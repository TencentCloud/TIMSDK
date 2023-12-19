package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.text.Html;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageBaseHolder;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;

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

        if (properties.getTipsMessageBubble() != null) {
            mChatTipsTv.setBackground(properties.getTipsMessageBubble());
        }
        if (properties.getTipsMessageFontColor() != 0) {
            mChatTipsTv.setTextColor(properties.getTipsMessageFontColor());
        }
        if (properties.getTipsMessageFontSize() != 0) {
            mChatTipsTv.setTextSize(properties.getTipsMessageFontSize());
        }

        mReEditText.setVisibility(View.GONE);
        mReEditText.setOnClickListener(null);

        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            handleRevoke(msg, position);
        }

        if (msg instanceof TipsMessageBean) {
            mChatTipsTv.setText(Html.fromHtml(((TipsMessageBean) msg).getText()));
        }
    }

    private void handleRevoke(TUIMessageBean msg, int position) {
        String showString = ChatMessageParser.getRevokeMessageDisplayString(msg);
        UserBean revoker = msg.getRevoker();
        if (msg.isSelf()) {
            int msgType = msg.getMsgType();
            if (revoker != null && TextUtils.equals(revoker.getUserId(), TUILogin.getLoginUser())) {
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
                    }
                }
            }
        }

        mChatTipsTv.setText(Html.fromHtml(showString));
    }
}
