package com.tencent.qcloud.tim.uikit.modules.group.apply;

import com.tencent.imsdk.v2.V2TIMGroupApplication;

import java.io.Serializable;

public class GroupApplyInfo implements Serializable {

    public static final int APPLIED = 1;
    public static final int REFUSED = -1;
    public static final int UNHANDLED = 0;

    private int status;
    private V2TIMGroupApplication timGroupApplication;

    public GroupApplyInfo(V2TIMGroupApplication timGroupApplication) {
        this.timGroupApplication = timGroupApplication;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public V2TIMGroupApplication getGroupApplication() {
        return timGroupApplication;
    }

}
