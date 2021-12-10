package com.tencent.qcloud.tuikit.tuichat.bean.message.reply;

import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.LocationReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.TUIReplyQuoteView;

public class LocationReplyQuoteBean extends TUIReplyQuoteBean {
    @Override
    public void onProcessReplyQuoteBean(TUIMessageBean messageBean) {

    }

    @Override
    public Class<? extends TUIReplyQuoteView> getReplyQuoteViewClass() {
        return LocationReplyQuoteView.class;
    }
}
