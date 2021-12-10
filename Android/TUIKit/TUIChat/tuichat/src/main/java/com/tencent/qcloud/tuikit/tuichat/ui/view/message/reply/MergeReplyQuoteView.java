package com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;

import java.util.List;

public class MergeReplyQuoteView extends TUIReplyQuoteView {
    private View mergeMsgLayout;
    private TextView mergeMsgTitle;
    private TextView mergeMsgContent;
    @Override
    public int getLayoutResourceId() {
        return R.layout.chat_reply_quote_merge_layout;
    }

    public MergeReplyQuoteView(Context context) {
        super(context);
        mergeMsgLayout = findViewById(R.id.merge_msg_layout);
        mergeMsgTitle = findViewById(R.id.merge_msg_title);
        mergeMsgContent = findViewById(R.id.merge_msg_content);
    }

    @Override
    public void onDrawReplyQuote(TUIReplyQuoteBean quoteBean) {
        MergeMessageBean messageBean = (MergeMessageBean) quoteBean.getMessageBean();
        mergeMsgLayout.setVisibility(View.VISIBLE);
        String title = messageBean.getTitle();
        List<String> abstractList= messageBean.getAbstractList();
        mergeMsgTitle.setText(title);
        String content = "";
        for (int i = 0; i < abstractList.size(); i++) {
            // 最多显示两行
            if (i >= 2) {
                break;
            }
            if (i != 0) {
                content += "\n";
            }
            content += abstractList.get(i);
        }
        content = FaceManager.emojiJudge(content);
        mergeMsgContent.setText(content);
    }
}
