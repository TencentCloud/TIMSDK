package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

import java.util.List;

/**
 * Group Chat event listener
 */
public abstract class GroupChatEventListener {

    public void onGroupForceExit(String groupId) {};

    public void onApplied(int unHandledSize) {}

    public void handleRevoke(String msgId) {}

    public void onRecvNewMessage(TUIMessageBean message) {}

    public void onReadReport(List<MessageReceiptInfo> receiptInfoList) {}

    public void onGroupNameChanged(String groupId, String newName) {}

    public void exitGroupChat(String chatId) {}

    public void clearGroupMessage(String chatId) {}

    public void onRecvMessageModified(TUIMessageBean messageBean) {}

    public void addMessage(TUIMessageBean messageBean, String chatId) {}

}
