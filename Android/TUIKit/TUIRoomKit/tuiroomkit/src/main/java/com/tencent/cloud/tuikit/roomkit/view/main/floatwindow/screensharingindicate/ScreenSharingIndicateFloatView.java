package com.tencent.cloud.tuikit.roomkit.view.main.floatwindow.screensharingindicate;

import android.content.Context;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.WindowManager;
import android.widget.LinearLayout;

public class ScreenSharingIndicateFloatView extends LinearLayout implements GestureDetector.OnGestureListener {

    protected final Context                    mContext;
    protected final WindowManager              mWindowManager;
    private         GestureDetector            mGestureDetector;
    private         WindowManager.LayoutParams layoutParams;
    private         float                      lastX;
    private         float                      lastY;

    public ScreenSharingIndicateFloatView(Context context) {
        this(context, null);
    }

    public ScreenSharingIndicateFloatView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ScreenSharingIndicateFloatView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mContext = context;
        mGestureDetector = new GestureDetector(context, this);
        mWindowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        return mGestureDetector.onTouchEvent(event);
    }

    @Override
    public boolean onDown(MotionEvent e) {
        lastX = e.getRawX();
        lastY = e.getRawY();
        return false;
    }

    @Override
    public void onShowPress(MotionEvent e) {
    }

    @Override
    public boolean onSingleTapUp(MotionEvent e) {
        return false;
    }

    @Override
    public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
        if (layoutParams == null) {
            layoutParams = (WindowManager.LayoutParams) getLayoutParams();
        }

        float nowX;
        float nowY;
        float tranX;
        nowX = e2.getRawX();
        nowY = e2.getRawY();
        tranX = nowX - lastX;
        float tranY = nowY - lastY;
        layoutParams.x += tranX;
        layoutParams.y += tranY;
        mWindowManager.updateViewLayout(this, layoutParams);
        lastX = nowX;
        lastY = nowY;
        return false;
    }

    @Override
    public void onLongPress(MotionEvent e) {
    }

    @Override
    public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
        return false;
    }

}