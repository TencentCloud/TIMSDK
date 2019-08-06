package com.tencent.qcloud.tim.uikit.modules.group.info;

import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.ext.group.TIMGroupDetailInfoResult;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.group.member.GroupMemberInfo;

import java.util.List;


public class GroupInfo extends ChatInfo {

    private String groupType;
    private int memberCount;
    private String groupName;
    private String notice;
    private List<GroupMemberInfo> memberDetails;
    private int joinType;
    private String owner;

    public GroupInfo() {
        setType(TIMConversationType.Group);
    }

    /**
     * 获取群名称
     *
     * @return
     */
    public String getGroupName() {
        return groupName;
    }

    /**
     * 设置群名称
     *
     * @param groupName
     */
    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    /**
     * 获取群公告
     *
     * @return
     */
    public String getNotice() {
        return notice;
    }

    /**
     * 设置群公告
     *
     * @param signature
     */
    public void setNotice(String signature) {
        this.notice = signature;
    }

    /**
     * 设置是否是群主
     *
     * @param owner
     */
    public void setOwner(String owner) {
        this.owner = owner;
    }

    /**
     * 回去加群验证方式
     *
     * @return
     */
    public int getJoinType() {
        return joinType;
    }

    /**
     * 设置加群验证方式
     *
     * @param joinType
     */
    public void setJoinType(int joinType) {
        this.joinType = joinType;
    }

    /**
     * 获取群类型，Public/Private/ChatRoom
     *
     * @return
     */
    public String getGroupType() {
        return groupType;
    }

    /**
     * 设置群类型
     *
     * @param groupType
     */
    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

    /**
     * 获取成员详细信息
     *
     * @return
     */
    public List<GroupMemberInfo> getMemberDetails() {
        return memberDetails;
    }

    /**
     * 设置成员详细信息
     *
     * @param memberDetails
     */
    public void setMemberDetails(List<GroupMemberInfo> memberDetails) {
        this.memberDetails = memberDetails;
    }

    /**
     * 获取群成员数量
     *
     * @return
     */
    public int getMemberCount() {
        if (memberDetails != null) {
            return memberDetails.size();
        }
        return memberCount;
    }

    /**
     * 设置群成员数量
     *
     * @param memberCount
     */
    public void setMemberCount(int memberCount) {
        this.memberCount = memberCount;
    }

    /**
     * 返回是否是群主
     *
     * @return
     */
    public boolean isOwner() {
        return TIMManager.getInstance().getLoginUser().equals(owner);
    }

    /**
     * 从SDK转化为TUIKit的群信息bean
     *
     * @param detailInfo
     * @return
     */
    public GroupInfo covertTIMGroupDetailInfo(TIMGroupDetailInfoResult detailInfo) {
        setChatName(detailInfo.getGroupName());
        setGroupName(detailInfo.getGroupName());
        setId(detailInfo.getGroupId());
        setNotice(detailInfo.getGroupNotification());
        setMemberCount((int) detailInfo.getMemberNum());
        setGroupType(detailInfo.getGroupType());
        setOwner(detailInfo.getGroupOwner());
        setJoinType((int) detailInfo.getAddOption().getValue());
        return this;
    }
}
