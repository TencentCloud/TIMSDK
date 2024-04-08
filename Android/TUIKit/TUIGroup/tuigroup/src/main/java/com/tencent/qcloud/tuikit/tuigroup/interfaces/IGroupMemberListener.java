package com.tencent.qcloud.tuikit.tuigroup.interfaces;

import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;

import java.util.ArrayList;

public interface IGroupMemberListener {
    default void forwardListMember(GroupInfo info) {}

    default void forwardAddMember(GroupInfo info) {}

    default void forwardDeleteMember(GroupInfo info) {}

    default void forwardShowMemberDetail(GroupMemberInfo info) {}

    default void setSelectedMember(ArrayList<String> members) {}
}
