package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMMessage;

import java.util.HashSet;
import java.util.Set;

public class ChatbotPlaceholderMessageBean extends TextMessageBean {
    private static final String TAG = "ChatbotPlaceholderMessageBean";

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {

    }

    @Override
    public String getSender() {
        return getUserId();
    }

    @Override
    public Set<String> getAdditionalUserIDList() {
        Set<String> userIDs = new HashSet<>();
        userIDs.add(getUserId());
        return userIDs;
    }

    @Override
    public boolean isUseMsgReceiverAvatar() {
        return true;
    }
}
