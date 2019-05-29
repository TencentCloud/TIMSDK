package com.tencent.qcloud.uikit.api.infos;

import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatInfo;

public interface GroupInfoPanelEvent {

    void onBackClick();

    void onDissolve(GroupChatInfo info);

    void onModifyGroupName(GroupChatInfo info);

    void onModifyGroupNotice(GroupChatInfo info);

}
