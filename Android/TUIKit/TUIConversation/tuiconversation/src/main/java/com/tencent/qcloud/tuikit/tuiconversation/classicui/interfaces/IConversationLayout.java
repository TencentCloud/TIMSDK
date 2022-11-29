package com.tencent.qcloud.tuikit.tuiconversation.classicui.interfaces;

import android.view.View;

import com.tencent.qcloud.tuicore.component.interfaces.ILayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;

public interface IConversationLayout extends ILayout {
    View getConversationList();
    void setConversationTop(ConversationInfo conversation, IUIKitCallback callBack);
    void deleteConversation(ConversationInfo conversation);
    void clearConversationMessage(ConversationInfo conversation);

    /**
     * 隐藏普通会话
     * Hide normal conversation
     */
    void markConversationHidden(ConversationInfo conversation);

    /**
     * 标记会话已读/未读
     * Mark conversation read or unread
     */
    void markConversationUnread(ConversationInfo conversationInfo, boolean markUnread);

    /**
     * 隐藏整个折叠的会话 item
     * Hide folded conversation item
     */
    void hideFoldedItem(boolean needHide);

    /**
     * 清除折叠 item 本地未读状态
     * Clear unread status of fold item
     */
    void clearUnreadStatusOfFoldItem();
}
