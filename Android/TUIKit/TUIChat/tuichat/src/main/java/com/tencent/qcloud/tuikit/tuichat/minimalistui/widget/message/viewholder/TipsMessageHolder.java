package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.graphics.drawable.Drawable;
import android.text.Html;
import android.view.View;
import android.widget.TextView;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageBaseHolder;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.minimalistui.TUIChatConfigMinimalist;

public class TipsMessageHolder extends MessageBaseHolder {
    protected TextView mChatTipsTv;
    protected TextView mReEditText;

    public TipsMessageHolder(View itemView) {
        super(itemView);
        mChatTipsTv = itemView.findViewById(R.id.chat_tips_tv);
        mReEditText = itemView.findViewById(R.id.re_edit);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_tips;
    }

    @Override
    public void layoutViews(TUIMessageBean msg, int position) {
        super.layoutViews(msg, position);

        Drawable systemMessageBackground = TUIChatConfigMinimalist.getSystemMessageBackground();
        if (systemMessageBackground != null) {
            mChatTipsTv.setBackground(systemMessageBackground);
        }
        int systemMessageTextFontColor = TUIChatConfigMinimalist.getSystemMessageTextColor();
        if (systemMessageTextFontColor != TUIChatConfigMinimalist.UNDEFINED) {
            mChatTipsTv.setTextColor(systemMessageTextFontColor);
        }
        int systemMessageTextFontSize = TUIChatConfigMinimalist.getSystemMessageFontSize();
        if (systemMessageTextFontSize != TUIChatConfigMinimalist.UNDEFINED) {
            mChatTipsTv.setTextSize(systemMessageTextFontSize);
            mReEditText.setTextSize(systemMessageTextFontSize);
        }

        mReEditText.setVisibility(View.GONE);
        mReEditText.setOnClickListener(null);

        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            handleRevoke(msg);
        }

        if (msg instanceof TipsMessageBean) {
            mChatTipsTv.setText(Html.fromHtml(((TipsMessageBean) msg).getText()));
        }
    }

    private void handleRevoke(TUIMessageBean msg) {
        String showString = itemView.getResources().getString(R.string.revoke_tips_other);
        if (msg.isSelf()) {
            int msgType = msg.getMsgType();
            if (msgType == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
                long nowtime = V2TIMManager.getInstance().getServerTime();
                long msgtime = msg.getMessageTime();
                if ((int) (nowtime - msgtime) < 2 * 60) {
                    mReEditText.setVisibility(View.VISIBLE);
                    mReEditText.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            onItemClickListener.onReEditRevokeMessage(view, msg);
                        }
                    });
                } else {
                    mReEditText.setVisibility(View.GONE);
                }
            }
            showString = itemView.getResources().getString(R.string.revoke_tips_you);
        } else if (msg.isGroup()) {
            String sender = TUIChatConstants.covert2HTMLString(msg.getUserDisplayName());
            showString = sender + itemView.getResources().getString(R.string.revoke_tips);
            mReEditText.setVisibility(View.GONE);
            mReEditText.setOnClickListener(null);
        }
        mChatTipsTv.setText(Html.fromHtml(showString));
    }

    @Override
    protected boolean isShowAvatar(TUIMessageBean messageBean) {
        return messageBean instanceof TipsMessageBean;
    }
}
