package com.tencent.qcloud.uikit.business.chat.group.view.widget;

import com.tencent.qcloud.uikit.business.chat.group.model.GroupMemberInfo;

import java.util.List;

public interface GroupMemberCallback {
    void onMemberRemove(GroupMemberInfo memberInfo, List<GroupMemberInfo> members);
}
