package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.FaceUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;

import java.util.List;

public class MergeMessageHolder extends MessageContentHolder {
    private View mForwardMsgLayout;
    private TextView msgForwardTitle;
    private LinearLayout firstLine;
    private LinearLayout secondLine;
    private LinearLayout thirdLine;

    public MergeMessageHolder(View itemView) {
        super(itemView);
        mForwardMsgLayout = itemView.findViewById(R.id.forward_msg_layout);
        msgForwardTitle = itemView.findViewById(R.id.msg_forward_title);
        firstLine = itemView.findViewById(R.id.first_line);
        secondLine = itemView.findViewById(R.id.second_line);
        thirdLine = itemView.findViewById(R.id.third_line);
        timeInLineTextLayout = itemView.findViewById(R.id.merge_msg_time_in_line_text);
        mForwardMsgLayout.setClickable(true);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.minimalist_forward_msg_holder;
    }

    @Override
    public void layoutVariableViews(final TUIMessageBean msg, final int position) {
        if (msg == null) {
            return;
        }
        setMessageBubbleBackground(R.drawable.chat_minimalist_merge_message_border);
        if (!isForwardMode && !isMessageDetailMode) {
            if (msg.isSelf()) {
                if (properties.getRightBubble() != null && properties.getRightBubble().getConstantState() != null) {
                    setMessageBubbleBackground(properties.getRightBubble().getConstantState().newDrawable());
                }
            } else {
                if (properties.getLeftBubble() != null && properties.getLeftBubble().getConstantState() != null) {
                    setMessageBubbleBackground(properties.getLeftBubble().getConstantState().newDrawable());
                }
            }
        }

        MergeMessageBean messageBean = (MergeMessageBean) msg;
        String title = messageBean.getTitle();
        List<String> abstractList = messageBean.getAbstractList();
        msgForwardTitle.setText(title);
        setContent(abstractList);
        if (isMultiSelectMode) {
            mForwardMsgLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageClick(v, messageBean);
                    }
                }
            });
            return;
        }
        if (!isMessageDetailMode) {
            mForwardMsgLayout.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageLongClick(msgArea, msg);
                    }
                    return true;
                }
            });
        }
        mForwardMsgLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (onItemClickListener != null) {
                    onItemClickListener.onMessageClick(msgArea, msg);
                }
            }
        });
        setMessageBubbleDefaultPadding();
    }

    void setContent(List<String> abstractList) {
        firstLine.setVisibility(View.GONE);
        secondLine.setVisibility(View.GONE);
        thirdLine.setVisibility(View.GONE);
        if (abstractList == null || abstractList.isEmpty()) {
            return;
        }
        final String splitStr = "\u202C:";
        for (int i = 0; i < abstractList.size(); i++) {
            TextView senderTv;
            TextView contentTv;
            TextView splitTv;
            if (i == 0) {
                senderTv = firstLine.findViewById(R.id.sender_name_tv);
                contentTv = firstLine.findViewById(R.id.content_tv);
                splitTv = firstLine.findViewById(R.id.split_tv);
                firstLine.setVisibility(View.VISIBLE);
            } else if (i == 1) {
                senderTv = secondLine.findViewById(R.id.sender_name_tv);
                contentTv = secondLine.findViewById(R.id.content_tv);
                splitTv = secondLine.findViewById(R.id.split_tv);
                secondLine.setVisibility(View.VISIBLE);
            } else if (i == 2) {
                senderTv = thirdLine.findViewById(R.id.sender_name_tv);
                contentTv = thirdLine.findViewById(R.id.content_tv);
                splitTv = thirdLine.findViewById(R.id.split_tv);
                thirdLine.setVisibility(View.VISIBLE);
            } else {
                return;
            }
            String absString = abstractList.get(i);
            if (absString.contains(splitStr)) {
                String sender = "";
                String content = "";
                if (absString.contains(splitStr)) {
                    String[] strings = absString.split(splitStr);
                    if (strings.length >= 1) {
                        sender = strings[0];
                    }
                    if (strings.length >= 2) {
                        content = strings[1];
                    }
                }
                senderTv.setVisibility(View.VISIBLE);
                senderTv.setText(sender);
                splitTv.setVisibility(View.VISIBLE);
                contentTv.setText(FaceManager.emojiJudge(content));
            } else {
                senderTv.setVisibility(View.GONE);
                contentTv.setText(FaceManager.emojiJudge(absString));
                splitTv.setVisibility(View.GONE);
            }
        }
    }

    @Override
    protected boolean isNeedChangedBackground() {
        return false;
    }
}
