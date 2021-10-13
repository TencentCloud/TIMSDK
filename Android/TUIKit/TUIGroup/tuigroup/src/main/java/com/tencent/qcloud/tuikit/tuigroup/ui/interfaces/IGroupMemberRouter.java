package com.tencent.qcloud.tuikit.tuigroup.ui.interfaces;

import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;

public interface IGroupMemberRouter {

    void forwardListMember(GroupInfo info);

    void forwardAddMember(GroupInfo info);

    void forwardDeleteMember(GroupInfo info);
}
