package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.content.Intent;
import android.net.Uri;
import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomLinkMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;


public class CustomLinkMessageHolder extends MessageContentHolder {
    private TextView textView;
    private TextView linkView;

    public CustomLinkMessageHolder(View itemView) {
        super(itemView);
        textView = itemView.findViewById(R.id.test_custom_message_tv);
        linkView = itemView.findViewById(R.id.link_tv);
    }

    public static final String TAG = CustomLinkMessageHolder.class.getSimpleName();

    @Override
    public int getVariableLayout() {
        return R.layout.test_custom_message_layout1;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        // 自定义消息view的实现，这里仅仅展示文本信息，并且实现超链接跳转

        String text = "";
        String link = "";
        if (msg instanceof CustomLinkMessageBean) {
            text = ((CustomLinkMessageBean) msg).getText();
            link = ((CustomLinkMessageBean) msg).getLink();
        }

        if (!msg.isSelf()) {
            textView.setTextColor(textView.getResources().getColor(TUIThemeManager.getAttrResId(textView.getContext(), R.attr.chat_other_custom_msg_text_color)));
            linkView.setTextColor(textView.getResources().getColor(TUIThemeManager.getAttrResId(textView.getContext(), R.attr.chat_other_custom_msg_link_color)));
        } else {
            textView.setTextColor(textView.getResources().getColor(TUIThemeManager.getAttrResId(textView.getContext(), R.attr.chat_self_custom_msg_text_color)));
            linkView.setTextColor(textView.getResources().getColor(TUIThemeManager.getAttrResId(textView.getContext(), R.attr.chat_self_custom_msg_link_color)));
        }

        textView.setText(text);
        msgContentFrame.setClickable(true);
        String finalLink = link;
        msgContentFrame.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent();
                intent.setAction("android.intent.action.VIEW");
                Uri content_url = Uri.parse(finalLink);
                intent.setData(content_url);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                TUIChatService.getAppContext().startActivity(intent);
            }
        });

    }
}
