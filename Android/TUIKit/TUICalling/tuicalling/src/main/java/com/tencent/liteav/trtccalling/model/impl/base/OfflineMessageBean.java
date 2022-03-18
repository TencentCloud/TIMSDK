package com.tencent.liteav.trtccalling.model.impl.base;

import com.tencent.imsdk.v2.V2TIMConversation;


public class OfflineMessageBean {

    public static final int DEFAULT_VERSION      = 1;
    public static final int REDIRECT_ACTION_CHAT = 1;
    public static final int REDIRECT_ACTION_CALL = 2;

    public int    version  = DEFAULT_VERSION;
    public int    chatType = V2TIMConversation.V2TIM_C2C;
    public int    action   = REDIRECT_ACTION_CHAT;
    public String sender   = "";
    public String nickname = "";
    public String faceUrl  = "";
    public String content  = "";
    // 发送时间戳，单位秒
    public long   sendTime = 0;

    @Override
    public String toString() {
        return "OfflineMessageBean{" +
                "version=" + version +
                ", chatType='" + chatType + '\'' +
                ", action=" + action +
                ", sender=" + sender +
                ", nickname=" + nickname +
                ", faceUrl=" + faceUrl +
                ", content=" + content +
                ", sendTime=" + sendTime +
                '}';
    }
}