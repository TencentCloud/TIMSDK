package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.text.Html;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;

public class TipsMessageHolder extends MessageBaseHolder {

    protected TextView mChatTipsTv;

    public TipsMessageHolder(View itemView) {
        super(itemView);
        mChatTipsTv = itemView.findViewById(R.id.chat_tips_tv);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_tips;
    }

    @Override
    public void layoutViews(TUIMessageBean msg, int position) {
        super.layoutViews(msg, position);

        if (properties.getTipsMessageBubble() != null) {
            mChatTipsTv.setBackground(properties.getTipsMessageBubble());
        }
        if (properties.getTipsMessageFontColor() != 0) {
            mChatTipsTv.setTextColor(properties.getTipsMessageFontColor());
        }
        if (properties.getTipsMessageFontSize() != 0) {
            mChatTipsTv.setTextSize(properties.getTipsMessageFontSize());
        }

        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            if (msg.isSelf()) {
                msg.setExtra(TUIChatService.getAppContext().getString(R.string.revoke_tips_you));
            } else if (msg.isGroup()) {
                String sender = TUIChatConstants.covert2HTMLString(
                        (TextUtils.isEmpty(msg.getNameCard())
                                ? msg.getSender()
                                : msg.getNameCard()));
                msg.setExtra(sender + TUIChatService.getAppContext().getString(R.string.revoke_tips));
            } else {
                msg.setExtra(TUIChatService.getAppContext().getString(R.string.revoke_tips_other));
            }
        }

        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            if (msg.getExtra() != null) {
                mChatTipsTv.setText(Html.fromHtml(msg.getExtra()));
            }
        } else if (msg instanceof TipsMessageBean) {
            mChatTipsTv.setText(Html.fromHtml( ((TipsMessageBean) msg).getText()));
        }
    }

}
