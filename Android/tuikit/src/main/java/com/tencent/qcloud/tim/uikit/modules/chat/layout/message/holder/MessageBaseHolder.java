package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayoutUI;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageListAdapter;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

public abstract class MessageBaseHolder extends RecyclerView.ViewHolder {

    protected View rootView;

    public MessageListAdapter mAdapter;
    protected MessageLayout.OnItemClickListener onItemClickListener;
    public MessageLayoutUI.Properties properties = MessageLayout.Properties.getInstance();

    public MessageBaseHolder(View itemView) {
        super(itemView);

        rootView = itemView;
    }

    public void setAdapter(RecyclerView.Adapter adapter) {
        mAdapter = (MessageListAdapter) adapter;
    }

    public void setOnItemClickListener(MessageLayout.OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }

    public abstract void layoutViews(final MessageInfo msg, final int position);

    public static class Factory {

        public static RecyclerView.ViewHolder getInstance(ViewGroup parent, RecyclerView.Adapter adapter, int viewType) {

            LayoutInflater inflater = LayoutInflater.from(TUIKit.getAppContext());
            RecyclerView.ViewHolder holder = null;
            View view = null;

            // 头部的holder
            if (viewType == MessageListAdapter.MSG_TYPE_HEADER_VIEW) {
                view = inflater.inflate(R.layout.message_adapter_content_header, parent, false);
                holder = new MessageHeaderHolder(view);
                return holder;
            }

            // 加群消息等holder
            if (viewType >= MessageInfo.MSG_TYPE_TIPS) {
                view = inflater.inflate(R.layout.message_adapter_item_empty, parent, false);
                holder = new MessageTipsHolder(view);
            }

            // 具体消息holder
            view = inflater.inflate(R.layout.message_adapter_item_content, parent, false);
            switch (viewType) {
                case MessageInfo.MSG_TYPE_TEXT:
                    holder = new MessageTextHolder(view);
                    break;
                case MessageInfo.MSG_TYPE_IMAGE:
                case MessageInfo.MSG_TYPE_VIDEO:
                case MessageInfo.MSG_TYPE_CUSTOM_FACE:
                    holder = new MessageImageHolder(view);
                    break;
                case MessageInfo.MSG_TYPE_AUDIO:
                    holder = new MessageAudioHolder(view);
                    break;
                case MessageInfo.MSG_TYPE_FILE:
                    holder = new MessageFileHolder(view);
                    break;
                case MessageInfo.MSG_TYPE_CUSTOM:
                    holder = new MessageCustomHolder(view);
                    break;
            }
            if (holder != null) {
                ((MessageEmptyHolder) holder).setAdapter(adapter);
            }

            return holder;
        }
    }
}
