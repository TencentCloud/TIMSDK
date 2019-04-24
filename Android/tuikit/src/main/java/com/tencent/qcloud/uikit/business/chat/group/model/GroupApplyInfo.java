package com.tencent.qcloud.uikit.business.chat.group.model;

import com.tencent.imsdk.ext.group.TIMGroupPendencyItem;


public class GroupApplyInfo {

    private int status;
    private TIMGroupPendencyItem pendencyItem;

    public GroupApplyInfo(TIMGroupPendencyItem pendency) {
        this.pendencyItem = pendency;
    }

    public void setStatus(int status) {
        this.status = status;
    }


    public int getStatus() {
        return status;
    }

    public TIMGroupPendencyItem getPendencyItem() {
        return pendencyItem;
    }

}
