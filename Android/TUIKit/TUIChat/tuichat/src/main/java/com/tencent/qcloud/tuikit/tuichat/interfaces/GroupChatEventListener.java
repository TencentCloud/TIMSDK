package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuikit.tuichat.bean.GroupMessageReceiptInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

import java.util.List;

/**
 * 其他模块与 Group 聊天模块的通信接口
 */
public interface GroupChatEventListener {

    void onGroupForceExit(String groupId);

    void onApplied(int unHandledSize);

    void handleRevoke(String msgId);

    void onRecvNewMessage(TUIMessageBean message);

    void onReadReport(List<GroupMessageReceiptInfo> receiptInfoList);

    void onGroupNameChanged(String groupId, String newName);

    void exitGroupChat(String chatId);

    void clearGroupMessage(String chatId);
}
