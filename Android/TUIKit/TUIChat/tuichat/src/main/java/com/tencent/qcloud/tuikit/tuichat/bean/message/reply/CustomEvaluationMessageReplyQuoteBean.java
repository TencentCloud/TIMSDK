package com.tencent.qcloud.tuikit.tuichat.bean.message.reply;

import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomEvaluationMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.TextReplyQuoteView;

public class CustomEvaluationMessageReplyQuoteBean extends TextReplyQuoteBean {
    @Override
    public void onProcessReplyQuoteBean(TUIMessageBean messageBean) {
        if (messageBean instanceof CustomEvaluationMessageBean) {
            setText(((CustomEvaluationMessageBean) messageBean).getContent());
        }
    }

    @Override
    public Class<? extends TUIReplyQuoteView> getReplyQuoteViewClass() {
        return TextReplyQuoteView.class;
    }

}
