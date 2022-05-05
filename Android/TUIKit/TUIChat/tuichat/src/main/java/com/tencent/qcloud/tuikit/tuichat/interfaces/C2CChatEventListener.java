package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuikit.tuichat.bean.C2CMessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

import java.util.List;

/**
 * 其他模块与 C2C 聊天模块的通信接口
 */
public interface C2CChatEventListener {
    void onReadReport(List<C2CMessageReceiptInfo> receiptList);
    void handleRevoke(String msgId);
    void onRecvNewMessage(TUIMessageBean message);
    void exitC2CChat(String chatId);
    void onFriendNameChanged(String userId, String newName);

}
