package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;

import java.util.List;

public class MergeMessageHolder extends MessageContentHolder{
    private LinearLayout mForwardMsgLayout;
    private TextView msgForwardTitle;
    private TextView msgForwardContent;

    public MergeMessageHolder(View itemView) {
        super(itemView);
        mForwardMsgLayout = itemView.findViewById(R.id.forward_msg_layout);
        msgForwardTitle = itemView.findViewById(R.id.msg_forward_title);
        msgForwardContent = itemView.findViewById(R.id.msg_forward_content);
        mForwardMsgLayout.setClickable(true);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.forward_msg_holder;
    }

    @Override
    public void layoutVariableViews(final TUIMessageBean msg, final int position) {
        if (msg == null){
            return;
        }
        reactView.setThemeColorId(TUIThemeManager.getAttrResId(reactView.getContext(), R.attr.chat_react_other_text_color));
        if (isForwardMode || isReplyDetailMode) {
            msgArea.setBackgroundResource(R.drawable.chat_bubble_other_cavity_bg);
            statusImage.setVisibility(View.GONE);
        } else {
            //// 聊天气泡设置
            if (msg.isSelf()) {
                if (properties.getRightBubble() != null && properties.getRightBubble().getConstantState() != null) {
                    msgArea.setBackground(properties.getRightBubble().getConstantState().newDrawable());
                } else {
                    msgArea.setBackgroundResource(R.drawable.chat_bubble_self_cavity_bg);
                }
            } else {
                if (properties.getLeftBubble() != null && properties.getLeftBubble().getConstantState() != null) {
                    msgArea.setBackground(properties.getLeftBubble().getConstantState().newDrawable());
                } else {
                    msgArea.setBackgroundResource(R.drawable.chat_bubble_other_cavity_bg);
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
        mForwardMsgLayout.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if (onItemClickListener != null) {
                    onItemClickListener.onMessageLongClick(v, position, msg);
                }
                return true;
            }
        });

        mForwardMsgLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Bundle bundle = new Bundle();
                bundle.putSerializable(TUIChatConstants.FORWARD_MERGE_MESSAGE_KEY, msg);
                bundle.putSerializable(TUIChatConstants.CHAT_INFO, presenter.getChatInfo());
                TUICore.startActivity("TUIForwardChatActivity", bundle);
            }
        });
        
        setMessageAreaPadding();
    }

}
