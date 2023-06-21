package com.tencent.cloud.tuikit.roomkit.imaccess.view;

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

import com.google.gson.Gson;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.observer.RoomMsgData;
import com.tencent.cloud.tuikit.roomkit.imaccess.presenter.RoomPresenter;
import com.tencent.cloud.tuikit.roomkit.utils.DrawOverlaysPermissionUtil;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.TUIBuild;

public class RoomFloatViewService extends Service {
    private static final String TAG = "RoomFloatViewService";

    private static Intent mStartIntent;

    private static final int CLICK_ACTION_MAX_MOVE_DISTANCE_PX = 10;
    private static final int VIEW_MARGIN_EDGE_PX               = ScreenUtil.dip2px(10);

    private static Context mAppContext = TUILogin.getAppContext();

    private RoomFloatView              mFloatView;
    private WindowManager              mWindowManager;
    private WindowManager.LayoutParams mWindowLayoutParams;
    private WindowManager.LayoutParams mOldParams;


    private int mFloatViewSize =
            mAppContext.getResources().getDimensionPixelSize(R.dimen.tuiroomkit_room_float_view_size);
    private int mMaxPositionX  = ScreenUtil.getScreenWidth(mAppContext) - mFloatViewSize - VIEW_MARGIN_EDGE_PX;
    private int mMaxPositionY  = ScreenUtil.getScreenHeight(mAppContext) - mFloatViewSize - VIEW_MARGIN_EDGE_PX;

    private float mTouchDownPointX;
    private float mTouchDownPointY;
    private float mCurPointX;
    private float mCurPointY;

    private boolean mIsActionDrag;

    private RoomMsgData mRoomMsgData;

    public static void showFloatView(RoomMsgData roomMsgData) {
        if (!DrawOverlaysPermissionUtil.isGrantedDrawOverlays()) {
            Log.d(TAG, "showFloatView no float permission");
            return;
        }
        if (mStartIntent != null) {
            Log.d(TAG, "showFloatView is showed");
            return;
        }
        Log.d(TAG, "showFloatView");
        mStartIntent = new Intent(mAppContext, RoomFloatViewService.class);
        Gson gson = new Gson();
        String content = gson.toJson(roomMsgData);
        mStartIntent.putExtra(AccessRoomConstants.KEY_INVITE_DATA, content);
        mAppContext.startService(mStartIntent);
    }

    public static void dismissFloatView() {
        if (mStartIntent == null) {
            Log.d(TAG, "dismissFloatView mStartIntent is null");
            return;
        }
        Log.d(TAG, "dismissFloatView");
        final Intent startIntent = mStartIntent;
        mAppContext.stopService(startIntent);
        mStartIntent = null;
    }

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
        String data = intent.getStringExtra(AccessRoomConstants.KEY_INVITE_DATA);
        Gson gson = new Gson();
        mRoomMsgData = gson.fromJson(data, RoomMsgData.class);
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy");
        if (mFloatView != null) {
            mWindowManager.removeView(mFloatView);
        }
    }


    private void initWindow() {
        mWindowManager = (WindowManager) getApplicationContext().getSystemService(Context.WINDOW_SERVICE);
        mFloatView = new RoomFloatView(getApplicationContext());

        mWindowLayoutParams = getViewParams();
        mWindowManager.addView(mFloatView, mWindowLayoutParams);
        mFloatView.setTouchListener(new FloatingListener());
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
        dismissFloatView();
        if (mRoomMsgData == null) {
            Log.e(TAG, "handleClickAction mRoomMsgData is null");
        }
        RoomPresenter.getInstance().enterRoom(mRoomMsgData);
    }

    private void moveBackToOriginalPosition() {
        mWindowLayoutParams = mOldParams;
        mWindowManager.updateViewLayout(mFloatView, mWindowLayoutParams);
    }

    private void autoMoveToScreenEdge() {
        mWindowLayoutParams.x = mWindowLayoutParams.x > (mMaxPositionX >> 1) ? mMaxPositionX : VIEW_MARGIN_EDGE_PX;
        mWindowManager.updateViewLayout(mFloatView, mWindowLayoutParams);
    }

    private void updateLayout() {
        mWindowLayoutParams.x =
                mWindowLayoutParams.x < VIEW_MARGIN_EDGE_PX ? VIEW_MARGIN_EDGE_PX : mWindowLayoutParams.x;
        mWindowLayoutParams.x = mWindowLayoutParams.x > mMaxPositionX ? mMaxPositionX : mWindowLayoutParams.x;
        mWindowLayoutParams.y =
                mWindowLayoutParams.y < VIEW_MARGIN_EDGE_PX ? VIEW_MARGIN_EDGE_PX : mWindowLayoutParams.y;
        mWindowLayoutParams.y = mWindowLayoutParams.y > mMaxPositionY ? mMaxPositionY : mWindowLayoutParams.y;
        mWindowManager.updateViewLayout(mFloatView, mWindowLayoutParams);
    }
}
