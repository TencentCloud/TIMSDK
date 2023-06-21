package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget;

import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;

public abstract class ConversationBaseHolder extends RecyclerView.ViewHolder {
    protected View rootView;
    protected ConversationListAdapter mAdapter;

    public ConversationBaseHolder(View itemView) {
        super(itemView);
        rootView = itemView;
    }

    public void setAdapter(RecyclerView.Adapter adapter) {
        mAdapter = (ConversationListAdapter) adapter;
    }

    public abstract void layoutViews(ConversationInfo conversationInfo, int position);
}
