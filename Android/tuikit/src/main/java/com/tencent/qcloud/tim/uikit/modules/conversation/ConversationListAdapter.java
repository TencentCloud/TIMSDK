package com.tencent.qcloud.tim.uikit.modules.conversation;

import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageContentHolder;
import com.tencent.qcloud.tim.uikit.modules.conversation.interfaces.IConversationAdapter;
import com.tencent.qcloud.tim.uikit.modules.conversation.interfaces.IConversationProvider;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.conversation.holder.ConversationBaseHolder;
import com.tencent.qcloud.tim.uikit.modules.conversation.holder.ConversationCommonHolder;
import com.tencent.qcloud.tim.uikit.modules.conversation.holder.ConversationCustomHolder;

import java.util.ArrayList;

import java.util.List;

public class ConversationListAdapter extends IConversationAdapter {

    private List<ConversationInfo> mDataSource = new ArrayList<>();
    private ConversationListLayout.OnItemClickListener mOnItemClickListener;
    private ConversationListLayout.OnItemLongClickListener mOnItemLongClickListener;
    public boolean mIsShowUnreadDot = true;
    public boolean mIsShowItemRoundIcon = false;
    public int mTopTextSize;
    public int mBottomTextSize;
    public int mDateTextSize;

    public void setOnItemClickListener(ConversationListLayout.OnItemClickListener listener) {
        this.mOnItemClickListener = listener;
    }

    public void setOnItemLongClickListener(ConversationListLayout.OnItemLongClickListener listener) {
        this.mOnItemLongClickListener = listener;
    }

    public ConversationListAdapter() {

    }

    public void setDataProvider(IConversationProvider provider) {
        mDataSource = provider.getDataSource();
        if (provider instanceof ConversationProvider) {
            provider.attachAdapter(this);
        }
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(TUIKit.getAppContext());
        RecyclerView.ViewHolder holder = null;
        // 创建不同的 ViewHolder
        View view;
        // 根据ViewType来创建条目
        if (viewType == ConversationInfo.TYPE_CUSTOM) {
            view = inflater.inflate(R.layout.conversation_custom_adapter, parent, false);
            holder = new ConversationCustomHolder(view);
        } else {
            view = inflater.inflate(R.layout.conversation_adapter, parent, false);
            holder = new ConversationCommonHolder(view);
        }
        if (holder != null) {
            ((ConversationBaseHolder) holder).setAdapter(this);
        }
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, final int position) {
        final ConversationInfo conversationInfo = getItem(position);
        ConversationBaseHolder baseHolder = (ConversationBaseHolder) holder;

        switch (getItemViewType(position)) {
            case ConversationInfo.TYPE_CUSTOM:
                break;
            default:
                //设置点击和长按事件
                if (mOnItemClickListener != null) {
                    holder.itemView.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            mOnItemClickListener.onItemClick(view, position, conversationInfo);
                        }
                    });
                }
                if (mOnItemLongClickListener != null) {
                    holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                        @Override
                        public boolean onLongClick(View view) {
                            mOnItemLongClickListener.OnItemLongClick(view, position, conversationInfo);
                            return true;
                        }
                    });
                }
                break;
        }
        baseHolder.layoutViews(conversationInfo, position);
    }

    @Override
    public void onViewRecycled(@NonNull RecyclerView.ViewHolder holder) {
        if (holder instanceof ConversationCommonHolder) {
            ((ConversationCommonHolder)holder).conversationIconView.setBackground(null);
        }
    }

    public ConversationInfo getItem(int position) {
        if (mDataSource.size() == 0)
            return null;
        return mDataSource.get(position);
    }

    @Override
    public int getItemCount() {
        return mDataSource.size();
    }

    @Override
    public int getItemViewType(int position) {
        if (mDataSource != null) {
            ConversationInfo conversation = mDataSource.get(position);
            return conversation.getType();
        }
        return 1;
    }

    public void addItem(int position, ConversationInfo info) {
        mDataSource.add(position, info);
        notifyItemInserted(position);
        notifyDataSetChanged();
    }

    public void removeItem(int position) {
        mDataSource.remove(position);
        notifyItemRemoved(position);
        notifyDataSetChanged();
    }

    public void setItemTopTextSize(int size) {
        mTopTextSize = size;
    }

    public void setItemBottomTextSize(int size) {
        mBottomTextSize = size;
    }

    public void setItemDateTextSize(int size) {
        mDateTextSize = size;
    }

    public void enableItemRoundIcon(boolean flag) {
        mIsShowItemRoundIcon = flag;
    }

    public void disableItemUnreadDot(boolean flag) {
        mIsShowUnreadDot = !flag;
    }


}
