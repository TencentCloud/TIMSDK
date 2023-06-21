package com.tencent.qcloud.tuikit.tuiconversation.commonutil;

import android.text.TextUtils;
import android.view.View;
import android.widget.ListView;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopDialogAdapter;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.bean.DraftInfo;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;

public class ConversationUtils {
    private static final String TAG = ConversationUtils.class.getSimpleName();

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
        TUIConversationLog.i(TAG,
            "TIMConversation2ConversationInfo id:" + conversation.getConversationID() + "|name:" + conversation.getShowName()
                + "|unreadNum:" + conversation.getUnreadCount());
        final ConversationInfo info = new ConversationInfo();
        info.setConversation(conversation);
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
            info.setLastMessage(message);
        }

        int atInfoType = getAtInfoType(conversation);
        switch (atInfoType) {
            case V2TIMGroupAtInfo.TIM_AT_ME:
                info.setAtInfoText(TUIConversationService.getAppContext().getString(R.string.ui_at_me));
                info.setAtType(ConversationInfo.AT_TYPE_AT_ME);
                break;
            case V2TIMGroupAtInfo.TIM_AT_ALL:
                info.setAtInfoText(TUIConversationService.getAppContext().getString(R.string.ui_at_all));
                info.setAtType(ConversationInfo.AT_TYPE_AT_ALL);
                break;
            case V2TIMGroupAtInfo.TIM_AT_ALL_AT_ME:
                info.setAtInfoText(TUIConversationService.getAppContext().getString(R.string.ui_at_all_me));
                info.setAtType(ConversationInfo.AT_TYPE_AT_ALL_AND_ME);
                break;
            default:
                info.setAtInfoText("");
                break;
        }

        info.setTitle(conversation.getShowName());
        List<Object> faceList = new ArrayList<>();
        boolean isGroup = type == V2TIMConversation.V2TIM_GROUP;
        if (isGroup) {
            if (!TextUtils.isEmpty(conversation.getFaceUrl())) {
                faceList.add(conversation.getFaceUrl());
            }
        } else {
            if (TextUtils.isEmpty(conversation.getFaceUrl())) {
                faceList.add(TUIConfig.getDefaultAvatarImage());
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

        if (!V2TIMManager.GROUP_TYPE_AVCHATROOM.equals(conversation.getGroupType())) {
            info.setUnRead(conversation.getUnreadCount());
        }
        info.setTop(conversation.isPinned());
        info.setOrderKey(conversation.getOrderKey());
        if (conversation.getMarkList() != null) {
            if (conversation.getMarkList().contains(V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_FOLD)) {
                info.setMarkFold(true);
            } else {
                info.setMarkFold(false);
            }
            if (conversation.getMarkList().contains(V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_UNREAD)) {
                info.setMarkUnread(true);
            } else {
                info.setMarkUnread(false);
            }
            if (conversation.getMarkList().contains(V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_HIDE)) {
                info.setMarkHidden(true);
            } else {
                info.setMarkHidden(false);
            }
            if (conversation.getMarkList().contains(V2TIMConversation.V2TIM_CONVERSATION_MARK_TYPE_STAR)) {
                info.setMarkStar(true);
            } else {
                info.setMarkStar(false);
            }
        }
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

    public static boolean isIgnored(ConversationInfo conversationInfo) {
        if (V2TIMManager.GROUP_TYPE_AVCHATROOM.equals(conversationInfo.getGroupType())) {
            return true;
        }

        return false;
    }

    public static int getListUnspecifiedWidth(PopDialogAdapter adapter, ListView listView) {
        if (adapter == null || listView == null) {
            return 0;
        }
        int maxWidth = 0;
        View convertView = null;
        int childCount = adapter.getCount();
        if (childCount <= 0) {
            return 0;
        }
        for (int i = 0; i < childCount; i++) {
            View child = adapter.getView(i, convertView, listView);
            child.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
            maxWidth = Math.max(maxWidth, child.getMeasuredWidth() + child.getPaddingLeft() + child.getPaddingRight());
            convertView = child;
        }
        return maxWidth;
    }

    public static void checkRepeatForList(List<?> list) {
        if (list == null || list.isEmpty()) {
            return;
        }
        LinkedHashSet hashSet = new LinkedHashSet<>(list);
        list.clear();
        list.addAll(hashSet);
    }

    public static String getConversationAllGroupName() {
        return TUIConversationService.getAppContext().getResources().getString(R.string.conversation_page_all);
    }
}
