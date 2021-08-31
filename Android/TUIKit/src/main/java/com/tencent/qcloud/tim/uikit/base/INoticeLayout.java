package com.tencent.qcloud.tim.uikit.base;

import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.component.NoticeLayout;

/**
 * 通知区域 {@link NoticeLayout} 位置固定，只能显示或隐藏，位置不会随聊天内容的滚动而变化，可以用来展示<br>
 * 待处理的群消息，或者一些广播等。该区域分为两部分，可以用来展示内容主题以及辅助主题。可以设置点击事件来<br>
 * 响应用户操作。
 */
public interface INoticeLayout {

    /**
     * 获取通知的主题信息 View
     *
     * @return
     */
    TextView getContent();


    /**
     * 获取通知的进一步操作 View
     *
     * @return
     */
    TextView getContentExtra();

    /**
     * 设置通知的点击事件
     *
     * @param l
     */
    void setOnNoticeClickListener(View.OnClickListener l);

    /**
     * 设置通知区域是否一直显示
     *
     * @param show 一直显示为 true
     */
    void alwaysShow(boolean show);

}
