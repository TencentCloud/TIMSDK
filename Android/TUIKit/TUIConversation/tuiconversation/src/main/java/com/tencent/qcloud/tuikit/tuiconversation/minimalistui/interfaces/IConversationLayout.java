package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces;

import android.view.View;

import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ILayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;

public interface IConversationLayout extends ILayout {
    View getConversationList();

    void setConversationTop(ConversationInfo conversation, IUIKitCallback callBack);

    void deleteConversation(ConversationInfo conversation);

    void clearConversationMessage(ConversationInfo conversation);

    /**
     * Hide normal conversation
     */
    void markConversationHidden(ConversationInfo conversation);

    /**
     * Mark conversation read or unread
     */
    void markConversationUnread(ConversationInfo conversationInfo, boolean markUnread);

    /**
     * Hide folded conversation item
     */
    void hideFoldedItem(boolean needHide);

    /**
     *  item 
     * Clear unread status of fold item
     */
    void clearUnreadStatusOfFoldItem();
}
