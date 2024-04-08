package com.tencent.qcloud.tuikit.tuichatbotplugin.bean;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.util.TUIChatBotMessageParser;

public class RichTextMessageBean extends TextMessageBean {
    private String content;

    @Override
    public String onGetDisplayString() {
        return "Rich Text";
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        content = TUIChatBotMessageParser.getRichText(v2TIMMessage);
        setExtra(content);
    }
}
