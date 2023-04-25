package com.tencent.qcloud.tuikit.tuichat.bean.message.reply;

import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomLinkMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

public class CustomLinkReplyQuoteBean extends TextReplyQuoteBean {
    @Override
    public void onProcessReplyQuoteBean(TUIMessageBean messageBean) {
        if (messageBean instanceof CustomLinkMessageBean) {
            setText(((CustomLinkMessageBean) messageBean).getText());
        }
    }

}
