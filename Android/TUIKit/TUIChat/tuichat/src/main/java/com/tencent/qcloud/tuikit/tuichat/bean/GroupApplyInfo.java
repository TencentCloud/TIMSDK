package com.tencent.qcloud.tuikit.tuichat.bean;

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

    public String getFromUser() {
        if (timGroupApplication != null) {
            return timGroupApplication.getFromUser();
        }
        return "";
    }

    public String getFromUserNickName() {
        if (timGroupApplication != null) {
            return timGroupApplication.getFromUserNickName();
        }
        return "";
    }

    public String getRequestMsg() {
        if (timGroupApplication != null) {
            return timGroupApplication.getRequestMsg();
        }
        return "";
    }

    public boolean isStatusHandled() {
        if (timGroupApplication != null) {
            return timGroupApplication.getHandleStatus() != V2TIMGroupApplication.V2TIM_GROUP_APPLICATION_HANDLE_STATUS_UNHANDLED;
        }
        return false;
    }

}
