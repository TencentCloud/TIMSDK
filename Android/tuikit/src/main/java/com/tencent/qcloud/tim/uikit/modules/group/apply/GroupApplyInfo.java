package com.tencent.qcloud.tim.uikit.modules.group.apply;

import com.tencent.imsdk.ext.group.TIMGroupPendencyItem;

import java.io.Serializable;

public class GroupApplyInfo implements Serializable {

    public static final int APPLIED = 1;
    public static final int REFUSED = -1;
    public static final int UNHANDLED = 0;

    private int status;
    private TIMGroupPendencyItem pendencyItem;

    public void setStatus(int status) {
        this.status = status;
    }

    public int getStatus() {
        return status;
    }

    public GroupApplyInfo(TIMGroupPendencyItem pendency) {
        this.pendencyItem = pendency;
    }

    public TIMGroupPendencyItem getPendencyItem() {
        return pendencyItem;
    }

}
