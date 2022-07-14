package com.tencent.qcloud.tuikit.tuichat.bean.message.reply;

import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomOrderMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.TextReplyQuoteView;

public class CustomOrderMessageReplyQuoteBean extends TextReplyQuoteBean{
    @Override
    public void onProcessReplyQuoteBean(TUIMessageBean messageBean) {
        if (messageBean instanceof CustomOrderMessageBean) {
            setText(((CustomOrderMessageBean) messageBean).getDescription());
        }
    }

    @Override
    public Class<? extends TUIReplyQuoteView> getReplyQuoteViewClass() {
        return TextReplyQuoteView.class;
    }
}
