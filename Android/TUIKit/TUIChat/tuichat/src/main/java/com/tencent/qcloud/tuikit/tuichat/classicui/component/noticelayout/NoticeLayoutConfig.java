package com.tencent.qcloud.tuikit.tuichat.classicui.component.noticelayout;

import android.view.ViewGroup;

public class NoticeLayoutConfig {
    private ViewGroup mCustomNoticeLayout = null;

    /**
     *
     * Get a custom view of the chat interface
     */
    public ViewGroup getCustomNoticeLayout() {
        return mCustomNoticeLayout;
    }

    /**
     *
     * Set a custom view of the chat interface
     */
    public void setCustomNoticeLayout(ViewGroup mCustomNoticeLayout) {
        this.mCustomNoticeLayout = mCustomNoticeLayout;
    }
}
