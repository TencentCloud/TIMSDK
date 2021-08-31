package com.tencent.qcloud.tim.uikit.modules.forward;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;

import java.util.List;

class ForwardContactSelectorAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>{
    private Context context;
    private List<String> list;
    private RecyclerView mRecycleView;

    public ForwardContactSelectorAdapter(Context context) {
        this.context = context;
    }

    @Override
    public void onAttachedToRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        mRecycleView = (RecyclerView) recyclerView;
        //mRecycleView.setItemViewCacheSize(5);
    }

    @Override
    public ContactViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ContactViewHolder(LayoutInflater.from(context).inflate(R.layout.forward_contact_selector_item, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        ContactViewHolder viewHolder = (ContactViewHolder) holder;
        if (viewHolder != null){
            if (!TextUtils.isEmpty(list.get(position))) {
                GlideEngine.loadImage(viewHolder.userIconView, list.get(position), null);
            }
        }

    }

    public void setDataSource(List<String> provider) {
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
}

class ContactViewHolder extends RecyclerView.ViewHolder {
    public ImageView userIconView;
    public ContactViewHolder(View itemView) {
        super(itemView);
        userIconView = (ImageView) itemView.findViewById(R.id.ivAvatar);
    }
}
