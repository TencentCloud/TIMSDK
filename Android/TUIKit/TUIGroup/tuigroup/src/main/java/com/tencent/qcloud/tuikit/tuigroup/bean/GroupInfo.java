package com.tencent.qcloud.tuikit.tuigroup.bean;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import java.util.ArrayList;
import java.util.List;

public class GroupInfo extends ChatInfo {
    public static final String GROUP_TYPE_MEETING = V2TIMManager.GROUP_TYPE_MEETING;
    public static final String GROUP_TYPE_AVCHATROOM = V2TIMManager.GROUP_TYPE_AVCHATROOM;
    public static final String GROUP_TYPE_COMMUNITY = V2TIMManager.GROUP_TYPE_COMMUNITY;
    public static final String GROUP_TYPE_PUBLIC = V2TIMManager.GROUP_TYPE_PUBLIC;
    public static final String GROUP_TYPE_WORK = V2TIMManager.GROUP_TYPE_WORK;

    public static final String GROUP_TYPE_ROOM = "Room";

    public static final int GROUP_MEMBER_FILTER_ALL = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL;
    public static final int GROUP_MEMBER_FILTER_OWNER = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_OWNER;
    public static final int GROUP_MEMBER_FILTER_ADMIN = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ADMIN;
    public static final int GROUP_MEMBER_FILTER_COMMON = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_COMMON;

    public static final int GROUP_MEMBER_ROLE_MEMBER = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_MEMBER;
    public static final int GROUP_MEMBER_ROLE_OWNER = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_OWNER;
    public static final int GROUP_MEMBER_ROLE_ADMIN = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_ADMIN;

    private String groupType;
    private int memberCount;
    private String groupName;
    private String notice;
    private List<GroupMemberInfo> memberDetails = new ArrayList<>();
    private int joinType;
    private int inviteType;
    private String owner;
    private boolean messageReceiveOption;
    private String faceUrl;
    private long mNextSeq = 0;
    private boolean canManagerGroup;
    private boolean isAllMuted;
    private int role;

    public GroupInfo() {
        setType(V2TIMConversation.V2TIM_GROUP);
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    /**
     * Get group announcements
     *
     * @return
     */
    public String getNotice() {
        return notice;
    }

    /**
     * Set group announcements
     *
     * @param signature
     */
    public void setNotice(String signature) {
        this.notice = signature;
    }

    /**
     * Get the group verification method
     *
     * @return
     */
    public int getJoinType() {
        return joinType;
    }

    /**
     * Set the group verification method
     *
     * @param joinType
     */
    public void setJoinType(int joinType) {
        this.joinType = joinType;
    }

    public int getInviteType() {
        return inviteType;
    }

    public void setInviteType(int inviteType) {
        this.inviteType = inviteType;
    }

    /**
     * Get the group type, Public/Private/ChatRoom
     *
     * @return
     */
    public String getGroupType() {
        return groupType;
    }

    /**
     * Set the group type
     *
     * @param groupType
     */
    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

    /**
     * Get member details
     *
     * @return
     */
    public List<GroupMemberInfo> getMemberDetails() {
        return memberDetails;
    }

    /**
     * Set member details
     *
     * @param memberDetails
     */
    public void setMemberDetails(List<GroupMemberInfo> memberDetails) {
        this.memberDetails = memberDetails;
    }

    /**
     * Get the number of members that have joined the group
     *
     * @return
     */
    public int getMemberCount() {
        return memberCount;
    }

    /**
     * Set the number of members that have joined the group
     *
     * @param memberCount
     */
    public void setMemberCount(int memberCount) {
        this.memberCount = memberCount;
    }

    /**
     * Returns whether it is the owner of the group
     *
     * @return
     */
    public boolean isOwner() {
        return V2TIMManager.getInstance().getLoginUser().equals(owner);
    }

    /**
     * Set whether it is the owner of the group
     *
     * @param owner
     */
    public void setOwner(String owner) {
        this.owner = owner;
    }

    /**
     * Get the current user's message receiving option in the group. To modify the group message receiving option, please call the setReceiveMessageOpt API.
     *
     * @return
     */
    public boolean getMessageReceiveOption() {
        return messageReceiveOption;
    }

    /**
     * Set the current user's message receiving option in the group.
     * @param messageReceiveOption, true,no message will be received； false，messages will be received.
     */
    public void setMessageReceiveOption(boolean messageReceiveOption) {
        this.messageReceiveOption = messageReceiveOption;
    }

    public String getFaceUrl() {
        return faceUrl;
    }

    public void setFaceUrl(String faceUrl) {
        this.faceUrl = faceUrl;
    }

    public long getNextSeq() {
        return mNextSeq;
    }

    public void setNextSeq(long mNextSeq) {
        this.mNextSeq = mNextSeq;
    }

    public boolean isCanManagerGroup() {
        return canManagerGroup;
    }

    public boolean isAllMuted() {
        return isAllMuted;
    }

    public void setRole(int role) {
        this.role = role;
    }

    public int getRole() {
        return role;
    }

    public GroupInfo covertTIMGroupDetailInfo(V2TIMGroupInfoResult infoResult) {
        if (infoResult.getResultCode() != 0) {
            return this;
        }
        setChatName(infoResult.getGroupInfo().getGroupName());
        setGroupName(infoResult.getGroupInfo().getGroupName());
        setId(infoResult.getGroupInfo().getGroupID());
        setNotice(infoResult.getGroupInfo().getNotification());
        setMemberCount(infoResult.getGroupInfo().getMemberCount());
        setGroupType(infoResult.getGroupInfo().getGroupType());
        setOwner(infoResult.getGroupInfo().getOwner());
        setJoinType(infoResult.getGroupInfo().getGroupAddOpt());
        setInviteType(infoResult.getGroupInfo().getGroupApproveOpt());
        setMessageReceiveOption(infoResult.getGroupInfo().getRecvOpt() == V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE ? true : false);
        setFaceUrl(infoResult.getGroupInfo().getFaceUrl());
        role = infoResult.getGroupInfo().getRole();
        canManagerGroup = role == V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_OWNER || role == V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_ADMIN
            || TextUtils.equals(groupType, V2TIMManager.GROUP_TYPE_WORK);
        isAllMuted = infoResult.getGroupInfo().isAllMuted();
        return this;
    }
}
