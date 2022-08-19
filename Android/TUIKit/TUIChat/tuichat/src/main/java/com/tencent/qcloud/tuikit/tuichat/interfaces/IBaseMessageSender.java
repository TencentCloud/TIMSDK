package com.tencent.qcloud.tuikit.tuichat.interfaces;


import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

public interface IBaseMessageSender {
    /**
     * 调用 TUIKit 的接口发送消息
     * 
     * send message 
     * 
     * @param message 消息
     * @param receiver 接收者 Id
     * @param isGroup 是否为群组
     */
    void sendMessage(final TUIMessageBean message, String receiver, boolean isGroup);
}
