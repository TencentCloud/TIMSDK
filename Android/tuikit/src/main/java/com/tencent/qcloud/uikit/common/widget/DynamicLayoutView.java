package com.tencent.qcloud.uikit.common.widget;


import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;

import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;

public abstract class DynamicLayoutView<T> {
    protected ViewGroup mContainer;
    protected int mViewId;

    public void setLayoutContainer(ViewGroup container) {
        this.mContainer = container;
    }

    public void setMainViewId(int viewId) {
        this.mViewId = viewId;
    }

    public void addChild(View child, LayoutParams params) {
        mContainer.addView(child, params);
    }

    public abstract void parseInformation(T info);


}
