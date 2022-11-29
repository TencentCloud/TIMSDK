package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces;

import android.view.View;

import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;

import java.util.List;

public interface OnConversationAdapterListener {
    void onItemClick(View view, int viewType, ConversationInfo conversationInfo);
    void OnItemLongClick(View view, ConversationInfo conversationInfo);
    void onConversationChanged(List<ConversationInfo> dataSource);
    void onMarkConversationUnread(View view, ConversationInfo conversationInfo, boolean markUnread);
    void onMarkConversationHidden(View view, ConversationInfo conversationInfo);
    void onClickMoreView(View view, ConversationInfo conversationInfo);
    void onSwipeConversationChanged(ConversationInfo conversationInfo);
}
