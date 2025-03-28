package com.tencent.qcloud.tuikit.tuicontact.interfaces;

import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;

import java.util.List;

public interface GroupMemberListener {

    default void onGroupMemberLoaded(List<GroupMemberInfo> groupMemberBeanList) {}
}
