package com.tencent.qcloud.uikit.business.chat.group.view.widget;

import com.tencent.qcloud.uikit.business.chat.group.model.GroupApplyInfo;

import java.util.List;

public interface GroupApplyCallback {

    void onAccept(int position, GroupApplyInfo item);

    void onRefuse(int position, GroupApplyInfo item);

    void setDataSource(List<GroupApplyInfo> members);

}
