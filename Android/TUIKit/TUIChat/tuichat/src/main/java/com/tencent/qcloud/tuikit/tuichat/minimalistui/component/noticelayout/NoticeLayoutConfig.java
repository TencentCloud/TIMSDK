package com.tencent.qcloud.tuikit.tuichat.minimalistui.component.noticelayout;

import android.view.ViewGroup;

public class NoticeLayoutConfig {
    private ViewGroup mCustomNoticeLayout = null;

    /**
     * 获取聊天界面自定义视图
     *
     * Get a custom view of the chat interface
     */
    public ViewGroup getCustomNoticeLayout() {
        return mCustomNoticeLayout;
    }

    /**
     * 设置聊天界面自定义视图
     *
     * Set a custom view of the chat interface
     */
    public void setCustomNoticeLayout(ViewGroup mCustomNoticeLayout) {
        this.mCustomNoticeLayout = mCustomNoticeLayout;
    }
}
