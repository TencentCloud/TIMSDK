package com.tencent.qcloud.tuikit.timcommon.bean;

import android.text.TextUtils;
import java.io.Serializable;

public class UserBean implements Serializable {
    protected String userId;
    protected String nickName;
    protected String nameCard;
    protected String friendRemark;
    protected String faceUrl;
    protected String signature;
    protected long birthday;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
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

    public String getDisplayName() {
        if (!TextUtils.isEmpty(nameCard)) {
            return nameCard;
        } else if (!TextUtils.isEmpty(friendRemark)) {
            return friendRemark;
        } else if (!TextUtils.isEmpty(nickName)) {
            return nickName;
        } else {
            return userId;
        }
    }

    public String getFaceUrl() {
        return faceUrl;
    }

    public void setFaceUrl(String faceUrl) {
        this.faceUrl = faceUrl;
    }

    public String getSignature() {
        return signature;
    }

    public long getBirthday() {
        return birthday;
    }

    public void setSignature(String signature) {
        this.signature = signature;
    }

    public void setBirthday(long birthday) {
        this.birthday = birthday;
    }
}
