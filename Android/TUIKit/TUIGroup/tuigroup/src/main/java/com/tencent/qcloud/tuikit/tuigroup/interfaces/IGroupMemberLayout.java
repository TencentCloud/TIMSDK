package com.tencent.qcloud.tuikit.tuigroup.interfaces;

import com.tencent.qcloud.tuicore.component.interfaces.ILayout;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;


public interface IGroupMemberLayout extends ILayout {

    void onGroupInfoChanged(GroupInfo dataSource);
    void onGroupInfoModified(Object value, int type);
}
