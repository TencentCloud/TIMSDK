package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

public class MessageTipsHolder extends MessageEmptyHolder {

    private TextView chat_tips_tv;

    public MessageTipsHolder(View itemView) {
        super(itemView);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_tips;
    }

    @Override
    public void initVariableViews() {
        chat_tips_tv = rootView.findViewById(R.id.chat_tips_tv);
    }

    @Override
    public void layoutViews(MessageInfo msg, int position) {
        super.layoutViews(msg, position);

        if (properties.getTipsMessageBubble() != null) {
            chat_tips_tv.setBackground(properties.getTipsMessageBubble());
        }
        if (properties.getTipsMessageFontColor() != 0) {
            chat_tips_tv.setTextColor(properties.getTipsMessageFontColor());
        }
        if (properties.getTipsMessageFontSize() != 0) {
            chat_tips_tv.setTextSize(properties.getTipsMessageFontSize());
        }

        if (msg.getStatus() == MessageInfo.MSG_STATUS_REVOKE) {
            if (msg.isSelf())
                chat_tips_tv.setText("您撤回了一条消息");
            else if (msg.isGroup()) {
                chat_tips_tv.setText(msg.getFromUser() + "撤回了一条消息");
            } else {
                chat_tips_tv.setText("对方撤回了一条消息");
            }

        } else if (msg.getMsgType() >= MessageInfo.MSG_TYPE_GROUP_CREATE && msg.getMsgType() <= MessageInfo.MSG_TYPE_GROUP_MODIFY_NOTICE) {
            if (msg.getExtra() != null) {
                chat_tips_tv.setText(msg.getExtra().toString());
            }
        }
    }

}
