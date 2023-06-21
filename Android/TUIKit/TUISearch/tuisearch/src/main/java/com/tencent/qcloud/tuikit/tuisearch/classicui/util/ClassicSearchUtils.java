package com.tencent.qcloud.tuikit.tuisearch.classicui.util;

import android.os.Bundle;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuisearch.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchUtils;

public class ClassicSearchUtils {
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
}
