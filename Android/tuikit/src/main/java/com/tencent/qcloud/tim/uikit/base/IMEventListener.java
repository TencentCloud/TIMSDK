package com.tencent.qcloud.tim.uikit.base;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.util.List;

/**
 * IM事件监听
 */

public abstract class IMEventListener {
    private final static String TAG = IMEventListener.class.getSimpleName();

    /**
     * 被踢下线时回调
     */
    public void onForceOffline() {
        TUIKitLog.v(TAG, "onForceOffline");
    }

    /**
     * 用户票据过期
     */
    public void onUserSigExpired() {
        TUIKitLog.v(TAG, "onUserSigExpired");
    }

    /**
     * 连接建立
     */
    public void onConnected() {
        TUIKitLog.v(TAG, "onConnected");
    }

    /**
     * 连接断开
     *
     * @param code 错误码
     * @param desc 错误描述
     */
    public void onDisconnected(int code, String desc) {
        TUIKitLog.v(TAG, "onDisconnected, code:" + code + "|desc:" + desc);
    }

    /**
     * WIFI需要验证
     *
     * @param name wifi名称
     */
    public void onWifiNeedAuth(String name) {
        TUIKitLog.v(TAG, "onWifiNeedAuth, wifi name:" + name);
    }

    /**
     * 部分会话刷新（包括多终端已读上报同步）
     *
     * @param conversations 需要刷新的会话列表
     */
    public void onRefreshConversation(List<V2TIMConversation> conversations) {
        TUIKitLog.v(TAG, "onRefreshConversation, size:" + (conversations != null ? conversations.size() : 0));
    }

    /**
     * 收到新消息回调
     *
     * @param v2TIMMessage 收到的新消息
     */
    public void onNewMessage(V2TIMMessage v2TIMMessage) {
        TUIKitLog.v(TAG, "onNewMessage, msgID:" + (v2TIMMessage != null ? v2TIMMessage.getMsgID() : ""));
    }
}
