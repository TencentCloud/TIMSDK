package com.tencent.qcloud.uikit.api.infos;

import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatInfo;

/**
 * Created by valxehuang on 2018/7/30.
 */

public interface GroupInfoPanelEvent {

    void onBackClick();

    void onDissolve(GroupChatInfo info);

    void onModifyGroupName(GroupChatInfo info);

    void onModifyGroupNotice(GroupChatInfo info);

}
