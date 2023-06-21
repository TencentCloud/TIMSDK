package com.tencent.qcloud.tim.demo.push;

import androidx.annotation.NonNull;
import com.tencent.imsdk.v2.V2TIMConversation;

public class OfflineMessageBean {
    public static final int REDIRECT_ACTION_CHAT = 1;
    public static final int REDIRECT_ACTION_CALL = 2;

    public int version = 1;
    public int chatType = V2TIMConversation.V2TIM_C2C;
    public int action = REDIRECT_ACTION_CHAT;
    public String sender = "";
    public String nickname = "";
    public String faceUrl = "";
    public String content = "";
    // seconds
    public long sendTime = 0;

    @NonNull
    @Override
    public String toString() {
        return "OfflineMessageBean{"
            + "version=" + version + ", chatType='" + chatType + '\'' + ", action=" + action + ", sender=" + sender + ", nickname=" + nickname
            + ", faceUrl=" + faceUrl + ", content=" + content + ", sendTime=" + sendTime + '}';
    }
}