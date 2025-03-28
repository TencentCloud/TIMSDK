package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.util.Pair;
import android.view.View;
import android.widget.TextView;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.timcommon.TIMCommonService;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageBaseHolder;
import com.tencent.qcloud.tuikit.timcommon.util.TextUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TipsMessageBean;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.FriendProfileActivity;
import com.tencent.qcloud.tuikit.tuichat.config.classicui.TUIChatConfigClassic;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import java.util.Map;

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
        Drawable systemMessageBackground = TUIChatConfigClassic.getSystemMessageBackground();
        if (systemMessageBackground != null) {
            mChatTipsTv.setBackground(systemMessageBackground);
        }
        int systemMessageTextFontColor = TUIChatConfigClassic.getSystemMessageTextColor();
        if (systemMessageTextFontColor != TUIChatConfigClassic.UNDEFINED) {
            mChatTipsTv.setTextColor(systemMessageTextFontColor);
        }
        int systemMessageTextFontSize = TUIChatConfigClassic.getSystemMessageFontSize();
        if (systemMessageTextFontSize != TUIChatConfigClassic.UNDEFINED) {
            mChatTipsTv.setTextSize(systemMessageTextFontSize);
            mReEditText.setTextSize(systemMessageTextFontSize);
        }

        mReEditText.setVisibility(View.GONE);
        mReEditText.setOnClickListener(null);

        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            handleRevoke(msg);
        }

        if (msg instanceof TipsMessageBean) {
            setTips((TipsMessageBean) msg);
        }

        mChatTipsTv.setMovementMethod(LinkMovementMethod.getInstance());
    }

    private void setTips(TipsMessageBean msg) {
        Map<String, String> targetUserNameMap = msg.getTargetUserMap();
        Pair<String, String> operationUserPair = msg.getOperationUserPair();
        String text = msg.getText();
        SpannableStringBuilder builder = new SpannableStringBuilder(msg.getText());
        int color = TIMCommonService.getAppContext().getResources().getColor(com.tencent.qcloud.tuikit.timcommon.R.color.common_quote_user_name_color);
        if (!targetUserNameMap.isEmpty()) {
            for (Map.Entry<String, String> entry : targetUserNameMap.entrySet()) {
                int start = text.indexOf(entry.getValue());
                if (start != -1) {
                    int end = start + entry.getValue().length();
                    TextUtil.ForegroundColorClickableSpan span = new TextUtil.ForegroundColorClickableSpan(color, new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            onUserClick(entry.getKey());
                        }
                    });
                    builder.setSpan(span, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                }
            }
        }
        if (operationUserPair != null) {
            int start = text.indexOf(operationUserPair.second);
            if (start != -1) {
                int end = start + operationUserPair.second.length();
                TextUtil.ForegroundColorClickableSpan span = new TextUtil.ForegroundColorClickableSpan(color, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        onUserClick(operationUserPair.first);
                    }
                });
                builder.setSpan(span, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            }
        }
        mChatTipsTv.setText(builder);
    }

    private void handleRevoke(TUIMessageBean msg) {
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
        Pair<UserBean, String> displayStringPair = ChatMessageParser.getRevokeMessageDisplayString(msg);
        if (displayStringPair != null) {
            UserBean operator = displayStringPair.first;
            String showString = displayStringPair.second;
            if (operator != null && !TextUtils.isEmpty(operator.getDisplayName())) {
                int color = TIMCommonService.getAppContext().getResources().getColor(com.tencent.qcloud.tuikit.timcommon.R.color.common_quote_user_name_color);
                SpannableStringBuilder builder = new SpannableStringBuilder(showString);
                int start = showString.indexOf(operator.getDisplayName());
                if (start != -1) {
                    int end = start + operator.getDisplayName().length();
                    TextUtil.ForegroundColorClickableSpan span = new TextUtil.ForegroundColorClickableSpan(color, new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            onUserClick(operator.getUserId());
                        }
                    });
                    builder.setSpan(span, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                }
                mChatTipsTv.setText(builder);
            }
        }
    }

    private void onUserClick(String userID) {
        Intent intent = new Intent(itemView.getContext(), FriendProfileActivity.class);
        intent.putExtra(TUIConstants.TUIChat.CHAT_ID, userID);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        itemView.getContext().startActivity(intent);
    }
}
