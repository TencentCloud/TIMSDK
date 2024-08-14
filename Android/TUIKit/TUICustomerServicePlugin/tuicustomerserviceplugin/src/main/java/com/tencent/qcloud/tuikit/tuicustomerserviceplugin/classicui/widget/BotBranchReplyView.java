package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.content.Context;
import android.widget.TextView;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.BotBranchMessageReplyQuoteBean;

public class BotBranchReplyView extends TUIReplyQuoteView<BotBranchMessageReplyQuoteBean> {
    private TextView textView;

    public BotBranchReplyView(Context context) {
        super(context);
        textView = findViewById(R.id.text_quote_tv);
    }

    @Override
    public int getLayoutResourceId() {
        return R.layout.bot_branch_reply_quote_text_layout;
    }

    @Override
    public void onDrawReplyQuote(BotBranchMessageReplyQuoteBean quoteBean) {
        String text = quoteBean.getText();
        FaceManager.handlerEmojiText(textView, text, false);
    }
}
