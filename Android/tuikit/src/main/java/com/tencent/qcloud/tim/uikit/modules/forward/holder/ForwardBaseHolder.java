package com.tencent.qcloud.tim.uikit.modules.forward.holder;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.message.CustomElement;
import com.tencent.imsdk.message.FaceElement;
import com.tencent.imsdk.message.FileElement;
import com.tencent.imsdk.message.GroupTipsElement;
import com.tencent.imsdk.message.ImageElement;
import com.tencent.imsdk.message.LocationElement;
import com.tencent.imsdk.message.MergerElement;
import com.tencent.imsdk.message.SoundElement;
import com.tencent.imsdk.message.TextElement;
import com.tencent.imsdk.message.VideoElement;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageListAdapter;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageAudioHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageCustomHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageEmptyHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageFileHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageForwardHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageHeaderHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageImageHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageTextHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageTipsHolder;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.conversation.holder.ConversationBaseHolder;
import com.tencent.qcloud.tim.uikit.modules.forward.ForwardSelectListAdapter;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

public class ForwardBaseHolder extends ConversationBaseHolder {

    protected View rootView;
    protected ForwardSelectListAdapter mAdapter;

    public ForwardBaseHolder(View itemView) {
        super(itemView);
        rootView = itemView;
    }

    public void setAdapter(RecyclerView.Adapter adapter) {
        mAdapter = (ForwardSelectListAdapter) adapter;
    }

    public void layoutViews(ConversationInfo conversationInfo, int position){

    }

}
