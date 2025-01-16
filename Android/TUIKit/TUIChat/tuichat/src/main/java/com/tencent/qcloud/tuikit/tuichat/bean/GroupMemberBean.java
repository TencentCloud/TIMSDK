package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;

public class GroupMemberBean extends UserBean {
    private int role;

    public int getRole() {
        return role;
    }

    public void setRole(int role) {
        this.role = role;
    }
}
