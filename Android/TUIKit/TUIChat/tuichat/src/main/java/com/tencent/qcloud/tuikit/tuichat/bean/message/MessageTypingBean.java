package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageTyping;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class MessageTypingBean extends TUIMessageBean{
    private MessageTyping messageTyping;

    @Override
    public String onGetDisplayString() {
        return null;
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        String data = new String(v2TIMMessage.getCustomElem().getData());
        TUIChatLog.d("messageTypingBean", "data = " + data);
        if(!TextUtils.isEmpty(data)) {
            try {
                messageTyping = new Gson().fromJson(data, MessageTyping.class);
            } catch (Exception e) {
                TUIChatLog.e("messageTyping", "exception e = " + e);
            }
        }
        if (messageTyping == null) {
            TUIChatLog.e("messageTypingBean", "messageTyping is null");
        }
    }

    public int getTypingStatus() {
        if (messageTyping != null) {
            return messageTyping.typingStatus;
        }
        return 0;
    }
}
