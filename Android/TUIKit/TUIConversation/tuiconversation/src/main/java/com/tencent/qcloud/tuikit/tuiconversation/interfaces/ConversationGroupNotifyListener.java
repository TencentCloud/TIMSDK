package com.tencent.qcloud.tuikit.tuiconversation.interfaces;

import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationGroupBean;
import java.util.List;

public interface ConversationGroupNotifyListener {
    void notifyGroupsAdd(List<ConversationGroupBean> beans);

    void notifyMarkGroupsAdd(List<ConversationGroupBean> beans);

    void notifyGroupAdd(ConversationGroupBean bean);

    void notifyGroupDelete(String groupName);

    void notifyGroupRename(String oldName, String newName);

    void notifyGroupUnreadMessageCountChanged(String groupName, long totalUnreadCount);
}
