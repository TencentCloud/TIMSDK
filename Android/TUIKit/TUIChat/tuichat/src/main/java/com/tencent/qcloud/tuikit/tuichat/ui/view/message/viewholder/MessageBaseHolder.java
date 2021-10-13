package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.tuichat.R;

import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageProperties;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.ICommonMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.OnItemLongClickListener;

public abstract class MessageBaseHolder extends RecyclerView.ViewHolder {
    public static final int MSG_TYPE_HEADER_VIEW = -99;

    public ICommonMessageAdapter mAdapter;
    public MessageProperties properties = MessageProperties.getInstance();
    protected View rootView;
    protected OnItemLongClickListener onItemLongClickListener;

    public MessageBaseHolder(View itemView) {
        super(itemView);

        rootView = itemView;
    }

    public void setAdapter(ICommonMessageAdapter adapter) {
        mAdapter = adapter;
    }

    public void setOnItemClickListener(OnItemLongClickListener listener) {
        this.onItemLongClickListener = listener;
    }

    public OnItemLongClickListener getOnItemClickListener() {
        return this.onItemLongClickListener;
    }

    public abstract void layoutViews(final MessageInfo msg, final int position);

    public static class Factory {

        public static RecyclerView.ViewHolder getInstance(ViewGroup parent, ICommonMessageAdapter adapter, int viewType) {

            LayoutInflater inflater = LayoutInflater.from(TUIChatService.getAppContext());
            RecyclerView.ViewHolder holder = null;
            View view = null;

            // 头部的holder
            if (viewType == MSG_TYPE_HEADER_VIEW) {
                view = inflater.inflate(R.layout.loading_progress_bar, parent, false);
                holder = new MessageHeaderHolder(view);
                return holder;
            }

            // 加群消息等holder
            if (viewType >= MessageInfo.MSG_TYPE_TIPS && viewType <= MessageInfo.MSG_STATUS_REVOKE) {
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
                case MessageInfo.MSG_TYPE_MERGE:
                    holder = new MessageForwardHolder(view);
                    break;
                case MessageInfo.MSG_TYPE_CUSTOM:
                    holder = new MessageCustomHolder(view);
                    break;
                default: {
                    break;
                }
            }
            if (holder == null) {
                holder = new MessageTextHolder(view);
            }
            ((MessageEmptyHolder) holder).setAdapter(adapter);

            return holder;
        }
    }
}
