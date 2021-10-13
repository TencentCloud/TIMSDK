package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.MergeMessageElemBean;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;
import com.tencent.qcloud.tuicore.TUICore;

import java.util.List;

public class MessageForwardHolder extends MessageContentHolder{
    private LinearLayout mForwardMsgLayout;
    private TextView msgForwardTitle;
    private TextView msgForwardContent;

    public MessageForwardHolder(View itemView) {
        super(itemView);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.forward_msg_holder;
    }

    @Override
    public void initVariableViews() {
        mForwardMsgLayout = rootView.findViewById(R.id.forward_msg_layout);
        msgForwardTitle = rootView.findViewById(R.id.msg_forward_title);
        msgForwardContent = rootView.findViewById(R.id.msg_forward_content);
        mForwardMsgLayout.setClickable(true);
    }

    @Override
    public void layoutVariableViews(final MessageInfo msg, final int position) {
        if (msg == null){
            return;
        }
        mForwardMsgLayout.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                onItemLongClickListener.onMessageLongClick(v, position, msg);
                return true;
            }
        });

        mForwardMsgLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Bundle bundle = new Bundle();
                bundle.putSerializable(TUIChatConstants.FORWARD_MERGE_MESSAGE_KEY, msg);
                TUICore.startActivity("TUIForwardChatActivity", bundle);
            }
        });

        MergeMessageElemBean mergeMessageElemBean = MergeMessageElemBean.createMergeMessageElemBean(msg);
        if (mergeMessageElemBean != null){
            String title = mergeMessageElemBean.getTitle();
            List<String> abstractList= mergeMessageElemBean.getAbstractList();
            msgForwardTitle.setText(title);
            String content = "";
            for (int i = 0; i < abstractList.size(); i++) {
                content += abstractList.get(i) + "\n";
            }
            msgForwardContent.setText(content);
        }
    }

    @Override
    public void layoutViews(final MessageInfo msg, final int position) {
        super.layoutViews(msg, position);

        //// 聊天气泡设置
        if (msg.isSelf()) {
            msgContentFrame.setBackgroundResource(R.drawable.chat_right_live_group_bg);
        } else {
            msgContentFrame.setBackgroundResource(R.drawable.chat_left_live_group_bg);
        }
    }
}
