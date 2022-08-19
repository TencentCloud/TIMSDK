package com.tencent.qcloud.tuikit.tuicommunity.bean;

import android.text.TextUtils;

import java.io.Serializable;

public class CommunityMemberBean implements Serializable {
    private String account;
    private String avatar;
    private String nameCard;
    private String nickName;
    private String friendRemark;

    public String getAccount() {
        return account;
    }

    public void setAccount(String account) {
        this.account = account;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public String getNameCard() {
        return nameCard;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNameCard(String nameCard) {
        this.nameCard = nameCard;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public void setFriendRemark(String friendRemark) {
        this.friendRemark = friendRemark;
    }

    public String getFriendRemark() {
        return friendRemark;
    }

    public String getDisplayName() {
        String displayName = account;
        if (!TextUtils.isEmpty(nameCard)) {
            displayName = nameCard;
        } else if (!TextUtils.isEmpty(friendRemark)) {
            displayName = friendRemark;
        } else if (!TextUtils.isEmpty(nickName)) {
            displayName = nickName;
        }
        return displayName;
    }
}
