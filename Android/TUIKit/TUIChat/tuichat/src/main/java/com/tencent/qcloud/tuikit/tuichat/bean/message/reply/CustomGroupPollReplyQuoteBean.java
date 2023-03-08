package com.tencent.qcloud.tuikit.tuichat.bean.message.reply;

import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomPollMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

public class CustomGroupPollReplyQuoteBean extends TextReplyQuoteBean {
    @Override
    public void onProcessReplyQuoteBean(TUIMessageBean messageBean) {
        if (messageBean instanceof CustomPollMessageBean) {
            setText(((CustomPollMessageBean) messageBean).getText());
        }
    }

}
