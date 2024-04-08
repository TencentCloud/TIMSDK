package com.tencent.qcloud.tuikit.tuichatbotplugin.bean;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;

public class RichTextMessageReplyQuoteBean extends TUIReplyQuoteBean<RichTextMessageBean> {
    private String text;

    public String getText() {
        return text;
    }

    @Override
    public void onProcessReplyQuoteBean(RichTextMessageBean messageBean) {
        text = messageBean.getExtra();
    }
}
