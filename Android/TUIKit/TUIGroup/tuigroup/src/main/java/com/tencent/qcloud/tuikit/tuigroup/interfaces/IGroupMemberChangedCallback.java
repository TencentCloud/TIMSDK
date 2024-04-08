package com.tencent.qcloud.tuikit.tuigroup.interfaces;

import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;

public interface IGroupMemberChangedCallback {
    void onMemberRemoved(GroupMemberInfo memberInfo);
}
