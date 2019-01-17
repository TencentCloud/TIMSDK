package com.tencent.qcloud.uikit.common.component.datepicker.listener;

import android.view.MotionEvent;

import com.tencent.qcloud.uikit.common.component.datepicker.view.WheelView;


public final class LoopViewGestureListener extends android.view.GestureDetector.SimpleOnGestureListener {

    private final WheelView wheelView;


    public LoopViewGestureListener(WheelView wheelView) {
        this.wheelView = wheelView;
    }

    @Override
    public final boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
        wheelView.scrollBy(velocityY);
        return true;
    }
}
