package com.tencent.qcloud.uikit.business.chat.group.view.widget;

import com.tencent.qcloud.uikit.business.chat.group.model.GroupApplyInfo;

import java.util.List;

public interface GroupApplyCallback {
    public void onAccept(int position, GroupApplyInfo item);

    public void onRefuse(int position, GroupApplyInfo item);

    public void setDataSource(List<GroupApplyInfo> members);

}
