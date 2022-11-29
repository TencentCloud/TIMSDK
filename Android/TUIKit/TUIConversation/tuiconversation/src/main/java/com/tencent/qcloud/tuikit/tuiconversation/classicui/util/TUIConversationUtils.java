package com.tencent.qcloud.tuikit.tuiconversation.classicui.util;

import android.os.Bundle;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;

import java.io.Serializable;

public class TUIConversationUtils {
    public static void startChatActivity(ConversationInfo conversationInfo) {
        Bundle param = new Bundle();
        param.putInt(TUIConstants.TUIChat.CHAT_TYPE, conversationInfo.isGroup() ? V2TIMConversation.V2TIM_GROUP : V2TIMConversation.V2TIM_C2C);
        param.putString(TUIConstants.TUIChat.CHAT_ID, conversationInfo.getId());
        param.putString(TUIConstants.TUIChat.CHAT_NAME, conversationInfo.getTitle());
        if (conversationInfo.getDraft() != null) {
            param.putString(TUIConstants.TUIChat.DRAFT_TEXT, conversationInfo.getDraft().getDraftText());
            param.putLong(TUIConstants.TUIChat.DRAFT_TIME, conversationInfo.getDraft().getDraftTime());
        }
        param.putBoolean(TUIConstants.TUIChat.IS_TOP_CHAT, conversationInfo.isTop());
        param.putString(TUIConstants.TUIChat.FACE_URL, conversationInfo.getIconPath());
        if (conversationInfo.isGroup()) {
            param.putString(TUIConstants.TUIChat.GROUP_TYPE, conversationInfo.getGroupType());
            param.putSerializable(TUIConstants.TUIChat.AT_INFO_LIST, (Serializable) conversationInfo.getGroupAtInfoList());
        }
        if (conversationInfo.isGroup()) {
            TUICore.startActivity(TUIConstants.TUIChat.GROUP_CHAT_ACTIVITY_NAME, param);
        } else {
            TUICore.startActivity(TUIConstants.TUIChat.C2C_CHAT_ACTIVITY_NAME, param);
        }
    }
}
