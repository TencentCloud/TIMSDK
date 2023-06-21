package com.tencent.qcloud.tim.demo.main;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

public class TabRecyclerView extends RecyclerView {
    boolean isNeedIntercept = true;
    public TabRecyclerView(@NonNull Context context) {
        super(context);
    }

    public TabRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public TabRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent e) {
        return isNeedIntercept & super.onInterceptTouchEvent(e);
    }

    public void enableIntercept() {
        isNeedIntercept = true;
    }

    public void disableIntercept() {
        isNeedIntercept = false;
    }
}