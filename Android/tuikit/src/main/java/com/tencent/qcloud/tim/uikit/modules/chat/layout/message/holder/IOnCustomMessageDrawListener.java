package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

/**
 * 用于渲染自定义消息的回调，TUIKit在刷新自定义消息时，会调用onDraw方法来绘制客户定义的UI
 */
public interface IOnCustomMessageDrawListener {

    /**
     * TUIKit在刷新自定义消息时，会调用该方法来绘制自定义的UI
     *
     * @param parent 使用者需要把自己定义的view加到parent里
     * @param info   消息体
     */
    void onDraw(ICustomMessageViewGroup parent, MessageInfo info);

}
