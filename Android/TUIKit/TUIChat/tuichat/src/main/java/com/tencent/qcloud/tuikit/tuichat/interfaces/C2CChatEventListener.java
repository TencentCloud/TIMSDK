package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReceiptInfo;

import java.util.List;

/**
 * 其他模块与 C2C 聊天模块的通信接口
 */
public interface C2CChatEventListener {
    void onReadReport(List<MessageReceiptInfo> receiptList);
    void handleRevoke(String msgId);
    void onRecvNewMessage(MessageInfo message);
    void exitC2CChat(String chatId);
    void onFriendNameChanged(String userId, String newName);

}
