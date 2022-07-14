package com.tencent.qcloud.tuikit.tuiconversation.interfaces;

import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;

import java.util.List;

/**
 * 其他模块与 Conversation 模块的通信接口
 */
public interface ConversationEventListener {
    void deleteConversation(String chatId, boolean isGroup);
    void clearConversationMessage(String chatId, boolean isGroup);
    void deleteConversation(String conversationId);
    void setConversationTop(String chatId, boolean isChecked, IUIKitCallback<Void> iuiKitCallBack);
    boolean isTopConversation(String chatId);
    long getUnreadTotal();
    void updateTotalUnreadMessageCount(long count);
    void onNewConversation(List<ConversationInfo> conversationList);
    void onConversationChanged(List<ConversationInfo> conversationList);
    void onFriendRemarkChanged(String id, String remark);
    void onUserStatusChanged(List<V2TIMUserStatus> userStatusList);
    void refreshUserStatusFragmentUI();
}
