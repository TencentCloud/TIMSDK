package com.tencent.liteav.trtccalling.ui.floatwindow;

import android.animation.ValueAnimator;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;

import com.tencent.liteav.trtccalling.R;
import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtccalling.ui.base.BaseTUICallView;
import com.tencent.liteav.trtccalling.ui.base.Status;

/**
 * TUICalling组件悬浮窗服务
 * 组件通过home键退到后台,或者通过左上角按钮退到前一个界面时,拉起悬浮窗;
 * 点击悬浮窗可重新进入界面,且悬浮窗消失;
 * 直接点击桌面icon,也可重新进入界面,悬浮窗消失.
 */
public class FloatWindowService extends Service {
    private static final String TAG = "FloatWindowService";

    private static Intent          mStartIntent;
    private static BaseTUICallView mCallView;
    private static Context         mContext;

    private WindowManager              mWindowManager;
    private WindowManager.LayoutParams mWindowLayoutParams;

    private int mScreenWidth; //屏幕宽度
    private int mWidth;       //悬浮窗宽度

    public static void startFloatService(Context context, BaseTUICallView callView) {
        TRTCLogger.i(TAG, "startFloatService");
        mContext = context;
        mCallView = callView;
        mStartIntent = new Intent(context, FloatWindowService.class);
        context.startService(mStartIntent);
    }

    public static void stopService(Context context) {
        TRTCLogger.i(TAG, "stopService: startIntent = " + mStartIntent);
        if (null != mStartIntent) {
            context.stopService(mStartIntent);
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        initWindow();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return new FloatBinder();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Status.mIsShowFloatWindow = false;
        TRTCLogger.i(TAG, "onDestroy: mCallView = " + mCallView);
        if (null != mCallView) {
            // 移除悬浮窗口
            mWindowManager.removeView(mCallView);
            mCallView = null;
        }
    }

    /**
     * 设置悬浮窗基本参数（位置、宽高等）
     */
    private void initWindow() {
        mWindowManager = (WindowManager) getApplicationContext().getSystemService(Context.WINDOW_SERVICE);
        //设置好悬浮窗的参数
        mWindowLayoutParams = getParams();
        //屏幕宽度
        mScreenWidth = mWindowManager.getDefaultDisplay().getWidth();
        // 添加悬浮窗的视图
        TRTCLogger.i(TAG, "initWindow: mCallView = " + mCallView);
        if (null != mCallView) {
            mCallView.setBackgroundResource(R.drawable.trtccalling_bg_floatwindow_left);
            mWindowManager.addView(mCallView, mWindowLayoutParams);
            mCallView.setOnTouchListener(new FloatingListener());
        }
    }

    private WindowManager.LayoutParams getParams() {
        mWindowLayoutParams = new WindowManager.LayoutParams();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mWindowLayoutParams.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            mWindowLayoutParams.type = WindowManager.LayoutParams.TYPE_PHONE;
        }
        mWindowLayoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS;

        // 悬浮窗默认显示以左上角为起始坐标
        mWindowLayoutParams.gravity = Gravity.LEFT | Gravity.TOP;
        //悬浮窗的开始位置，设置从左上角开始，所以屏幕左上角是x=0,y=0.
        mWindowLayoutParams.x = 0;
        mWindowLayoutParams.y = mWindowManager.getDefaultDisplay().getHeight() / 2;
        //设置悬浮窗宽高
        mWindowLayoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
        mWindowLayoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
        mWindowLayoutParams.format = PixelFormat.TRANSPARENT;
        return mWindowLayoutParams;
    }

    //======================================悬浮窗Touch和贴边事件=============================//
    //开始触控的坐标，移动时的坐标（相对于屏幕左上角的坐标）
    private int mTouchStartX;
    private int mTouchStartY;
    private int mTouchCurrentX;
    private int mTouchCurrentY;
    //开始触控的坐标和结束时的坐标（相对于屏幕左上角的坐标）
    private int mStartX;
    private int mStartY;
    private int mStopX;
    private int mStopY;

