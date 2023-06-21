package com.tencent.qcloud.tuikit.tuigroup.bean;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import java.io.Serializable;

public class GroupMemberInfo implements Serializable {
    private String iconUrl;
    private String account;
    private String signature;
    private String location;
    private String birthday;
    private String nameCard;
    private String nickName;
    private boolean isTopChat;
    private boolean isFriend;
    private long joinTime;
    private long tinyId;
    private int memberType;
    private boolean isSelected = false;

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

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getBirthday() {
        return birthday;
    }

    public void setBirthday(String birthday) {
        this.birthday = birthday;
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

    public boolean isTopChat() {
        return isTopChat;
    }

    public void setTopChat(boolean topChat) {
        isTopChat = topChat;
    }

    public boolean isFriend() {
        return isFriend;
    }

    public void setFriend(boolean friend) {
        isFriend = friend;
    }

    public long getJoinTime() {
        return joinTime;
    }

    public void setJoinTime(long joinTime) {
        this.joinTime = joinTime;
    }

    public int getMemberType() {
        return memberType;
    }

    public void setMemberType(int memberType) {
        this.memberType = memberType;
    }

    public void setSelected(boolean selected) {
        isSelected = selected;
    }

    public boolean isSelected() {
        return isSelected;
    }

    public String getDisplayName() {
        if (!TextUtils.isEmpty(nameCard)) {
            return nameCard;
        } else if (!TextUtils.isEmpty(nickName)) {
            return nickName;
        } else if (!TextUtils.isEmpty(account)) {
            return account;
        } else {
            return "";
        }
    }

    public GroupMemberInfo covertTIMGroupMemberInfo(V2TIMGroupMemberInfo info) {
        if (info instanceof V2TIMGroupMemberFullInfo) {
            V2TIMGroupMemberFullInfo v2TIMGroupMemberFullInfo = (V2TIMGroupMemberFullInfo) info;
            setJoinTime(v2TIMGroupMemberFullInfo.getJoinTime());
            setMemberType(v2TIMGroupMemberFullInfo.getRole());
        }
        setAccount(info.getUserID());
        setNameCard(info.getNameCard());
        setIconUrl(info.getFaceUrl());
        setNickName(info.getNickName());
        return this;
    }
}
