package com.tencent.qcloud.tuikit.tuisearch.minimalistui.util;

import android.os.Bundle;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuisearch.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuisearch.util.TUISearchUtils;

public class MinimalistSearchUtils {
    public static void startChatActivity(ChatInfo chatInfo) {
        Bundle param = new Bundle();
        param.putInt(TUIConstants.TUIChat.CHAT_TYPE, chatInfo.getType());
        param.putString(TUIConstants.TUIChat.CHAT_ID, chatInfo.getId());
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
            TUICore.startActivity("TUIGroupChatMinimalistActivity", param);
        } else {
            TUICore.startActivity("TUIC2CChatMinimalistActivity", param);
        }
    }
}
