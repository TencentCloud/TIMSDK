package com.tencent.qcloud.tuikit.tuigroup.ui.interfaces;

import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;

public interface IGroupMemberChangedCallback {
    void onMemberRemoved(GroupMemberInfo memberInfo);
}
