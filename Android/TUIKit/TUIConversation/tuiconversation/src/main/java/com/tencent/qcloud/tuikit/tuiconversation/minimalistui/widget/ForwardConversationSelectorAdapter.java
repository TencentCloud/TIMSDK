package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;

import java.util.List;

public class ForwardConversationSelectorAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>{
    private Context context;
    private List<ConversationInfo> list;
    private OnItemClickListener mOnItemClickListener;

    public ForwardConversationSelectorAdapter(Context context) {
        this.context = context;
    }

    @Override
    public void onAttachedToRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
    }

    @NonNull
    @Override
    public ConversationViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ConversationViewHolder(LayoutInflater.from(context).inflate(R.layout.minimalist_forward_conversation_selector_item, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, final int position) {
        ConversationViewHolder viewHolder = (ConversationViewHolder) holder;
        viewHolder.conversationUserIconView.setVisibility(View.VISIBLE);
        viewHolder.conversationUserIconView.setConversation(list.get(position));

        viewHolder.conversationUserIconView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mOnItemClickListener.onClick(v, position);
            }
        });

    }

    public void setDataSource(List<ConversationInfo> dataSource) {
        if (dataSource == null) {
            if (list != null) {
                list.clear();
            }
        } else {
            list = dataSource;
        }

        notifyDataSetChanged();
    }

    @Override
    public int getItemCount() {
        return list == null ? 0 : list.size();
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.mOnItemClickListener = listener;
    }

    public interface OnItemClickListener {
        void onClick(View view, int position);
    }

    static class ConversationViewHolder extends RecyclerView.ViewHolder {
        public ConversationIconView conversationUserIconView;
        public ConversationViewHolder(View itemView) {
            super(itemView);
            conversationUserIconView = itemView.findViewById(R.id.conversation_user_icon_view);
        }
    }
}


