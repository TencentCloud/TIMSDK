package com.tencent.qcloud.tuikit.tuicontact.interfaces;

import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;

import java.util.ArrayList;

public interface IGroupMemberListener {

    default void forwardAddMember(GroupInfo info) {}

    default void forwardDeleteMember(GroupInfo info) {}

    default void setSelectedMember(ArrayList<String> members) {}
}
