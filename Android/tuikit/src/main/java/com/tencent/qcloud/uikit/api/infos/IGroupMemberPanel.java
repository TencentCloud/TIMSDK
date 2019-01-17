package com.tencent.qcloud.uikit.api.infos;

import com.tencent.qcloud.uikit.business.chat.group.model.GroupMemberInfo;
import com.tencent.qcloud.uikit.business.chat.group.view.widget.GroupMemberCallback;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;

import java.util.List;

/**
 * Created by valxehuang on 2018/7/17.
 */

public interface IGroupMemberPanel {

    PageTitleBar getTitleBar();

    void setMembers(List<GroupMemberInfo> members);

    void initDefault();

    void setGroupMemberCallback(GroupMemberCallback callback);

}
