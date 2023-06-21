package com.tencent.qcloud.tuikit.tuiconversation.classicui.interfaces;

import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationGroupBean;

public interface IConversationGroupListener {
    void notifyGroupAdd(ConversationGroupBean bean);

    void notifyGroupDelete(String groupName);

    void notifyGroupRename(String oldName, String newName);

    void notifyGroupUnreadMessageCountChanged(String groupName, long totalUnreadCount);
}
