package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply;

import android.content.Context;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;

public class TextReplyQuoteView extends TUIReplyQuoteView {
    protected TextView textView;

    @Override
    public int getLayoutResourceId() {
        return R.layout.chat_reply_quote_text_layout;
    }

    public TextReplyQuoteView(Context context) {
        super(context);
        textView = findViewById(R.id.text_quote_tv);
    }

    @Override
    public void setSelf(boolean isSelf) {
        if (!isSelf) {
            textView.setTextColor(
                textView.getResources().getColor(TUIThemeManager.getAttrResId(textView.getContext(), R.attr.chat_other_reply_quote_text_color)));
        } else {
            textView.setTextColor(
                textView.getResources().getColor(TUIThemeManager.getAttrResId(textView.getContext(), R.attr.chat_self_reply_quote_text_color)));
        }
    }

    @Override
    public void onDrawReplyQuote(TUIReplyQuoteBean quoteBean) {
        if (quoteBean instanceof TextReplyQuoteBean) {
            String text = ((TextReplyQuoteBean) quoteBean).getText();
            FaceManager.handlerEmojiText(textView, text, false);
        }
    }
}
