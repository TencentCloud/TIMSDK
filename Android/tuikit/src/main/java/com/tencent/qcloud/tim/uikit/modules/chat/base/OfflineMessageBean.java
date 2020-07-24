package com.tencent.qcloud.tim.uikit.modules.chat.base;

import com.tencent.imsdk.TIMConversationType;

import androidx.annotation.NonNull;

public class OfflineMessageBean {

    public static final int REDIRECT_ACTION_CHAT = 1;
    public static final int REDIRECT_ACTION_CALL = 2;

    public int version = 1;
    public int chatType = TIMConversationType.C2C.value();
    public int action = REDIRECT_ACTION_CHAT;
    public String sender = "";
    public String nickname = "";
    public String faceUrl = "";
    public String content = "";
    // 发送时间戳，单位秒
    public long sendTime = 0;

    @NonNull
    @Override
    public String toString() {
        return  "OfflineMessageBean{" +
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