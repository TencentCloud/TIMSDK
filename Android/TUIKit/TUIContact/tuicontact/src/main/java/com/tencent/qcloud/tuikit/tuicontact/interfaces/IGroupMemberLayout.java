package com.tencent.qcloud.tuikit.tuicontact.interfaces;

import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ILayout;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;

public interface IGroupMemberLayout extends ILayout {
    void onGroupInfoChanged(GroupInfo dataSource);

    void onGroupInfoModified(Object value, int type);

    void onGroupMemberListChanged(GroupInfo dataSource);
}
