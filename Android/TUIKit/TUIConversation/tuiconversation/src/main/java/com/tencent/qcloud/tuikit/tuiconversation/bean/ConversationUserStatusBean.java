package com.tencent.qcloud.tuikit.tuiconversation.bean;

import com.tencent.imsdk.v2.V2TIMUserStatus;

public class ConversationUserStatusBean {

    public static final int USER_STATUS_UNKNOWN = V2TIMUserStatus.V2TIM_USER_STATUS_UNKNOWN;
    public static final int USER_STATUS_ONLINE = V2TIMUserStatus.V2TIM_USER_STATUS_ONLINE;
    public static final int USER_STATUS_OFFLINE = V2TIMUserStatus.V2TIM_USER_STATUS_OFFLINE;
    public static final int USER_STATUS_UNLOGINED = V2TIMUserStatus.V2TIM_USER_STATUS_UNLOGINED;

    private V2TIMUserStatus v2TIMUserStatus;

    public void setV2TIMUserStatus(V2TIMUserStatus v2TIMUserStatus) {
        this.v2TIMUserStatus = v2TIMUserStatus;
    }

    public String getUserID() {
        if (v2TIMUserStatus != null) {
            return v2TIMUserStatus.getUserID();
        }
        return "";
    }

    public int getStatusType() {
        if (v2TIMUserStatus != null) {
            return v2TIMUserStatus.getStatusType();
        }
        return 0;
    }
}
