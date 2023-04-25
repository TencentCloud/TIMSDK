package com.tencent.qcloud.tuikit.timcommon.bean;

import com.tencent.imsdk.v2.V2TIMMessageReceipt;

import java.io.Serializable;

public class MessageReceiptInfo implements Serializable {
    private V2TIMMessageReceipt messageReceipt;

    public void setMessageReceipt(V2TIMMessageReceipt messageReceipt) {
        this.messageReceipt = messageReceipt;
    }

    public String getUserID() {
        if (messageReceipt != null) {
            return messageReceipt.getUserID();
        }
        return null;
    }

    public boolean isPeerRead() {
        if (messageReceipt != null) {
            return messageReceipt.isPeerRead();
        }
        return false;
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
