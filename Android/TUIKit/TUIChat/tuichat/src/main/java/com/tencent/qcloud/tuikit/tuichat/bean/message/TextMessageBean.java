package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMMessage;

public class TextMessageBean extends TUIMessageBean {
    private String text;

    public TextMessageBean() {}

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
}
