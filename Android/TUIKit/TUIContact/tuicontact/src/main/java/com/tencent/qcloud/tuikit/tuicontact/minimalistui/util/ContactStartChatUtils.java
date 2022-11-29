package com.tencent.qcloud.tuikit.tuicontact.minimalistui.util;

import android.os.Bundle;
import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMConversation;
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
        if (isGroupChat(chatType)) {
            TUICore.startActivity("TUIGroupChatMinimalistActivity", bundle);
        } else {
            TUICore.startActivity("TUIC2CChatMinimalistActivity", bundle);
        }
    }

}
