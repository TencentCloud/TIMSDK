package com.tencent.qcloud.tuikit.tuisearch.util;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuisearch.R;
import com.tencent.qcloud.tuikit.tuisearch.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.DraftInfo;
import com.tencent.qcloud.tuikit.tuisearch.bean.MessageInfo;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class ConversationUtils {
    private static final String TAG = ConversationUtils.class.getSimpleName();

    public static final String SP_IMAGE = "_conversation_group_face";

    public static List<ConversationInfo> convertV2TIMConversationList(List<V2TIMConversation> conversationList) {
        List<ConversationInfo> conversationInfoList = new ArrayList<>();
        if (conversationList != null) {
            for (V2TIMConversation conversation : conversationList) {
                conversationInfoList.add(convertV2TIMConversation(conversation));
            }
        }
        return conversationInfoList;
    }

    public static ConversationInfo convertV2TIMConversation(final V2TIMConversation conversation) {
        if (conversation == null) {
            return null;
        }
        TUISearchLog.i(TAG,
            "TIMConversation2ConversationInfo id:" + conversation.getConversationID() + "|name:" + conversation.getShowName()
                + "|unreadNum:" + conversation.getUnreadCount());
        final ConversationInfo info = new ConversationInfo();
        int type = conversation.getType();
        if (type != V2TIMConversation.V2TIM_C2C && type != V2TIMConversation.V2TIM_GROUP) {
            return null;
        }


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
        }
        MessageInfo messageInfo = MessageInfoUtil.convertTIMMessage2MessageInfo(message);
        if (messageInfo != null) {
            info.setLastMessage(messageInfo);
        }

        int atInfoType = getAtInfoType(conversation);
        switch (atInfoType) {
            case V2TIMGroupAtInfo.TIM_AT_ME:
                info.setAtInfoText(ServiceInitializer.getAppContext().getString(R.string.ui_at_me));
                break;
            case V2TIMGroupAtInfo.TIM_AT_ALL:
                info.setAtInfoText(ServiceInitializer.getAppContext().getString(R.string.ui_at_all));
                break;
            case V2TIMGroupAtInfo.TIM_AT_ALL_AT_ME:
                info.setAtInfoText(ServiceInitializer.getAppContext().getString(R.string.ui_at_all_me));
                break;
            default:
                info.setAtInfoText("");
                break;
        }

        boolean isGroup = type == V2TIMConversation.V2TIM_GROUP;
        info.setTitle(conversation.getShowName());
        if (isGroup) {
            fillConversationUrlForGroup(conversation, info);
        } else {
            List<Object> faceList = new ArrayList<>();
            if (TextUtils.isEmpty(conversation.getFaceUrl())) {
                faceList.add(
                    TUIThemeManager.getAttrResId(ServiceInitializer.getAppContext(), com.tencent.qcloud.tuikit.timcommon.R.attr.core_default_user_icon));
            } else {
                faceList.add(conversation.getFaceUrl());
                info.setIconPath(conversation.getFaceUrl());
            }
            info.setIconUrlList(faceList);
        }
        if (isGroup) {
            info.setId(conversation.getGroupID());
            info.setGroupType(conversation.getGroupType());
        } else {
            info.setId(conversation.getUserID());
        }

        info.setShowDisturbIcon(conversation.getRecvOpt() == V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE ? true : false);
        info.setConversationId(conversation.getConversationID());
        info.setGroup(isGroup);
        if (!V2TIMManager.GROUP_TYPE_AVCHATROOM.equals(conversation.getGroupType())) {
            info.setUnRead(conversation.getUnreadCount());
        }
        info.setTop(conversation.isPinned());
        info.setOrderKey(conversation.getOrderKey());
        return info;
    }

    private static int getAtInfoType(V2TIMConversation conversation) {
        int atInfoType = 0;
        boolean atMe = false;
        boolean atAll = false;

        List<V2TIMGroupAtInfo> atInfoList = conversation.getGroupAtInfoList();

        if (atInfoList == null || atInfoList.isEmpty()) {
            return V2TIMGroupAtInfo.TIM_AT_UNKNOWN;
        }

        for (V2TIMGroupAtInfo atInfo : atInfoList) {
            if (atInfo.getAtType() == V2TIMGroupAtInfo.TIM_AT_ME) {
                atMe = true;
                continue;
            }
            if (atInfo.getAtType() == V2TIMGroupAtInfo.TIM_AT_ALL) {
                atAll = true;
                continue;
            }
            if (atInfo.getAtType() == V2TIMGroupAtInfo.TIM_AT_ALL_AT_ME) {
                atMe = true;
                atAll = true;
                continue;
            }
        }

        if (atAll && atMe) {
            atInfoType = V2TIMGroupAtInfo.TIM_AT_ALL_AT_ME;
        } else if (atAll) {
            atInfoType = V2TIMGroupAtInfo.TIM_AT_ALL;
        } else if (atMe) {
            atInfoType = V2TIMGroupAtInfo.TIM_AT_ME;
        } else {
            atInfoType = V2TIMGroupAtInfo.TIM_AT_UNKNOWN;
        }

        return atInfoType;
    }

    private static void fillConversationUrlForGroup(final V2TIMConversation conversation, final ConversationInfo info) {
        if (TextUtils.isEmpty(conversation.getFaceUrl())) {
            final String savedIcon = getGroupConversationAvatar(conversation.getConversationID());
            if (TextUtils.isEmpty(savedIcon)) {
                fillFaceUrlList(conversation.getGroupID(), info);
            } else {
                List<Object> list = new ArrayList<>();
                list.add(savedIcon);
                info.setIconUrlList(list);
            }
        } else {
            List<Object> list = new ArrayList<>();
            list.add(conversation.getFaceUrl());
            info.setIconUrlList(list);
        }
    }

    private static void fillFaceUrlList(final String groupID, final ConversationInfo info) {
        V2TIMManager.getGroupManager().getGroupMemberList(
            groupID, V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL, 0, new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
                @Override
                public void onError(int code, String desc) {
                    TUISearchLog.e(TAG, "getGroupMemberList failed! groupID:" + groupID + "|code:" + code + "|desc: " + desc);
                }

                @Override
                public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                    List<V2TIMGroupMemberFullInfo> v2TIMGroupMemberFullInfoList = v2TIMGroupMemberInfoResult.getMemberInfoList();
                    int faceSize = v2TIMGroupMemberFullInfoList.size() > 9 ? 9 : v2TIMGroupMemberFullInfoList.size();
                    List<Object> urlList = new ArrayList<>();
                    for (int i = 0; i < faceSize; i++) {
                        V2TIMGroupMemberFullInfo v2TIMGroupMemberFullInfo = v2TIMGroupMemberFullInfoList.get(i);
                        if (TextUtils.isEmpty(v2TIMGroupMemberFullInfo.getFaceUrl())) {
                            urlList.add(TUIThemeManager.getAttrResId(
                                ServiceInitializer.getAppContext(), com.tencent.qcloud.tuikit.timcommon.R.attr.core_default_user_icon));
                        } else {
                            urlList.add(v2TIMGroupMemberFullInfo.getFaceUrl());
                        }
                    }
                    info.setIconUrlList(urlList);
                }
            });
    }

    public static String getGroupConversationAvatar(String groupId) {
        final String savedIcon = SPUtils.getInstance(TUILogin.getSdkAppId() + SP_IMAGE).getString(groupId);
        if (!TextUtils.isEmpty(savedIcon) && new File(savedIcon).isFile() && new File(savedIcon).exists()) {
            return savedIcon;
        }
        return "";
    }
}
