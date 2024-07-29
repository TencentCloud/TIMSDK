package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMManager;


public class GroupChatInfo extends ChatInfo {
    public static final String GROUP_TYPE_PUBLIC = V2TIMManager.GROUP_TYPE_PUBLIC;
    public static final String GROUP_TYPE_WORK = V2TIMManager.GROUP_TYPE_WORK;
    public static final String GROUP_TYPE_AVCHATROOM = V2TIMManager.GROUP_TYPE_AVCHATROOM;
    public static final String GROUP_TYPE_MEETING = V2TIMManager.GROUP_TYPE_MEETING;
    public static final String GROUP_TYPE_COMMUNITY = V2TIMManager.GROUP_TYPE_COMMUNITY;

    private String groupType;
    private String groupName;
    private String notice;

    public GroupChatInfo() {
        setType(ChatInfo.TYPE_GROUP);
    }

    /**
     *
     * Get the group name
     *
     * @return
     */
    public String getGroupName() {
        return groupName;
    }

    /**
     *
     * Set the group name
     *
     * @param groupName
     */
    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    /**
     *
     * Get the group notice
     *
     * @return
     */
    public String getNotice() {
        return notice;
    }

    /**
     *
     * Set the group notice
     *
     * @param signature
     */
    public void setNotice(String signature) {
        this.notice = signature;
    }

    /**
     *
     * Get the group type
     *
     * @return
     */
    public String getGroupType() {
        return groupType;
    }

    /**
     *
     * Set the group type
     *
     * @param groupType
     */
    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

}
