package com.tencent.qcloud.tuikit.tuigroup.classicui.interfaces;

import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;

import java.util.ArrayList;

public interface IGroupMemberListener {

    void forwardListMember(GroupInfo info);

    void forwardAddMember(GroupInfo info);

    void forwardDeleteMember(GroupInfo info);

    default void setSelectedMember(ArrayList<String> members) {}
}
