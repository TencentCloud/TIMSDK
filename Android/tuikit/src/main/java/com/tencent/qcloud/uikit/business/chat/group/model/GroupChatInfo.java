package com.tencent.qcloud.uikit.business.chat.group.model;

import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMManager;
import com.tencent.qcloud.uikit.business.chat.model.BaseChatInfo;

import java.util.List;


public class GroupChatInfo extends BaseChatInfo {

    private String groupType;
    private int memberCount;

    private String groupName;
    private String iconUrl;
    private String account;
    private String notice;
    private List<GroupMemberInfo> memberDetails;
    private int joinType;
    private String inGroupNickName;
    private String owner;
    private boolean isTopChat;

    public GroupChatInfo() {
        setType(TIMConversationType.Group);
    }


    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public String getIconUrl() {
        return iconUrl;
    }

    public void setIconUrl(String iconUrl) {
        this.iconUrl = iconUrl;
    }

    public String getAccount() {
        return account;
    }

    public void setAccount(String account) {
        this.account = account;
    }

    public String getNotice() {
        return notice;
    }

    public void setNotice(String signature) {
        this.notice = signature;
    }

    public String getOwner() {
        return owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public int getJoinType() {
        return joinType;
    }

    public void setJoinType(int joinType) {
        this.joinType = joinType;
    }

    public String getInGroupNickName() {
        return inGroupNickName;
    }

    public void setInGroupNickName(String inGroupNickName) {
        this.inGroupNickName = inGroupNickName;
    }

    public boolean isTopChat() {
        return isTopChat;
    }

    public void setTopChat(boolean topChat) {
        isTopChat = topChat;
    }

    public String getGroupType() {
        return groupType;
    }

    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }


    public List<GroupMemberInfo> getMemberDetails() {
        return memberDetails;
    }

    public void setMemberDetails(List<GroupMemberInfo> memberDetails) {
        this.memberDetails = memberDetails;
    }

    public int getMemberCount() {
        if (memberDetails != null)
            return memberDetails.size();
        return memberCount;
    }

    public void setMemberCount(int memberCount) {
        this.memberCount = memberCount;
    }

    public boolean isOwner() {
        return TIMManager.getInstance().getLoginUser().equals(owner);
    }
}
