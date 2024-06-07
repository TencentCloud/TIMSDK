package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageReceiptInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;

import java.util.List;

/**
 * Group Chat event listener
 */
public abstract class GroupChatEventListener {
    public void onGroupForceExit(String groupId) {}

    public void onApplied() {}

    public void onRecvMessageRevoked(String msgID, UserBean userBean, String reason) {}

    public void onRecvNewMessage(TUIMessageBean message) {}

    public void onReadReport(List<MessageReceiptInfo> receiptInfoList) {}

    public void onGroupNameChanged(String groupId, String newName) {}

    public void onGroupFaceUrlChanged(String groupId, String faceUrl) {}

    public void exitGroupChat(String chatId) {}

    public void clearGroupMessage(String chatId) {}
    
    public void onRecvMessageModified(TUIMessageBean messageBean) {}

    public void addMessage(TUIMessageBean messageBean, String chatId) {}

    public void onMessageChanged(TUIMessageBean messageBean, int dataChangeType) {}

    public void onGroupMessagePinned(String groupID, TUIMessageBean messageBean, UserBean opUser) {}

    public void onGroupMessageUnPinned(String groupID, String messageID, UserBean opUser) {}

    public void onGrantGroupAdmin(String groupID, List<String> newAdminUserIDList) {}

    public void onRevokeGroupAdmin(String groupID, List<String> oldAdminUserIDList) {}

    public void onGrantGroupOwner(String groupID, String groupOwner) {}
}
