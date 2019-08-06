package com.tencent.qcloud.tim.uikit.base;

import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;

public interface ILayout {

    /**
     * 获取标题栏
     *
     * @return
     */
    TitleBarLayout getTitleBar();

    /**
     * 设置该 Layout 的父容器
     *
     * @param parent
     */
    void setParentLayout(Object parent);
}
