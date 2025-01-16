package com.tencent.qcloud.tuikit.tuicontact.bean;

import android.text.TextUtils;

import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import java.util.ArrayList;
import java.util.List;

public class GroupInfo extends ChatInfo {
    public static final int ERR_SVR_GROUP_ALLREADY_MEMBER = BaseConstants.ERR_SVR_GROUP_ALLREADY_MEMBER;
    public static final int ERR_SVR_GROUP_PERMISSION_DENY = BaseConstants.ERR_SVR_GROUP_PERMISSION_DENY;
    public static final int ERR_SVR_GROUP_NOT_FOUND = BaseConstants.ERR_SVR_GROUP_NOT_FOUND; 
    public static final int ERR_SVR_GROUP_FULL_MEMBER_COUNT = BaseConstants.ERR_SVR_GROUP_FULL_MEMBER_COUNT;
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
    private String groupName;
    private String notice;
    private List<GroupMemberInfo> memberDetails = new ArrayList<>();
    private int joinType;
    private String owner;
    private boolean messageReceiveOption;
    private String faceUrl;
    private boolean communitySupportTopic = false;
    private List<Object> iconUrlList = new ArrayList<>();
    private int selfRole;
    private int groupMemberCount = 0;
    private long mNextSeq = 0;
    private boolean isAllMuted;

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
     * 
     * Set group announcements
     *
     * @param signature
     */
    public void setNotice(String signature) {
        this.notice = signature;
    }

    /**
     * 
     *
     * Get the group verification method
     *
     * @return
     */
    public int getJoinType() {
        return joinType;
    }

    /**
     * 
     *
     * Set the group verification method
     *
     * @param joinType
     */
    public void setJoinType(int joinType) {
        this.joinType = joinType;
    }

    /**
     * ，Public/Private/ChatRoom
     *
     * Get the group type, Public/Private/ChatRoom
     *
     * @return
     */
    public String getGroupType() {
        return groupType;
    }

    /**
     * 
     *
     * Set the group type
     *
     * @param groupType
     */
    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

    /**
     * 
     *
     * Get member details
     *
     * @return
     */
    public List<GroupMemberInfo> getMemberDetails() {
        return memberDetails;
    }

    /**
     * 
     *
     * Set member details
     *
     * @param memberDetails
     */
    public void setMemberDetails(List<GroupMemberInfo> memberDetails) {
        this.memberDetails = memberDetails;
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

    public boolean isCommunitySupportTopic() {
        return communitySupportTopic;
    }

    public void setCommunitySupportTopic(boolean communitySupportTopic) {
        this.communitySupportTopic = communitySupportTopic;
    }

    public void setIconUrlList(List<Object> iconUrlList) {
        this.iconUrlList = iconUrlList;
    }

    public boolean isOwner() {
        return selfRole == V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_OWNER;
    }

    public void setNextSeq(long nextSeq) {
        mNextSeq = nextSeq;
    }

    public void setInviteType(Integer value) {
    }



    public boolean isAllMuted() {
        return false;
    }

    public boolean isCanManagerGroup() {
        return false;
    }

    public CharSequence getNotice() {
            return null;
    }

    public long getNextSeq() {
        return mNextSeq;
    }

    public void setTopChat(boolean isSetTop) {

    }

    public void setFolded(boolean b) {
    }

    public int getInviteType() {
        return 1;
    }

    public int getSelfRole() {
        return selfRole;
    }

    public void setSelfRole(int selfRole) {
        this.selfRole = selfRole;
    }

    public void setGroupMemberCount(int groupMemberCount) {
        this.groupMemberCount = groupMemberCount;
    }

    public int getGroupMemberCount() {
        return groupMemberCount;
    }

    public void covertTIMGroupDetailInfo(V2TIMGroupInfoResult result) {
        setChatName(result.getGroupInfo().getGroupName());
        setGroupName(result.getGroupInfo().getGroupName());
        setId(result.getGroupInfo().getGroupID());
        setNotice(result.getGroupInfo().getNotification());
        setGroupMemberCount(result.getGroupInfo().getMemberCount());
        setGroupType(result.getGroupInfo().getGroupType());
        owner = result.getGroupInfo().getOwner();
        setJoinType(result.getGroupInfo().getGroupAddOpt());
        setInviteType(result.getGroupInfo().getGroupApproveOpt());
        setMessageReceiveOption(result.getGroupInfo().getRecvOpt() == V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE ? true : false);
        setFaceUrl(result.getGroupInfo().getFaceUrl());
        selfRole = result.getGroupInfo().getRole();
        isAllMuted = result.getGroupInfo().isAllMuted();
    }
}
