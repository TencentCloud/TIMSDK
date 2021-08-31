package com.tencent.qcloud.tim.uikit.modules.conversation.interfaces;

import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationProvider;

public interface ILoadConversationCallback {
    void onSuccess(ConversationProvider provider, boolean isFinished, long nextSeq);

    void onError(String module, int errCode, String errMsg);
}
