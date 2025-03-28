package com.tencent.qcloud.tuikit.tuicontact.interfaces;

import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ILayout;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;

public interface IGroupMemberLayout extends ILayout {
    void onGroupInfoChanged(GroupInfo dataSource);

    void onGroupMemberListChanged(GroupInfo dataSource);
}
