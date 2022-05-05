package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMMessageReceipt;

public class GroupMessageReceiptInfo {
    private V2TIMMessageReceipt messageReceipt;

    public void setMessageReceipt(V2TIMMessageReceipt messageReceipt) {
        this.messageReceipt = messageReceipt;
    }

    public String getGroupID() {
        if (messageReceipt != null) {
            return messageReceipt.getGroupID();
        }
        return null;
    }

    public long getReadCount() {
        if (messageReceipt != null) {
            return messageReceipt.getReadCount();
        }
        return 0;
    }

    public long getUnreadCount() {
        if (messageReceipt != null) {
            return messageReceipt.getUnreadCount();
        }
        return 0;
    }

    public String getMsgID() {
        if (messageReceipt != null) {
            return messageReceipt.getMsgID();
        }
        return null;
    }
}
