package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.reply;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;

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
    public void setSelf(boolean isSelf) {
        if (!isSelf) {
            mergeMsgContent.setTextColor(
                mergeMsgContent.getResources().getColor(TUIThemeManager.getAttrResId(mergeMsgContent.getContext(), R.attr.chat_other_reply_quote_text_color)));
            mergeMsgTitle.setTextColor(
                mergeMsgTitle.getResources().getColor(TUIThemeManager.getAttrResId(mergeMsgTitle.getContext(), R.attr.chat_other_reply_quote_text_color)));
        } else {
            mergeMsgContent.setTextColor(
                mergeMsgContent.getResources().getColor(TUIThemeManager.getAttrResId(mergeMsgContent.getContext(), R.attr.chat_self_reply_quote_text_color)));
            mergeMsgTitle.setTextColor(
                mergeMsgTitle.getResources().getColor(TUIThemeManager.getAttrResId(mergeMsgTitle.getContext(), R.attr.chat_self_reply_quote_text_color)));
        }
    }

    @Override
    public void onDrawReplyQuote(TUIReplyQuoteBean quoteBean) {
        MergeMessageBean messageBean = (MergeMessageBean) quoteBean.getMessageBean();
        mergeMsgLayout.setVisibility(View.VISIBLE);
        String title = messageBean.getTitle();
        List<String> abstractList = messageBean.getAbstractList();
        mergeMsgTitle.setText(title);
        String content = "";
        for (int i = 0; i < abstractList.size(); i++) {
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
