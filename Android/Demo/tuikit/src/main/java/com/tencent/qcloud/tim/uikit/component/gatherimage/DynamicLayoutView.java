package com.tencent.qcloud.tim.uikit.component.gatherimage;


import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;

public abstract class DynamicLayoutView<T> {
    protected ViewGroup mLayout;
    protected int mViewId;

    public void setLayout(ViewGroup layout) {
        this.mLayout = layout;
    }

    public void setMainViewId(int viewId) {
        this.mViewId = viewId;
    }

    public void addChild(View child, LayoutParams params) {
        mLayout.addView(child, params);
    }

    public abstract void parseInformation(T info);


}
