package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import android.text.Html;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.face.FaceManager;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

public class MessageCustomHolder extends MessageContentHolder implements ICustomMessageViewGroup {

    private TextView msgBodyText;

    public MessageCustomHolder(View itemView) {
        super(itemView);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_text;
    }

    @Override
    public void initVariableViews() {
        msgBodyText = rootView.findViewById(R.id.msg_body_tv);
    }

    @Override
    public void layoutViews(MessageInfo msg, int position) {
        super.layoutViews(msg, position);
    }

    @Override
    public void layoutVariableViews(MessageInfo msg, int position) {
        msgBodyText.setVisibility(View.VISIBLE);
        msgBodyText.setText(Html.fromHtml("<font color=\"#338BFF\">[不支持的自定义消息]</font>"));
        if (properties.getChatContextFontSize() != 0) {
            msgBodyText.setTextSize(properties.getChatContextFontSize());
        }
        if (msg.isSelf()) {
            if (properties.getRightChatContentFontColor() != 0) {
                msgBodyText.setTextColor(properties.getRightChatContentFontColor());
            }
        } else {
            if (properties.getLeftChatContentFontColor() != 0) {
                msgBodyText.setTextColor(properties.getLeftChatContentFontColor());
            }
        }
    }

    @Override
    public void addMessageItemView(View view) {
        ((RelativeLayout) rootView).removeAllViews();
        ((RelativeLayout) rootView).addView(chatTimeText, 0);
        if (view != null) {
            ((RelativeLayout) rootView).addView(view, 1);
        }
    }

    @Override
    public void addMessageContentView(View view) {
        if (view != null) {
            msgContentFrame.removeAllViews();
            msgContentFrame.addView(view);
        }
    }

}
