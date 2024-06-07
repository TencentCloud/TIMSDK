package com.tencent.qcloud.tuikit.tuicontact.bean;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;

import java.io.Serializable;

public class GroupMemberInfo implements Serializable {
    private String iconUrl;
    private String account;
    private String signature;
    private String nameCard;
    private String nickName;

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

    public String getSignature() {
        return signature;
    }

    public void setSignature(String signature) {
        this.signature = signature;
    }

    public void setNameCard(String nameCard) {
        this.nameCard = nameCard;
    }

    public String getNameCard() {
        return nameCard;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getNickName() {
        return this.nickName;
    }

    public String getDisplayName() {
        String displayName = account;
        if (!TextUtils.isEmpty(nameCard)) {
            displayName = nameCard;
        } else if (!TextUtils.isEmpty(nickName)) {
            displayName = nickName;
        }
        return displayName;
    }

}
