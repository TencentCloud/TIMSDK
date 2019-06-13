package com.tencent.qcloud.tim.uikit.modules.conversation.holder;

import android.graphics.Color;
import android.net.Uri;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

/**
 * 自定义会话Holder
 */
public class ConversationCustomHolder extends ConversationBaseHolder {

    protected LinearLayout leftItemLayout;
    protected TextView titleText;
    protected TextView messageText;
    protected TextView timelineText;
    protected TextView unreadText;
    protected ImageView imageView;


    public ConversationCustomHolder(View itemView) {
        super(itemView);
        leftItemLayout = rootView.findViewById(R.id.item_left);
        imageView = rootView.findViewById(R.id.conversation_icon);
        titleText = rootView.findViewById(R.id.conversation_title);
        messageText = rootView.findViewById(R.id.conversation_last_msg);
        timelineText = rootView.findViewById(R.id.conversation_time);
        unreadText = rootView.findViewById(R.id.conversation_unread);
    }

    @Override
    public void layoutViews(ConversationInfo conversation, int position) {
        MessageInfo lastMsg = conversation.getLastMessage();
        if (conversation.isTop()) {
            leftItemLayout.setBackgroundColor(rootView.getResources().getColor(R.color.top_conversation_color));
        } else {
            leftItemLayout.setBackgroundColor(Color.WHITE);
        }
        if (conversation.getIconUrl() != null) {
            GlideEngine.loadImage(imageView, Uri.parse(conversation.getIconUrl()));
        }

        titleText.setText(conversation.getTitle());
        messageText.setText("");
        timelineText.setText("");

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

    }

}
