package com.tencent.qcloud.tuikit.tuicommunity.bean;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.qcloud.tuicore.TUILogin;

import java.io.Serializable;
import java.util.List;

public class CommunityBean implements Comparable<CommunityBean>, Serializable {

     public static final int ROLE_UNDEFINED = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_UNDEFINED;
     public static final int ROLE_ADMIN = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_ADMIN;
     public static final int ROLE_OWNER = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_OWNER;
     public static final int ROLE_MEMBER = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_MEMBER;

    private String groupId;
    private String groupFaceUrl;
    private String communityName;
    private String introduction;
    private String coverUrl;
    private String owner;
    private int role;
    private long createTime;
    private long joinTime;
    private long lastMessageTime;
    private long lastInfoTime;
    private List<String> topicCategories;

    public String getGroupId() {
        return groupId;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public void setLastMessageTime(long lastMessageTime) {
        this.lastMessageTime = lastMessageTime;
    }

    public long getLastMessageTime() {
        return lastMessageTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public void setJoinTime(long joinTime) {
        this.joinTime = joinTime;
    }

    public void setLastInfoTime(long lastInfoTime) {
        this.lastInfoTime = lastInfoTime;
    }

    public long getCreateTime() {
        return createTime;
    }

    public long getJoinTime() {
        return joinTime;
    }

    public long getLastInfoTime() {
        return lastInfoTime;
    }

    /**
     * 根据最新活动时间排序
     * Sort by latest event time
     */
    public long getSortTime() {
        long sortTime = createTime;
        sortTime = Math.max(sortTime, joinTime);
        sortTime = Math.max(sortTime, lastInfoTime);
        sortTime = Math.max(sortTime, lastMessageTime);
        return sortTime;
    }

    public String getGroupFaceUrl() {
        return groupFaceUrl;
    }

    public void setGroupFaceUrl(String groupFaceUrl) {
        this.groupFaceUrl = groupFaceUrl;
    }

    public String getCommunityName() {
        return communityName;
    }

    public void setCommunityName(String communityName) {
        this.communityName = communityName;
    }

    public String getIntroduction() {
        return introduction;
    }

    public void setIntroduction(String introduction) {
        this.introduction = introduction;
    }

    public int getRole() {
        return role;
    }

    public void setRole(int role) {
        this.role = role;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public String getOwner() {
        return owner;
    }

    public String getCoverUrl() {
        return coverUrl;
    }

    public void setCoverUrl(String coverUrl) {
        this.coverUrl = coverUrl;
    }

    public void setTopicCategories(List<String> topicCategories) {
        this.topicCategories = topicCategories;
    }

    public List<String> getTopicCategories() {
        return topicCategories;
    }

    public boolean isOwner() {
        return TextUtils.equals(owner, TUILogin.getLoginUser());
    }

    @Override
    public int compareTo(CommunityBean o) {
        if (getSortTime() > o.getSortTime()) {
            return -1;
        } else if (getSortTime() == o.getSortTime()) {
            return 0;
        } else {
            return 1;
        }
    }
}
