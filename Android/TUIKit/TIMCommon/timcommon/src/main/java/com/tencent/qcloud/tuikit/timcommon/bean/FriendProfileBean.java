package com.tencent.qcloud.tuikit.timcommon.bean;

import java.io.Serializable;

public class FriendProfileBean extends UserBean implements Serializable {
    private int allowType;

    public int getAllowType() {
        return allowType;
    }

    public void setAllowType(int allowType) {
        this.allowType = allowType;
    }
}
