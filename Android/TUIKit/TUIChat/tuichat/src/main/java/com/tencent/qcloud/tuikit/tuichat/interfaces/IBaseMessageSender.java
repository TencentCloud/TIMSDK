package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.OfflinePushInfo;

public interface IBaseMessageSender {
    /**
     * 调用 TUIKit 的接口发送消息
     * @param messageInfo 消息元祖类
     */
    void sendMessage(final MessageInfo messageInfo, String receiver, boolean isGroup);
}
