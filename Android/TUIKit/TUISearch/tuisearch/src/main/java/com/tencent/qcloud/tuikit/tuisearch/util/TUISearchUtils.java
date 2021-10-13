package com.tencent.qcloud.tuikit.tuisearch.util;

import android.os.Bundle;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuisearch.bean.ChatInfo;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;

import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX;
import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_GROUP_PREFIX;


public class TUISearchUtils {

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, String module, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(module, errCode, desc);
        }
    }

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(null, errCode, desc);
        }
    }

    public static <T> void callbackOnSuccess(IUIKitCallback<T> callBack, T data) {
        if (callBack != null) {
            callBack.onSuccess(data);
        }
    }

    public static String getConversationIdByUserId(String id, boolean isGroup) {
        String conversationIdPrefix = isGroup ? CONVERSATION_GROUP_PREFIX : CONVERSATION_C2C_PREFIX;
        return conversationIdPrefix + id;
    }

    public static boolean isC2CChat(int chatType) {
        return chatType == V2TIMConversation.V2TIM_C2C;
    }

    public static boolean isGroupChat(int chatType) {
        return chatType == V2TIMConversation.V2TIM_GROUP;
    }

    public static void startChatActivity(ChatInfo chatInfo) {
        Bundle param = new Bundle();
        param.putInt(TUIConstants.TUIChat.CHAT_TYPE, chatInfo.getType());
        param.putString(TUIConstants.TUIChat.CHAT_ID, chatInfo.getId());
        param.putString(TUIConstants.TUIChat.CHAT_NAME, chatInfo.getChatName());
        if (chatInfo.getDraft() != null) {
            param.putString(TUIConstants.TUIChat.DRAFT_TEXT, chatInfo.getDraft().getDraftText());
            param.putLong(TUIConstants.TUIChat.DRAFT_TIME, chatInfo.getDraft().getDraftTime());
        }
        param.putBoolean(TUIConstants.TUIChat.IS_TOP_CHAT, chatInfo.isTopChat());
        if (chatInfo.getLocateMessage() != null && chatInfo.getLocateMessage().getTimMessage() != null) {
            param.putSerializable(TUIConstants.TUIChat.LOCATE_MESSAGE, chatInfo.getLocateMessage().getTimMessage());
        }
        if (TUISearchUtils.isGroupChat(chatInfo.getType())) {
            param.putString(TUIConstants.TUIChat.GROUP_TYPE, chatInfo.getGroupType());
        }
        if (TUISearchUtils.isGroupChat(chatInfo.getType())) {
            TUICore.startActivity(TUIConstants.TUIChat.GROUP_CHAT_ACTIVITY_NAME, param);
        } else {
            TUICore.startActivity(TUIConstants.TUIChat.C2C_CHAT_ACTIVITY_NAME, param);
        }
    }

    public static String getLoginUser() {
        return V2TIMManager.getInstance().getLoginUser();
    }

    public static boolean isUserLogined() {
        return V2TIMManager.getInstance().getLoginStatus() == V2TIMManager.V2TIM_STATUS_LOGINED;
    }
}
