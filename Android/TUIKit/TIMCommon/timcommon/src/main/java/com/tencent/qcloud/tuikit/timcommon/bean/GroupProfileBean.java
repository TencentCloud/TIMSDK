package com.tencent.qcloud.tuikit.timcommon.bean;

import com.tencent.imsdk.group.GroupMemberInfo;

import java.io.Serializable;

public class GroupProfileBean implements Serializable {
    private String groupName;
    private String groupID;
    private String groupType;
    private String notification;
    private String groupIntroduction;
    private String groupFaceUrl;
    private int memberCount;
    private int recvOpt;
    private int approveOpt;
    private int addOpt;
    private boolean isAllMuted = false;
    private GroupMemberBean selfInfo;

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public String getGroupID() {
        return groupID;
    }

    public void setGroupID(String groupID) {
        this.groupID = groupID;
    }

    public String getGroupType() {
        return groupType;
    }

    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

    public String getNotification() {
        return notification;
    }

    public void setNotification(String notification) {
        this.notification = notification;
    }

    public String getGroupIntroduction() {
        return groupIntroduction;
    }

    public void setGroupIntroduction(String groupIntroduction) {
        this.groupIntroduction = groupIntroduction;
    }

    public String getGroupFaceUrl() {
        return groupFaceUrl;
    }

    public void setGroupFaceUrl(String groupFaceUrl) {
        this.groupFaceUrl = groupFaceUrl;
    }

    public int getMemberCount() {
        return memberCount;
    }

    public void setMemberCount(int memberCount) {
        this.memberCount = memberCount;
    }

    public void setSelfInfo(GroupMemberBean selfInfo) {
        this.selfInfo = selfInfo;
    }

    public GroupMemberBean getSelfInfo() {
        return selfInfo;
    }

    public int getRoleInGroup() {
        return selfInfo.getRole();
    }

    public void setRoleInGroup(int role) {
        selfInfo.setRole(role);
    }

    public boolean canManage() {
        return selfInfo.getRole() == GroupMemberInfo.MEMBER_ROLE_OWNER || selfInfo.getRole() == GroupMemberInfo.MEMBER_ROLE_ADMINISTRATOR;
    }

    public boolean isOwner() {
        return selfInfo.getRole() == GroupMemberInfo.MEMBER_ROLE_OWNER;
    }

    public boolean isAdmin() {
        return selfInfo.getRole() == GroupMemberInfo.MEMBER_ROLE_ADMINISTRATOR;
    }

    public void setAllMuted(boolean allMuted) {
        isAllMuted = allMuted;
    }

    public boolean isAllMuted() {
        return isAllMuted;
    }

    public void setApproveOpt(int approveOpt) {
        this.approveOpt = approveOpt;
    }

    public int getApproveOpt() {
        return approveOpt;
    }

    public int getAddOpt() {
        return addOpt;
    }

    public void setAddOpt(int addOpt) {
        this.addOpt = addOpt;
    }

    public void setRecvOpt(int recvOpt) {
        this.recvOpt = recvOpt;
    }

    public int getRecvOpt() {
        return recvOpt;
    }
}
