package com.tencent.qcloud.tuikit.tuicontact.classicui.util;

import android.os.Bundle;
import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;

public class ContactStartChatUtils {
    public static boolean isC2CChat(int chatType) {
        return chatType == V2TIMConversation.V2TIM_C2C;
    }

    public static boolean isGroupChat(int chatType) {
        return chatType == V2TIMConversation.V2TIM_GROUP;
    }

    public static void startChatActivity(String chatId, int chatType, String chatName, String groupType) {
        if (TextUtils.isEmpty(chatId)) {
            return;
        }
        Bundle bundle = new Bundle();
        bundle.putString(TUIConstants.TUIChat.CHAT_ID, chatId);
        bundle.putString(TUIConstants.TUIChat.CHAT_NAME, chatName);
        bundle.putInt(TUIConstants.TUIChat.CHAT_TYPE, chatType);
        if (isC2CChat(chatType)) {
            TUICore.startActivity(TUIConstants.TUIChat.C2C_CHAT_ACTIVITY_NAME, bundle);
        } else if (isGroupChat(chatType)) {
            bundle.putString(TUIConstants.TUIChat.GROUP_TYPE, groupType);
            TUICore.startActivity(TUIConstants.TUIChat.GROUP_CHAT_ACTIVITY_NAME, bundle);
        }
    }

    public static String getLoginUser() {
        return V2TIMManager.getInstance().getLoginUser();
    }
}
