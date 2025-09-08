package com.tencent.qcloud.tuikit.tuicontact.bean;

import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;

import java.io.Serializable;

public class GroupMemberInfo extends UserBean implements Serializable {

    private long muteUtil = 0;
    private int role = 0;
    private boolean isSelected = false;

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean selected) {
        this.isSelected = selected;
    }

    public void setMuteUtil(long muteUtil) {
        this.muteUtil = muteUtil;
    }

    public long getMuteUtil() {
        return muteUtil;
    }

    public void setRole(int role) {
        this.role = role;
    }

    public int getRole() {
        return role;
    }

    public GroupMemberInfo covertTIMGroupMemberInfo(V2TIMGroupMemberFullInfo info) {
        if (info instanceof V2TIMGroupMemberFullInfo) {
            V2TIMGroupMemberFullInfo v2TIMGroupMemberFullInfo = info;
            setRole(v2TIMGroupMemberFullInfo.getRole());
        }
        setUserId(info.getUserID());
        setNameCard(info.getNameCard());
        setFaceUrl(info.getFaceUrl());
        setNickName(info.getNickName());
        setFriendRemark(info.getFriendRemark());

        return this;
    }
}
