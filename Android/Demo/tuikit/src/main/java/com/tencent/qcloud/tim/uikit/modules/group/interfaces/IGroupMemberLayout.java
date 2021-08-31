package com.tencent.qcloud.tim.uikit.modules.group.interfaces;

import com.tencent.qcloud.tim.uikit.base.ILayout;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;


public interface IGroupMemberLayout extends ILayout {

    void setDataSource(GroupInfo dataSource);

}
