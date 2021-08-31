package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import android.view.View;

/**
 * 自定义消息的容器
 */
public interface ICustomMessageViewGroup {

    /**
     * 把自定义消息的整个view添加到容器里
     *
     * @param view 自定义消息的整个view
     */
    void addMessageItemView(View view);

    /**
     * 把自定义消息的内容区域view添加到容器里
     *
     * @param view 自定义消息的内容区域view
     */
    void addMessageContentView(View view);
}
