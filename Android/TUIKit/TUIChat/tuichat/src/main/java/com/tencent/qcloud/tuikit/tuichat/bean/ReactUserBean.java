package com.tencent.qcloud.tuikit.tuichat.bean;

import android.text.TextUtils;

import java.io.Serializable;

public class ReactUserBean implements Serializable {
    private String userId;
    private String nikeName;
    private String nameCard;
    private String friendRemark;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getNikeName() {
        return nikeName;
    }

    public void setNikeName(String nikeName) {
        this.nikeName = nikeName;
    }

    public String getFriendRemark() {
        return friendRemark;
    }

    public void setFriendRemark(String friendRemark) {
        this.friendRemark = friendRemark;
    }

    public void setNameCard(String nameCard) {
        this.nameCard = nameCard;
    }

    public String getNameCard() {
        return nameCard;
    }

    public String getDisplayString() {
        if (!TextUtils.isEmpty(nameCard)) {
            return nameCard;
        } else if (!TextUtils.isEmpty(friendRemark)) {
            return friendRemark;
        } else if (!TextUtils.isEmpty(nikeName)) {
            return nikeName;
        } else {
            return userId;
        }
    }
}
