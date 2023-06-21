package com.tencent.qcloud.tuikit.tuicontact.bean;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.bean.BaseIndexPinyinBean;

public class ContactItemBean extends BaseIndexPinyinBean {
    public static final int TYPE_C2C = V2TIMConversation.V2TIM_C2C;
    public static final int TYPE_GROUP = V2TIMConversation.V2TIM_GROUP;
    public static final int TYPE_INVALID = V2TIMConversation.CONVERSATION_TYPE_INVALID;

    public static final int ITEM_BEAN_TYPE_CONTACT = 1;
    public static final int ITEM_BEAN_TYPE_CONTROLLER = 2;

    public static final String INDEX_STRING_TOP = "↑";
    private String id;
    private boolean isTop;
    private boolean isSelected;
    private boolean isBlackList;
    private String remark;
    private String nickName;
    private String avatarUrl;
    private String signature;
    private boolean isGroup;
    private String groupType;
    private boolean isFriend = false;
    private boolean isEnable = true;
    private int statusType = V2TIMUserStatus.V2TIM_USER_STATUS_UNKNOWN;
    private int itemBeanType = ITEM_BEAN_TYPE_CONTACT;

    public ContactItemBean() {}

    public ContactItemBean(String id) {
        this.id = id;
    }

    public String getId() {
        return id;
    }

    public ContactItemBean setId(String id) {
        this.id = id;
        return this;
    }

    public ContactItemBean setItemBeanType(int itemBeanType) {
        this.itemBeanType = itemBeanType;
        return this;
    }

    public int getItemBeanType() {
        return itemBeanType;
    }

    public boolean isTop() {
        return isTop;
    }

    public ContactItemBean setTop(boolean top) {
        isTop = top;
        return this;
    }

    @Override
    public String getTarget() {
        if (!TextUtils.isEmpty(remark)) {
            return remark;
        }
        if (!TextUtils.isEmpty(nickName)) {
            return nickName;
        }
        return id;
    }

    @Override
    public boolean isNeedToPinyin() {
        return !isTop;
    }

    @Override
    public boolean isShowSuspension() {
        return !isTop;
    }

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean selected) {
        isSelected = selected;
    }

    public boolean isEnable() {
        return isEnable;
    }

    public void setEnable(boolean enable) {
        isEnable = enable;
    }

    public boolean isBlackList() {
        return isBlackList;
    }

    public void setBlackList(boolean blacklist) {
        isBlackList = blacklist;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getSignature() {
        return signature;
    }

    public void setSignature(String signature) {
        this.signature = signature;
    }

    public ContactItemBean covertTIMFriend(V2TIMFriendInfo friendInfo) {
        if (friendInfo == null) {
            return this;
        }
        setId(friendInfo.getUserID());
        setNickName(friendInfo.getUserProfile().getNickName());
        setAvatarUrl(friendInfo.getUserProfile().getFaceUrl());
        setSignature(friendInfo.getUserProfile().getSelfSignature());
        setRemark(friendInfo.getFriendRemark());
        return this;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public boolean isGroup() {
        return isGroup;
    }

    public void setGroup(boolean group) {
        isGroup = group;
    }

    public String getGroupType() {
        return groupType;
    }

    public void setGroupType(String groupType) {
        this.groupType = groupType;
    }

    public boolean isFriend() {
        return isFriend;
    }

    public void setFriend(boolean friend) {
        isFriend = friend;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public int getStatusType() {
        return statusType;
    }

    public void setStatusType(int statusType) {
        this.statusType = statusType;
    }

    public ContactItemBean covertTIMGroupBaseInfo(V2TIMGroupInfo group) {
        if (group == null) {
            return this;
        }
        setId(group.getGroupID());
        setRemark(group.getGroupName());
        setAvatarUrl(group.getFaceUrl());
        setGroup(true);
        setGroupType(group.getGroupType());
        return this;
    }

    public ContactItemBean covertTIMGroupMemberFullInfo(V2TIMGroupMemberFullInfo member) {
        if (member == null) {
            return this;
        }
        setId(member.getUserID());
        if (TextUtils.isEmpty(member.getNickName())) {
            setRemark(member.getNameCard());
            setNickName(member.getNameCard());
        } else {
            setRemark(member.getNickName());
            setNickName(member.getNickName());
        }
        setAvatarUrl(member.getFaceUrl());
        setGroup(false);
        return this;
    }
}
