package com.tencent.cloud.tuikit.roomkit.view.service;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.RoomVideoFloatView;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.TUIBuild;

public class RoomFloatViewService extends Service {
    private static final String TAG = "RoomFloatViewService";

    private static final int CLICK_ACTION_MAX_MOVE_DISTANCE_PX = 10;
    private static final int VIEW_MARGIN_EDGE_PX               = ScreenUtil.dip2px(10);

    private static Context mAppContext = TUILogin.getAppContext();

    private RoomVideoFloatView         mVideoFloatView;
    private WindowManager              mWindowManager;
    private WindowManager.LayoutParams mWindowLayoutParams;
    private WindowManager.LayoutParams mOldParams;

    private int mFloatViewWidth  =
            mAppContext.getResources().getDimensionPixelSize(R.dimen.tuiroomkit_room_video_float_view_width);
    private int mFloatViewHeight =
            mAppContext.getResources().getDimensionPixelSize(R.dimen.tuiroomkit_room_video_float_view_height);
    private int mMaxPositionX    = ScreenUtil.getScreenWidth(mAppContext) - mFloatViewWidth - VIEW_MARGIN_EDGE_PX;
    private int mMaxPositionY    = ScreenUtil.getScreenHeight(mAppContext) - mFloatViewHeight - VIEW_MARGIN_EDGE_PX;

    private float mTouchDownPointX;
    private float mTouchDownPointY;
    private float mCurPointX;
    private float mCurPointY;

    private boolean mIsActionDrag;

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "onCreate");
        initWindow();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "onStartCommand");
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy");
        if (mVideoFloatView != null) {
            mWindowManager.removeView(mVideoFloatView);
        }
    }


    private void initWindow() {
        mWindowManager = (WindowManager) getApplicationContext().getSystemService(Context.WINDOW_SERVICE);
        mVideoFloatView = new RoomVideoFloatView(getApplicationContext());

        mWindowLayoutParams = getViewParams();
        mWindowManager.addView(mVideoFloatView, mWindowLayoutParams);
        mVideoFloatView.setTouchListener(new FloatingListener());
    }

    private WindowManager.LayoutParams getViewParams() {
        mWindowLayoutParams = new WindowManager.LayoutParams();
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O) {
            mWindowLayoutParams.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            mWindowLayoutParams.type = WindowManager.LayoutParams.TYPE_PHONE;
        }
        mWindowLayoutParams.flags =
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                        | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS;

        mWindowLayoutParams.gravity = Gravity.LEFT | Gravity.TOP;
        mWindowLayoutParams.x = mMaxPositionX;
        mWindowLayoutParams.y = mMaxPositionY >> 1;

        mWindowLayoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
        mWindowLayoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
        mWindowLayoutParams.format = PixelFormat.TRANSPARENT;

        return mWindowLayoutParams;
    }

    private class FloatingListener implements View.OnTouchListener {
        @Override
        public boolean onTouch(View v, MotionEvent event) {
            int action = event.getAction();
            switch (action) {
                case MotionEvent.ACTION_DOWN:
                    mTouchDownPointX = event.getRawX();
                    mTouchDownPointY = event.getRawY();
                    mCurPointX = mTouchDownPointX;
                    mCurPointY = mTouchDownPointY;

                    mOldParams = mWindowLayoutParams;
                    mIsActionDrag = false;
                    break;

                case MotionEvent.ACTION_MOVE:
                    mWindowLayoutParams.x += (int) event.getRawX() - mCurPointX;
                    mWindowLayoutParams.y += (int) event.getRawY() - mCurPointY;

                    updateLayout();
                    updateFlagOfDragAction(event.getRawX(), event.getRawY());
                    mCurPointX = (int) event.getRawX();
                    mCurPointY = (int) event.getRawY();
                    break;

                case MotionEvent.ACTION_UP:
                    if (mIsActionDrag) {
                        autoMoveToScreenEdge();
                    } else {
                        moveBackToOriginalPosition();
                        handleClickAction();
                    }
                    break;

                default:
                    break;
            }
            return true;
        }
    }

    private void updateFlagOfDragAction(float xMovePoint, float yMovePoint) {
        float xDistance = Math.abs(xMovePoint - mTouchDownPointX);
        float yDistance = Math.abs(yMovePoint - mTouchDownPointY);
        if (xDistance >= CLICK_ACTION_MAX_MOVE_DISTANCE_PX || yDistance >= CLICK_ACTION_MAX_MOVE_DISTANCE_PX) {
            mIsActionDrag = true;
        }
    }

    private void handleClickAction() {
        Log.d(TAG, "handleClickAction");
        RoomEngineManager.sharedInstance(mAppContext).exitFloatWindow();
    }

    private void moveBackToOriginalPosition() {
        mWindowLayoutParams = mOldParams;
        mWindowManager.updateViewLayout(mVideoFloatView, mWindowLayoutParams);
    }

    private void autoMoveToScreenEdge() {
        mWindowLayoutParams.x = mWindowLayoutParams.x > (mMaxPositionX >> 1) ? mMaxPositionX : VIEW_MARGIN_EDGE_PX;
        mWindowManager.updateViewLayout(mVideoFloatView, mWindowLayoutParams);
    }

    private void updateLayout() {
        mWindowLayoutParams.x =
                mWindowLayoutParams.x < VIEW_MARGIN_EDGE_PX ? VIEW_MARGIN_EDGE_PX : mWindowLayoutParams.x;
        mWindowLayoutParams.x = mWindowLayoutParams.x > mMaxPositionX ? mMaxPositionX : mWindowLayoutParams.x;
        mWindowLayoutParams.y =
                mWindowLayoutParams.y < VIEW_MARGIN_EDGE_PX ? VIEW_MARGIN_EDGE_PX : mWindowLayoutParams.y;
        mWindowLayoutParams.y = mWindowLayoutParams.y > mMaxPositionY ? mMaxPositionY : mWindowLayoutParams.y;
        mWindowManager.updateViewLayout(mVideoFloatView, mWindowLayoutParams);
    }
}
