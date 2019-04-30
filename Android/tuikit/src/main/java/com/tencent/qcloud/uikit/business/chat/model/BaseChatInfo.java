package com.tencent.qcloud.uikit.business.chat.model;

import com.tencent.imsdk.TIMConversationType;

/**
 * 聊天信息基本类
 */

public class BaseChatInfo {
    /**
     * 聊天的标题，C2C一般为对方名称，群聊为群名字
     */
    private String chatName;
    /**
     * 聊天类型
     */
    private TIMConversationType type;
    /**
     * 聊天标识
     */
    private String peer;

    public BaseChatInfo() {

    }

    public String getChatName() {
        return chatName;
    }

    public void setChatName(String chatName) {
        this.chatName = chatName;
    }

    public TIMConversationType getType() {
        return type;
    }

    public void setType(TIMConversationType type) {
        this.type = type;
    }

    public String getPeer() {
        return peer;
    }

    public void setPeer(String peer) {
        this.peer = peer;
    }

}
