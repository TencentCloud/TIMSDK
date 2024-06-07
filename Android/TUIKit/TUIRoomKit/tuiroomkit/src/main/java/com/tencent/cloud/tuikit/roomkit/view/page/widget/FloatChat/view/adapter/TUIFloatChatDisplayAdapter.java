package com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.view.adapter;

import android.view.ViewGroup;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatChat.model.TUIFloatChat;

public interface TUIFloatChatDisplayAdapter {
    RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType);

    void onBindViewHolder(RecyclerView.ViewHolder holder, TUIFloatChat barrage);

    int getItemViewType(int position, TUIFloatChat barrage);
}
