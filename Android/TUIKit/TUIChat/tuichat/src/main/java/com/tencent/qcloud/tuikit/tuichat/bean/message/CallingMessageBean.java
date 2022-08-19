package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;


public class CallingMessageBean extends TextMessageBean {
    private String text;
    private int callType; //1：audio; 2:video
    public static final int ACTION_ID_AUDIO_CALL = 1;
    public static final int ACTION_ID_VIDEO_CALL = 2;

    @Override
    public String onGetDisplayString() {
        return text;
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        if (v2TIMMessage.getTextElem() != null) {
            text = v2TIMMessage.getTextElem().getText();
        }
        setExtra(text);
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public int getCallType() {
        return callType;
    }

    public void setCallType(int callType) {
        this.callType = callType;
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return TextReplyQuoteBean.class;
    }
}
