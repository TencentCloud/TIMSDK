package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

/**
 * 其他模块与 Group 聊天模块的通信接口
 */
public interface GroupChatEventListener {

    void onGroupForceExit(String groupId);

    void onApplied(int unHandledSize);

    void handleRevoke(String msgId);

    void onRecvNewMessage(TUIMessageBean message);

    void onGroupNameChanged(String groupId, String newName);

    void exitGroupChat(String chatId);
}
