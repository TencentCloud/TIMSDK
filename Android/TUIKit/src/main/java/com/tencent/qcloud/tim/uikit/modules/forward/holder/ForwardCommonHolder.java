package com.tencent.qcloud.tim.uikit.modules.forward.holder;

import android.view.View;
import android.widget.CheckBox;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationIconView;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;

public class ForwardCommonHolder extends ForwardBaseHolder {

    public ConversationIconView conversationIconView;
    protected LinearLayout leftItemLayout;
    protected TextView titleText;
    protected TextView messageText;
    protected TextView timelineText;
    protected TextView unreadText;
    protected TextView atInfoText;
    protected CheckBox mMutiSelectCheckBox;

    public ForwardCommonHolder(View itemView) {
        super(itemView);
        leftItemLayout = rootView.findViewById(R.id.item_left);
        conversationIconView = rootView.findViewById(R.id.conversation_icon);
        titleText = rootView.findViewById(R.id.conversation_title);
        messageText = rootView.findViewById(R.id.conversation_last_msg);
        timelineText = rootView.findViewById(R.id.conversation_time);
        unreadText = rootView.findViewById(R.id.conversation_unread);
        atInfoText = rootView.findViewById(R.id.conversation_at_msg);
        mMutiSelectCheckBox = rootView.findViewById(R.id.select_checkbox);
    }

    public void layoutViews(ConversationInfo conversation, int position) {
        super.layoutViews(conversation, position);

        titleText.setText(conversation.getTitle());
        messageText.setText("");
        timelineText.setText("");

        conversationIconView.setRadius(mAdapter.getItemAvatarRadius());

        if (mAdapter.getItemTopTextSize() != 0) {
            titleText.setTextSize(mAdapter.getItemTopTextSize());
        }

        if (conversation.getIconUrlList() != null) {
            conversationIconView.setConversation(conversation);
        }

        if (!mAdapter.hasItemUnreadDot()) {
            unreadText.setVisibility(View.GONE);
        }

        if (!mAdapter.isAtInfoTextShow()){
            atInfoText.setVisibility(View.GONE);
        }

        if (!mAdapter.isMessageTextShow()){
            messageText.setVisibility(View.GONE);
        }

        if (!mAdapter.isTimelineTextShow()){
            timelineText.setVisibility(View.GONE);
        }

        if (!mAdapter.isUnreadTextShow()){
            unreadText.setVisibility(View.GONE);
        }

        conversationIconView.setConversation(conversation);

        //// 由子类设置指定消息类型的views
        layoutVariableViews(conversation, position);
    }

    public void layoutVariableViews(ConversationInfo conversationInfo, int position) {

    }

    public CheckBox getMutiSelectCheckBox() {
        return mMutiSelectCheckBox;
    }
}
