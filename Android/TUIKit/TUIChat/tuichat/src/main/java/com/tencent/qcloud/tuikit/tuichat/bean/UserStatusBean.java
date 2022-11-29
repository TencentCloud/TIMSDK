package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMUserStatus;

import java.io.Serializable;

public class UserStatusBean implements Serializable {

    public static final int STATUS_ONLINE = V2TIMUserStatus.V2TIM_USER_STATUS_ONLINE;
    public static final int STATUS_OFFLINE = V2TIMUserStatus.V2TIM_USER_STATUS_ONLINE;

    private String userID;
    private int onlineStatus = STATUS_OFFLINE;

    public void setOnlineStatus(int onlineStatus) {
        this.onlineStatus = onlineStatus;
    }

    public int getOnlineStatus() {
        return onlineStatus;
    }

    public void setUserID(String userID) {
        this.userID = userID;
    }

    public String getUserID() {
        return userID;
    }
}
