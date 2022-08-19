package com.tencent.qcloud.tuicore.component.interfaces;

import com.tencent.qcloud.tuicore.component.TitleBarLayout;

public interface ILayout {

    /**
     * get title bar
     *
     * @return
     */
    TitleBarLayout getTitleBar();

    /**
     * Set the parent container of this Layout
     *
     * @param parent
     */
    void setParentLayout(Object parent);
}
