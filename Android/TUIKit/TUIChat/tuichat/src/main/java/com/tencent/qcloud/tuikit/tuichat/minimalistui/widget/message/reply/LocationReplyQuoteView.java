package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply;

import android.content.Context;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.TUIReplyQuoteView;

public class LocationReplyQuoteView extends TUIReplyQuoteView {
    @Override
    public int getLayoutResourceId() {
        return 0;
    }

    public LocationReplyQuoteView(Context context) {
        super(context);
    }

    @Override
    public void onDrawReplyQuote(TUIReplyQuoteBean quoteBean) {

    }
}
