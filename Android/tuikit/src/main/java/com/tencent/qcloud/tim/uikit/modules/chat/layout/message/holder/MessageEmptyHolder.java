package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.tencent.imsdk.TIMMessage;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.DateTimeUtil;

import java.util.Date;

public abstract class MessageEmptyHolder extends MessageBaseHolder {

    public TextView chatTimeText;
    public FrameLayout msgContentFrame;

    public MessageEmptyHolder(View itemView) {
        super(itemView);
        rootView = itemView;

        chatTimeText = itemView.findViewById(R.id.chat_time_tv);
        msgContentFrame = itemView.findViewById(R.id.msg_content_fl);
        initVariableLayout();
    }

    public abstract int getVariableLayout();

    private void initVariableLayout() {
        if (getVariableLayout() != 0) {
            setVariableLayout(getVariableLayout());
        }
    }

    private void setVariableLayout(int resId) {
        if (msgContentFrame.getChildCount() == 0) {
            View.inflate(rootView.getContext(), resId, msgContentFrame);
        }
        initVariableViews();
    }

    public abstract void initVariableViews();

    public void layoutViews(final MessageInfo msg, final int position) {

        //// 时间线设置
        final TIMMessage timMsg = msg.getTIMMessage();
        if (properties.getChatTimeBubble() != null) {
            chatTimeText.setBackground(properties.getChatTimeBubble());
        }
        if (properties.getChatTimeFontColor() != 0) {
            chatTimeText.setTextColor(properties.getChatTimeFontColor());
        }
        if (properties.getChatTimeFontSize() != 0) {
            chatTimeText.setTextSize(properties.getChatTimeFontSize());
        }

        if (position > 1) {
            TIMMessage last = mAdapter.getItem(position - 1).getTIMMessage();
            if (last != null) {
                if (timMsg.timestamp() - last.timestamp() >= 5 * 60) {
                    chatTimeText.setVisibility(View.VISIBLE);
                    chatTimeText.setText(DateTimeUtil.getTimeFormatText(new Date(timMsg.timestamp() * 1000)));
                } else {
                    chatTimeText.setVisibility(View.GONE);
                }
            }
        } else {
            chatTimeText.setVisibility(View.VISIBLE);
            chatTimeText.setText(DateTimeUtil.getTimeFormatText(new Date(timMsg.timestamp() * 1000)));
        }
    }

}
