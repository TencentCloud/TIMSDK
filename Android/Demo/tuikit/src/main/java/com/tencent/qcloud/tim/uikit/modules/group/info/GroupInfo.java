package com.tencent.qcloud.tim.uikit.modules.group.info;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
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
    private boolean messageReceiveOption;
    private long mNextSeq = 0;

    public GroupInfo() {
        setType(V2TIMConversation.V2TIM_GROUP);
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
        return V2TIMManager.getInstance().getLoginUser().equals(owner);
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
     * 获取消息接收选项
     *
     * @return
     */
    public boolean getMessageReceiveOption() {
        return messageReceiveOption;
    }

    /**
     * 设置消息接收选项
     *
     * @param messageReceiveOption, true,免打扰； false，接收消息
     */
    public void setMessageReceiveOption(boolean messageReceiveOption) {
        this.messageReceiveOption = messageReceiveOption;
    }

    public long getNextSeq() {
        return mNextSeq;
    }

    public void setNextSeq(long mNextSeq) {
        this.mNextSeq = mNextSeq;
    }

    /**
     * 从SDK转化为TUIKit的群信息bean
     *
     * @param infoResult
     * @return
     */
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
        setMessageReceiveOption(infoResult.getGroupInfo().getRecvOpt() == V2TIMMessage.V2TIM_NOT_RECEIVE_MESSAGE ? true : false);
        return this;
    }
}
