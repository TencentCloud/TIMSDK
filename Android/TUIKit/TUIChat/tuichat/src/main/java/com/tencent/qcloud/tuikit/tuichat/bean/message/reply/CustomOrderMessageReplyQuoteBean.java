package com.tencent.qcloud.tuikit.tuichat.bean.message.reply;

import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomOrderMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

public class CustomOrderMessageReplyQuoteBean extends TextReplyQuoteBean{
    @Override
    public void onProcessReplyQuoteBean(TUIMessageBean messageBean) {
        if (messageBean instanceof CustomOrderMessageBean) {
            setText(((CustomOrderMessageBean) messageBean).getDescription());
        }
    }

}
