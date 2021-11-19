package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.content.Intent;
import android.net.Uri;
import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomLinkMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;


public class CustomLinkMessageHolder extends MessageContentHolder {

    public CustomLinkMessageHolder(View itemView) {
        super(itemView);
    }

    public static final String TAG = CustomLinkMessageHolder.class.getSimpleName();

    @Override
    public int getVariableLayout() {
        return R.layout.test_custom_message_layout1;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        // 自定义消息view的实现，这里仅仅展示文本信息，并且实现超链接跳转

        TextView textView = itemView.findViewById(R.id.test_custom_message_tv);
        String text = "";
        String link = "";
        if (msg instanceof CustomLinkMessageBean) {
            text = ((CustomLinkMessageBean) msg).getText();
            link = ((CustomLinkMessageBean) msg).getLink();
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

        msgContentFrame.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if (onItemLongClickListener != null) {
                    onItemLongClickListener.onMessageLongClick(v, position, msg);
                }
                return false;
            }
        });
    }
}
