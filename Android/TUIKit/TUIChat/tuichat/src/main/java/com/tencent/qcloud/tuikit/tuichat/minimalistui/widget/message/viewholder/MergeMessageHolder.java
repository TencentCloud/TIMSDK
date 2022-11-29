package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.content.Intent;
import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.page.TUIForwardChatMinimalistActivity;

import java.util.List;

public class MergeMessageHolder extends MessageContentHolder {
    private View mForwardMsgLayout;
    private TextView msgForwardTitle;
    private TextView msgForwardContent;

    public MergeMessageHolder(View itemView) {
        super(itemView);
        mForwardMsgLayout = itemView.findViewById(R.id.forward_msg_layout);
        msgForwardTitle = itemView.findViewById(R.id.msg_forward_title);
        msgForwardContent = itemView.findViewById(R.id.msg_forward_content);
        timeInLineTextLayout = itemView.findViewById(R.id.merge_msg_time_in_line_text);
        mForwardMsgLayout.setClickable(true);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.minimalist_forward_msg_holder;
    }

    @Override
    public void layoutVariableViews(final TUIMessageBean msg, final int position) {
        if (msg == null){
            return;
        }
        msgArea.setBackgroundResource(R.drawable.chat_minimalist_merge_message_border);
        if (!isForwardMode && !isMessageDetailMode) {
            if (msg.isSelf()) {
                if (properties.getRightBubble() != null && properties.getRightBubble().getConstantState() != null) {
                    msgArea.setBackground(properties.getRightBubble().getConstantState().newDrawable());
                }
            } else {
                if (properties.getLeftBubble() != null && properties.getLeftBubble().getConstantState() != null) {
                    msgArea.setBackground(properties.getLeftBubble().getConstantState().newDrawable());
                }
            }
        }

        MergeMessageBean messageBean = (MergeMessageBean) msg;
        String title = messageBean.getTitle();
        List<String> abstractList= messageBean.getAbstractList();
        msgForwardTitle.setText(title);
        String content = "";
        for (int i = 0; i < abstractList.size(); i++) {
            if (i > 0) {
                content += "\n";
            }
            content += abstractList.get(i);
        }
        content = FaceManager.emojiJudge(content);
        msgForwardContent.setText(content);

        if (isMultiSelectMode) {
            mForwardMsgLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageClick(v, position, messageBean);
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
                        onItemClickListener.onMessageLongClick(msgArea, position, msg);
                    }
                    return true;
                }
            });

            mForwardMsgLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (presenter == null || presenter.getChatInfo() == null) {
                        return;
                    }
                    Intent intent = new Intent(view.getContext(), TUIForwardChatMinimalistActivity.class);
                    intent.putExtra(TUIChatConstants.FORWARD_MERGE_MESSAGE_KEY, msg);
                    intent.putExtra(TUIChatConstants.CHAT_INFO, presenter.getChatInfo());
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    view.getContext().startActivity(intent);
                }
            });
        }
        setMessageAreaPadding();
    }

}
