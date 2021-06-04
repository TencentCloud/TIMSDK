package com.tencent.qcloud.tim.uikit.base;

import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;

public interface IBaseMessageSender {
    /**
     * 调用 TUIKit 的接口发送消息
     * @param baseInfo 消息元祖类
     * @param pushInfo 离线推送设置，可为空
     * @param receiver 接受者
     * @param isGroup 是否是群消息
     * @param callBack 发送消息之后触发的回调
     */
    void sendMessage(IBaseInfo baseInfo, V2TIMOfflinePushInfo pushInfo, String receiver, boolean isGroup,boolean onlineUserOnly,  final IUIKitCallBack callBack);
}
