package com.tencent.qcloud.tuikit.timcommon.util;

import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX;
import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_GROUP_PREFIX;

import android.text.TextUtils;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

public class TIMCommonUtil {
    public static String getConversationIdByID(String chatID, boolean isGroup) {
        String conversationIdPrefix = isGroup ? CONVERSATION_GROUP_PREFIX : CONVERSATION_C2C_PREFIX;
        return conversationIdPrefix + chatID;
    }

    public static boolean isChatbot(String chatID) {
        return chatID.startsWith("@RBT#");
    }

    public static boolean isOfficialAccount(String userID) {
        return userID.startsWith("@TOA#_");
    }

    public static boolean isOfficialAccountConversation(String conversationID) {
        return conversationID.startsWith("c2c_@TOA#_");
    }

    public static boolean isOfficialAccountChat(TUIMessageBean msg) {
        if (msg == null) {
            return false;
        }
        String userId = msg.getUserId();
        if (!TextUtils.isEmpty(userId) && isOfficialAccount(userId)) {
            return true;
        }
        String sender = msg.getSender();
        return !TextUtils.isEmpty(sender) && isOfficialAccount(sender);
    }
}