    //标记悬浮窗是否移动，防止移动后松手触发了点击事件
    private boolean mIsMove;

    public class FloatBinder extends Binder {
        public FloatWindowService getService() {
            return FloatWindowService.this;
        }
    }

    private class FloatingListener implements View.OnTouchListener {
        @Override
        public boolean onTouch(View v, MotionEvent event) {
            int action = event.getAction();
            switch (action) {
                case MotionEvent.ACTION_DOWN:
                    mIsMove = false;
                    mTouchStartX = (int) event.getRawX(); //触摸点相对屏幕显示器左上角的坐标
                    mTouchStartY = (int) event.getRawY();
                    //悬浮窗不是全屏的,因此不能用getX()标记开始点,getX()是触摸点相对自身左上角的坐标
                    mStartX = (int) event.getRawX();
                    mStartY = (int) event.getRawY();
                    break;
                case MotionEvent.ACTION_MOVE:
                    mTouchCurrentX = (int) event.getRawX();
                    mTouchCurrentY = (int) event.getRawY();
                    mWindowLayoutParams.x += mTouchCurrentX - mTouchStartX;
                    mWindowLayoutParams.y += mTouchCurrentY - mTouchStartY;
                    if (null != mCallView) {
                        mWindowManager.updateViewLayout(mCallView, mWindowLayoutParams);
                    }
                    mTouchStartX = mTouchCurrentX;
                    mTouchStartY = mTouchCurrentY;
                case MotionEvent.ACTION_UP:
                    mStopX = (int) event.getRawX();
                    mStopY = (int) event.getRawY();
                    if (Math.abs(mStartX - mStopX) >= 5 || Math.abs(mStartY - mStopY) >= 5) {
                        mIsMove = true;
                        if (null != mCallView) {
                            mWidth = mCallView.getWidth();
                            //超出一半屏幕右移
                            if (mTouchCurrentX > (mScreenWidth / 2)) {
                                startScroll(mStopX, mScreenWidth - mWidth, false);
                            } else {
                                startScroll(mStopX, 0, true);
                            }
                        }
                    }
                    break;
                default:
                    break;
            }
            //移动事件拦截
            return mIsMove;
        }
    }

    //悬浮窗贴边动画
    private void startScroll(int start, int end, boolean isLeft) {
        mWidth = mCallView.getWidth();
        ValueAnimator valueAnimator = ValueAnimator.ofFloat(start, end).setDuration(300);
        valueAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                if (isLeft) {
                    mWindowLayoutParams.x = (int) (start * (1 - animation.getAnimatedFraction()));
                    mCallView.setBackgroundResource(R.drawable.trtccalling_bg_floatwindow_left);
                } else {
                    mWindowLayoutParams.x = (int) (start + (mScreenWidth - start - mWidth) * animation.getAnimatedFraction());
                    mCallView.setBackgroundResource(R.drawable.trtccalling_bg_floatwindow_right);
                }
                calculateHeight();
                mWindowManager.updateViewLayout(mCallView, mWindowLayoutParams);
            }
        });
        valueAnimator.start();
    }

    //计算高度,防止悬浮窗上下越界
    private void calculateHeight() {
        int height = mCallView.getHeight();
        int screenHeight = mWindowManager.getDefaultDisplay().getHeight();
        //获取系统状态栏的高度
        int resourceId = mContext.getResources().getIdentifier("status_bar_height",
                "dimen", "android");
        int statusBarHeight = mContext.getResources().getDimensionPixelSize(resourceId);
        if (mWindowLayoutParams.y < 0) {
            mWindowLayoutParams.y = 0;
        } else if (mWindowLayoutParams.y > (screenHeight - height - statusBarHeight)) {
            mWindowLayoutParams.y = screenHeight - height - statusBarHeight;
        }
    }
}
