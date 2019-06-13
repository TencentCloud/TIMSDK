package com.tencent.qcloud.tim.uikit.modules.conversation.holder;

import android.graphics.Color;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationIconView;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.DateTimeUtil;

import java.util.Date;

public class ConversationCommonHolder extends ConversationBaseHolder {

    protected LinearLayout leftItemLayout;
    protected TextView titleText;
    protected TextView messageText;
    protected TextView timelineText;
    protected TextView unreadText;
    protected ConversationIconView conversationIconView;

    public ConversationCommonHolder(View itemView) {
        super(itemView);
        leftItemLayout = rootView.findViewById(R.id.item_left);
        conversationIconView = rootView.findViewById(R.id.conversation_icon);
        titleText = rootView.findViewById(R.id.conversation_title);
        messageText = rootView.findViewById(R.id.conversation_last_msg);
        timelineText = rootView.findViewById(R.id.conversation_time);
        unreadText = rootView.findViewById(R.id.conversation_unread);
    }

    public void layoutViews(ConversationInfo conversation, int position) {
        MessageInfo lastMsg = conversation.getLastMessage();
        if (conversation.isTop()) {
            leftItemLayout.setBackgroundColor(rootView.getResources().getColor(R.color.top_conversation_color));
        } else {
            leftItemLayout.setBackgroundColor(Color.WHITE);
        }
        conversationIconView.setIconUrls(null); // 如果自己要设置url，这行代码需要删除
        if (conversation.isGroup()) {
            if (mAdapter.mIsShowItemRoundIcon) {
                conversationIconView.setBitmapResId(R.drawable.conversation_group);
            } else {
                conversationIconView.setDefaultImageResId(R.drawable.conversation_group);
            }
        } else {
            if (mAdapter.mIsShowItemRoundIcon) {
                conversationIconView.setBitmapResId(R.drawable.conversation_c2c);
            } else {
                conversationIconView.setDefaultImageResId(R.drawable.conversation_c2c);
            }
        }

        titleText.setText(conversation.getTitle());
        messageText.setText("");
        timelineText.setText("");
        if (lastMsg != null) {
            if (lastMsg.getStatus() == MessageInfo.MSG_STATUS_REVOKE) {
                if (lastMsg.isSelf())
                    messageText.setText("您撤回了一条消息");
                else if (lastMsg.isGroup()) {
                    messageText.setText(lastMsg.getFromUser() + "撤回了一条消息");
                } else {
                    messageText.setText("对方撤回了一条消息");
                }

            } else {
                if (lastMsg.getExtra() != null)
                    messageText.setText(lastMsg.getExtra().toString());
            }

            timelineText.setText(DateTimeUtil.getTimeFormatText(new Date(lastMsg.getMsgTime())));
        }


        if (conversation.getUnRead() > 0) {
            unreadText.setVisibility(View.VISIBLE);
            unreadText.setText("" + conversation.getUnRead());
        } else {
            unreadText.setVisibility(View.GONE);
        }

        if (mAdapter.mDateTextSize != 0) {
            timelineText.setTextSize(mAdapter.mDateTextSize);
        }
        if (mAdapter.mBottomTextSize != 0) {
            messageText.setTextSize(mAdapter.mBottomTextSize);
        }
        if (mAdapter.mTopTextSize != 0) {
            titleText.setTextSize(mAdapter.mTopTextSize);
        }
//        if (mIsShowUnreadDot) {
//            holder.unreadText.setVisibility(View.GONE);
//        }

        //// 由子类设置指定消息类型的views
        layoutVariableViews(conversation, position);
    }

    public void layoutVariableViews(ConversationInfo conversationInfo, int position) {

    }
}
