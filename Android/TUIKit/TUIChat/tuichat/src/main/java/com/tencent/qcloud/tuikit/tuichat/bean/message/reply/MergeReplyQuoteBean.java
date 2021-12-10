package com.tencent.qcloud.tuikit.tuichat.bean.message.reply;

import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.MergeReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.TUIReplyQuoteView;

public class MergeReplyQuoteBean extends TUIReplyQuoteBean {
    @Override
    public void onProcessReplyQuoteBean(TUIMessageBean messageBean) {

    }


    @Override
    public Class<? extends TUIReplyQuoteView> getReplyQuoteViewClass() {
        return MergeReplyQuoteView.class;
    }
}
