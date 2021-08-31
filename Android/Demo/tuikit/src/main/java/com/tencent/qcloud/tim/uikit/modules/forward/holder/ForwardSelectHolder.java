package com.tencent.qcloud.tim.uikit.modules.forward.holder;

import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.TUIKitImpl;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.conversation.holder.ConversationBaseHolder;

public class ForwardSelectHolder extends ForwardBaseHolder {
    private TextView titleView;
    public ForwardSelectHolder(View itemView) {
        super(itemView);
        titleView = itemView.findViewById(R.id.forward_title);
    }

    @Override
    public void layoutViews(ConversationInfo conversationInfo, int position) {

    }

    public void refreshTitile(boolean isCreateGroup){
        if (titleView == null)return;

        if (isCreateGroup){
            titleView.setText(TUIKit.getAppContext().getString(R.string.forward_select_new_chat));
        } else {
            titleView.setText(TUIKit.getAppContext().getString(R.string.forward_select_from_contact));
        }
    }
}
