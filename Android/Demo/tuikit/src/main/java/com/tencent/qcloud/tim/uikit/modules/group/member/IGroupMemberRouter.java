package com.tencent.qcloud.tim.uikit.modules.group.member;

import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;

public interface IGroupMemberRouter {

    void forwardListMember(GroupInfo info);

    void forwardAddMember(GroupInfo info);

    void forwardDeleteMember(GroupInfo info);
}
