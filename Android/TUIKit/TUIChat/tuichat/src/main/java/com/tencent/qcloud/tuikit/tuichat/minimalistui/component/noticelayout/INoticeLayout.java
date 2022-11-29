package com.tencent.qcloud.tuikit.tuichat.minimalistui.component.noticelayout;

import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

/**
 * 通知区域 {@link com.tencent.qcloud.tuikit.tuichat.minimalistui.component.noticelayout.NoticeLayout} 位置固定，只能显示或隐藏，位置不会随聊天内容的滚动而变化，可以用来展示<br>
 * 待处理的群消息，或者一些广播等。该区域分为两部分，可以用来展示内容主题以及辅助主题。可以设置点击事件来<br>
 * 响应用户操作。
 * 
 * The notification area {@link com.tencent.qcloud.tuikit.tuichat.minimalistui.component.noticelayout.NoticeLayout} has a fixed position and can only be displayed or hidden.
 * The position will not change with the scrolling of the chat content. It can be used to display pending
 * group messages, or some broadcasts. This area is divided into two parts, which can be used to display 
 * content topics and auxiliary topics. Click events can be set up in response to user actions.
 */
public interface INoticeLayout {

    /**
     * 获取父视图
     *
     * Get parent view
     *
     * @return
     */
    RelativeLayout getParentLayout();

    /**
     * 获取通知的主题信息 View
     * 
     * Get the subject information of the notification View
     *
     * @return
     */
    TextView getContent();


    /**
     * 获取通知的进一步操作 View
     * 
     * Get notifications for further actions View
     *
     * @return
     */
    TextView getContentExtra();

    /**
     * 设置通知的点击事件
     * 
     * Set the click event for the notification
     *
     * @param l
     */
    void setOnNoticeClickListener(View.OnClickListener l);

    /**
     * 设置通知区域是否一直显示
     * 
     * Set whether the notification area is always displayed
     *
     * @param show 一直显示为 true
     */
    void alwaysShow(boolean show);

}
