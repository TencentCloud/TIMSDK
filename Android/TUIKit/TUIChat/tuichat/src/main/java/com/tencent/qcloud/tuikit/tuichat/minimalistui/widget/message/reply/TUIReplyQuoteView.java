package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply;

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

    /**
     * 原始消息发送者是否为自己 ， 用于不同 UI 展示
     * 
     * Whether the original message sender is himself, used for different UI displays
     * 
     * @param isSelf
     */
    public void setSelf(boolean isSelf) {}

}
