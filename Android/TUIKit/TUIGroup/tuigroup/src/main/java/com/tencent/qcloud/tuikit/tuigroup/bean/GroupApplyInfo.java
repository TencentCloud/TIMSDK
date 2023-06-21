package com.tencent.qcloud.tuikit.tuigroup.bean;

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

    public String getFromUserFaceUrl() {
        if (timGroupApplication != null) {
            return timGroupApplication.getFromUserFaceUrl();
        }
        return null;
    }

    public String getFromUserID() {
        if (timGroupApplication != null) {
            return timGroupApplication.getFromUser();
        }
        return null;
    }

    public String getAddWording() {
        if (timGroupApplication != null) {
            return timGroupApplication.getRequestMsg();
        }
        return null;
    }

    public String getGroupID() {
        if (timGroupApplication != null) {
            return timGroupApplication.getGroupID();
        }
        return null;
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
