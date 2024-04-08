package com.tencent.qcloud.tuikit.tuichat.classicui.component.noticelayout;

import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

/**
 *
 * The notification area {@link NoticeLayout} has a fixed position and can only be displayed or hidden.
 * The position will not change with the scrolling of the chat content. It can be used to display pending
 * group messages, or some broadcasts. This area is divided into two parts, which can be used to display
 * content topics and auxiliary topics. Click events can be set up in response to user actions.
 */
public interface INoticeLayout {
    /**
     *
     * Get parent view
     *
     * @return
     */
    RelativeLayout getParentLayout();

    /**
     *
     * Get the subject information of the notification View
     *
     * @return
     */
    TextView getContent();

    /**
     *
     * Get notifications for further actions View
     *
     * @return
     */
    TextView getContentExtra();

    /**
     *
     * Set the click event for the notification
     *
     * @param l
     */
    void setOnNoticeClickListener(View.OnClickListener l);

    /**
     *
     * Set whether the notification area is always displayed
     *
     * @param show  true
     */
    void alwaysShow(boolean show);
}
