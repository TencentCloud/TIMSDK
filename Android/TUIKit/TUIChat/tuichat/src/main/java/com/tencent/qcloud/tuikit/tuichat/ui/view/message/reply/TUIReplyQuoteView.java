package com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply;

import android.content.Context;
import android.view.LayoutInflater;
import android.widget.FrameLayout;

import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;

public abstract class TUIReplyQuoteView extends FrameLayout {

    public abstract int getLayoutResourceId();

    public TUIReplyQuoteView(Context context) {
        super(context);
        int resId = getLayoutResourceId();
        if (resId != 0) {
            LayoutInflater.from(context).inflate(resId, this, true);
        }
    }

    public abstract void onDrawReplyQuote(TUIReplyQuoteBean quoteBean);

}
