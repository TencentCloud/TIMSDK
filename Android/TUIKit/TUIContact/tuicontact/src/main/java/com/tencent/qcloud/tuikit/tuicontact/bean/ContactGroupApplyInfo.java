package com.tencent.qcloud.tuikit.tuicontact.bean;

import com.tencent.imsdk.v2.V2TIMGroupApplication;

import java.io.Serializable;

public class ContactGroupApplyInfo implements Serializable {
    private String fromUser;
    private String fromUserNickName;
    private String requestMsg;
    private V2TIMGroupApplication timGroupApplication;

    public String getFromUser() {
        return fromUser;
    }

    public void setFromUser(String fromUser) {
        this.fromUser = fromUser;
    }

    public String getFromUserNickName() {
        return fromUserNickName;
    }

    public void setFromUserNickName(String fromUserNickName) {
        this.fromUserNickName = fromUserNickName;
    }

    public String getRequestMsg() {
        return requestMsg;
    }

    public void setRequestMsg(String requestMsg) {
        this.requestMsg = requestMsg;
    }

    public void setTimGroupApplication(V2TIMGroupApplication timGroupApplication) {
        this.timGroupApplication = timGroupApplication;
    }

    public V2TIMGroupApplication getTimGroupApplication() {
        return timGroupApplication;
    }
}
