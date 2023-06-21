package com.tencent.qcloud.tuikit.tuicommunity.bean;

import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;

public class CommunityChangeBean {
    private V2TIMGroupChangeInfo v2TIMGroupChangeInfo;
    public static final int CHANGE_TYPE_INVALID = V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_INVALID;

    public static final int CHANGE_TYPE_NAME = V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME;

    public static final int CHANGE_TYPE_INTRODUCTION = V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION;

    public static final int CHANGE_TYPE_NOTIFICATION = V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION;

    public static final int CHANGE_TYPE_FACE_URL = V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL;

    public static final int CHANGE_TYPE_OWNER = V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER;

    public static final int CHANGE_TYPE_CUSTOM = V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_CUSTOM;

    public static final int CHANGE_TYPE_SHUT_UP_ALL = V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL;

    public static final int CHANGE_TYPE_RECEIVE_MESSAGE_OPT = V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_RECEIVE_MESSAGE_OPT;

    public static final int CHANGE_TYPE_GROUP_ADD_OPT = V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_ADD_OPT;

    public int getType() {
        if (v2TIMGroupChangeInfo != null) {
            return v2TIMGroupChangeInfo.getType();
        }
        return CHANGE_TYPE_INVALID;
    }

    public String getKey() {
        if (v2TIMGroupChangeInfo != null) {
            return v2TIMGroupChangeInfo.getKey();
        }
        return null;
    }

    public String getValue() {
        if (v2TIMGroupChangeInfo != null) {
            return v2TIMGroupChangeInfo.getValue();
        }
        return null;
    }

    public void setV2TIMGroupChangeInfo(V2TIMGroupChangeInfo v2TIMGroupChangeInfo) {
        this.v2TIMGroupChangeInfo = v2TIMGroupChangeInfo;
    }
}
