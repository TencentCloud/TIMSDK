package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMGroupApplication;

import java.io.Serializable;

public class GroupApplyInfo implements Serializable {

    private V2TIMGroupApplication timGroupApplication;

    public GroupApplyInfo(V2TIMGroupApplication timGroupApplication) {
        this.timGroupApplication = timGroupApplication;
    }

    public V2TIMGroupApplication getGroupApplication() {
        return timGroupApplication;
    }

    public boolean isStatusHandled() {
        if (timGroupApplication != null) {
            return timGroupApplication.getHandleStatus() != V2TIMGroupApplication.V2TIM_GROUP_APPLICATION_HANDLE_STATUS_UNHANDLED;
        }
        return false;
    }
}
