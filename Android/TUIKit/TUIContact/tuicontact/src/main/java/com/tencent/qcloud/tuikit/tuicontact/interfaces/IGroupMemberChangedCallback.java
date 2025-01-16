package com.tencent.qcloud.tuikit.tuicontact.interfaces;


import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;

public interface IGroupMemberChangedCallback {
    void onMemberRemoved(GroupMemberInfo memberInfo);
}
