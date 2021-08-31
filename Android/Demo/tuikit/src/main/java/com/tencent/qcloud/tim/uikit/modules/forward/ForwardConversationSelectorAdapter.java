package com.tencent.qcloud.tim.uikit.modules.forward;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.gatherimage.UserIconView;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

import java.util.List;

public class ForwardConversationSelectorAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>{
    private Context context;
    private List<List<Object>> list;
    private RecyclerView mRecycleView;
    private OnItemClickListener mOnItemClickListener;

    public ForwardConversationSelectorAdapter(Context context) {
        this.context = context;
    }

    @Override
    public void onAttachedToRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        mRecycleView = (RecyclerView) recyclerView;
        //mRecycleView.setItemViewCacheSize(5);
    }

    @Override
    public ConversationViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ConversationViewHolder(LayoutInflater.from(context).inflate(R.layout.forward_conversation_selector_item, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, final int position) {
        ConversationViewHolder viewHolder = (ConversationViewHolder) holder;
        if (viewHolder != null){
            viewHolder.conversationUserIconView.setVisibility(View.VISIBLE);
            viewHolder.conversationUserIconView.setIconUrls(list.get(position));

            viewHolder.conversationUserIconView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mOnItemClickListener.onClick(v, position);
                }
            });
        }

    }

    public void setDataSource(List<List<Object>> provider) {
        if (provider == null) {
            if (list != null) {
                list.clear();
            }
        } else {
            list = provider;
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
}

class ConversationViewHolder extends RecyclerView.ViewHolder {
    public UserIconView conversationUserIconView;
    public ConversationViewHolder(View itemView) {
        super(itemView);
        conversationUserIconView = (UserIconView) itemView.findViewById(R.id.conversation_user_icon_view);
    }
}

