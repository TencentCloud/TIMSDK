package com.tencent.qcloud.tuikit.tuichat.classicui.component.noticelayout;

import android.view.View;

public class NoticeLayoutConfig {
    private View mCustomView = null;

    /**
     *
     * Get a custom view of the chat interface
     */
    public View getCustomNoticeLayout() {
        return mCustomView;
    }

    /**
     *
     * Set a custom view of the chat interface
     */
    public void setCustomNoticeLayout(View mCustomNoticeLayout) {
        this.mCustomView = mCustomNoticeLayout;
    }
}
