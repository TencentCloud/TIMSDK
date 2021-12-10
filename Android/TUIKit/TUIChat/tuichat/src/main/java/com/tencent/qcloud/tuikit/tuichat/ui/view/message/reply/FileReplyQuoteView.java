package com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.FileReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;

public class FileReplyQuoteView extends TUIReplyQuoteView {

    private View fileMsgLayout;
    private ImageView fileMsgIcon;
    private TextView fileMsgTv;
    @Override
    public int getLayoutResourceId() {
        return R.layout.chat_reply_quote_file_layout;
    }

    public FileReplyQuoteView(Context context) {
        super(context);
        fileMsgLayout = findViewById(R.id.file_msg_layout);
        fileMsgIcon = findViewById(R.id.file_msg_icon_iv);
        fileMsgTv = findViewById(R.id.file_msg_name_tv);
    }

    @Override
    public void onDrawReplyQuote(TUIReplyQuoteBean quoteBean) {
        fileMsgLayout.setVisibility(View.VISIBLE);
        if (quoteBean instanceof FileReplyQuoteBean) {
            fileMsgTv.setText(((FileReplyQuoteBean) quoteBean).getFileName());
        }
    }
}
