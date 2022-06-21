package com.tencent.qcloud.tuikit.tuiconversation.util;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.bean.DraftInfo;

import java.util.ArrayList;
import java.util.List;

public class ConversationUtils {
    private static final String TAG = ConversationUtils.class.getSimpleName();

    public static List<ConversationInfo> convertV2TIMConversationList(List<V2TIMConversation> conversationList) {
        List<ConversationInfo> conversationInfoList = new ArrayList<>();
        if (conversationList != null) {
            for(V2TIMConversation conversation : conversationList) {
                conversationInfoList.add(convertV2TIMConversation(conversation));
            }
        }
        return conversationInfoList;
    }

    /**
     * V2TIMConversation 转换为 ConversationInfo
     *
     * @param conversation V2TIMConversation
     * @return ConversationInfo
     */
    public static ConversationInfo convertV2TIMConversation(final V2TIMConversation conversation) {
        if (conversation == null) {
            return null;
        }
        TUIConversationLog.i(TAG, "TIMConversation2ConversationInfo id:" + conversation.getConversationID()
                + "|name:" + conversation.getShowName()
                + "|unreadNum:" + conversation.getUnreadCount());
        final ConversationInfo info = new ConversationInfo();
        info.setConversation(conversation);
        int type = conversation.getType();
        if (type != V2TIMConversation.V2TIM_C2C && type != V2TIMConversation.V2TIM_GROUP) {
            return null;
        }

        boolean isGroup = type == V2TIMConversation.V2TIM_GROUP;

        String draftText = conversation.getDraftText();
        if (!TextUtils.isEmpty(draftText)) {
            DraftInfo draftInfo = new DraftInfo();
            draftInfo.setDraftText(draftText);
            draftInfo.setDraftTime(conversation.getDraftTimestamp());
            info.setDraft(draftInfo);
        }
        V2TIMMessage message = conversation.getLastMessage();
        if (message == null) {
            long time = DateTimeUtil.getStringToDate("0001-01-01 00:00:00", "yyyy-MM-dd HH:mm:ss");
            info.setLastMessageTime(time);
        } else {
            info.setLastMessageTime(message.getTimestamp());
            info.setLastMessage(message);
        }

        int atInfoType = getAtInfoType(conversation);
        switch (atInfoType){
            case V2TIMGroupAtInfo.TIM_AT_ME:
                info.setAtInfoText(TUIConversationService.getAppContext().getString(R.string.ui_at_me));
                break;
            case V2TIMGroupAtInfo.TIM_AT_ALL:
                info.setAtInfoText(TUIConversationService.getAppContext().getString(R.string.ui_at_all));
                break;
            case V2TIMGroupAtInfo.TIM_AT_ALL_AT_ME:
                info.setAtInfoText(TUIConversationService.getAppContext().getString(R.string.ui_at_all_me));
                break;
            default:
                info.setAtInfoText("");
                break;

        }

        info.setTitle(conversation.getShowName());
        List<Object> faceList = new ArrayList<>();
        if (isGroup) {
            if (!TextUtils.isEmpty(conversation.getFaceUrl())) {
                faceList.add(conversation.getFaceUrl());
            }
        } else {
            if (TextUtils.isEmpty(conversation.getFaceUrl())) {
                faceList.add(TUIThemeManager.getAttrResId(TUIConversationService.getAppContext(), R.attr.core_default_user_icon));
            } else {
                faceList.add(conversation.getFaceUrl());
            }
        }
        info.setIconPath(conversation.getFaceUrl());
        info.setIconUrlList(faceList);

        if (isGroup) {
            info.setId(conversation.getGroupID());
            info.setGroupType(conversation.getGroupType());
        } else {
            info.setId(conversation.getUserID());
        }

        if (V2TIMManager.GROUP_TYPE_MEETING.equals(conversation.getGroupType())) {
            info.setShowDisturbIcon(false);
        } else {
            info.setShowDisturbIcon(conversation.getRecvOpt() == V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE);
        }
        info.setConversationId(conversation.getConversationID());
        info.setGroup(isGroup);
        // AVChatRoom 不支持未读数。
        if (!V2TIMManager.GROUP_TYPE_AVCHATROOM.equals(conversation.getGroupType())) {
            info.setUnRead(conversation.getUnreadCount());
        }
        info.setTop(conversation.isPinned());
        info.setOrderKey(conversation.getOrderKey());
        return info;
    }

    private static int getAtInfoType(V2TIMConversation conversation){
        int atInfoType = 0;
        boolean atMe = false;
        boolean atAll = false;

        List<V2TIMGroupAtInfo> atInfoList = conversation.getGroupAtInfoList();

        if (atInfoList == null || atInfoList.isEmpty()){
            return V2TIMGroupAtInfo.TIM_AT_UNKNOWN;
        }

        for(V2TIMGroupAtInfo atInfo : atInfoList){
            if (atInfo.getAtType() == V2TIMGroupAtInfo.TIM_AT_ME){
                atMe = true;
                continue;
            }
            if (atInfo.getAtType() == V2TIMGroupAtInfo.TIM_AT_ALL){
                atAll = true;
                continue;
            }
            if (atInfo.getAtType() == V2TIMGroupAtInfo.TIM_AT_ALL_AT_ME){
                atMe = true;
                atAll = true;
                continue;
            }
        }

        if (atAll && atMe){
            atInfoType = V2TIMGroupAtInfo.TIM_AT_ALL_AT_ME;
        } else if (atAll){
            atInfoType = V2TIMGroupAtInfo.TIM_AT_ALL;
        } else if (atMe){
            atInfoType = V2TIMGroupAtInfo.TIM_AT_ME;
        } else {
            atInfoType = V2TIMGroupAtInfo.TIM_AT_UNKNOWN;
        }

        return atInfoType;
    }

    public static boolean isNeedUpdate(ConversationInfo conversationInfo) {
        return V2TIMManager.GROUP_TYPE_AVCHATROOM.equals(conversationInfo.getGroupType());
    }

}
