package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMMessageReceipt;

public class C2CMessageReceiptInfo {
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

    /**
     * 获取已读时间戳
     *
     * @return 已读时间戳
     */
    public long getTimestamp() {
        if (messageReceipt != null) {
            return messageReceipt.getTimestamp();
        }
        return 0;
    }
}
