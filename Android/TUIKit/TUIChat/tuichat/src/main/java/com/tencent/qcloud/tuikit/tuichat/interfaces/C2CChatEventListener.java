package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

import java.util.List;

/**
 * C2C Chat event listener
 */
public abstract class C2CChatEventListener {
    public void onReadReport(List<MessageReceiptInfo> receiptList) {}
    public void handleRevoke(String msgId) {}
    public void onRecvNewMessage(TUIMessageBean message) {}
    public void exitC2CChat(String chatId) {}
    public void onFriendNameChanged(String userId, String newName) {}
    public void onRecvMessageModified(TUIMessageBean messageBean) {}
    public void addMessage(TUIMessageBean messageBean, String chatId) {}
    public void clearC2CMessage(String userID) {}

}
