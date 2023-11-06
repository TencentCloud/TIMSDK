package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.content.Context;
import android.widget.TextView;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CollectionMessageReplyQuoteBean;

public class CollectionReplyView extends TUIReplyQuoteView<CollectionMessageReplyQuoteBean> {
    private TextView textView;

    public CollectionReplyView(Context context) {
        super(context);
        textView = findViewById(R.id.text_quote_tv);
    }

    @Override
    public int getLayoutResourceId() {
        return R.layout.collection_reply_quote_text_layout;
    }

    @Override
    public void onDrawReplyQuote(CollectionMessageReplyQuoteBean quoteBean) {
        String text = quoteBean.getText();
        FaceManager.handlerEmojiText(textView, text, false);
    }
}
