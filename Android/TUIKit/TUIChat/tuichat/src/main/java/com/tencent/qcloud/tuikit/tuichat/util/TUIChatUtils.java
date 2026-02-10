package com.tencent.qcloud.tuikit.tuichat.util;

import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX;
import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_GROUP_PREFIX;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.GifSpan;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.ChatEventListener;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIChatUtils {
    public static <T> void callbackOnError(IUIKitCallback<T> callBack, String module, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(module, errCode, ErrorMessageConverter.convertIMError(errCode, desc));
        }
    }

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, int errCode, String desc, T data) {
        if (callBack != null) {
            callBack.onError(errCode, ErrorMessageConverter.convertIMError(errCode, desc), data);
        }
    }

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(null, errCode, ErrorMessageConverter.convertIMError(errCode, desc));
        }
    }

    public static <T> void callbackOnSuccess(IUIKitCallback<T> callBack, T data) {
        if (callBack != null) {
            callBack.onSuccess(data);
        }
    }

    public static void callbackOnProgress(IUIKitCallback callBack, Object data) {
        if (callBack != null) {
            callBack.onProgress(data);
        }
    }

    public static String getConversationIdByChatId(String id, boolean isGroup) {
        String conversationIdPrefix = isGroup ? CONVERSATION_GROUP_PREFIX : CONVERSATION_C2C_PREFIX;
        return conversationIdPrefix + id;
    }

    public static boolean isC2CChat(int chatType) {
        return chatType == V2TIMConversation.V2TIM_C2C;
    }

    public static boolean isGroupChat(int chatType) {
        return chatType == V2TIMConversation.V2TIM_GROUP;
    }

    public static boolean isCommunityGroup(String groupID) {
        if (TextUtils.isEmpty(groupID)) {
            return false;
        }

        return groupID.startsWith("@TGS#_");
    }

    public static boolean isTopicGroup(String groupID) {
        if (!isCommunityGroup(groupID)) {
            return false;
        }
        return groupID.contains("@TOPIC#_");
    }

    public static String getGroupIDFromTopicID(String topicID) {
        int index = topicID.indexOf("@TOPIC#_");
        return topicID.substring(0, index);
    }

    public static long getServerTime() {
        return V2TIMManager.getInstance().getServerTime();
    }

    public static boolean chatEventOnUserIconClicked(View view, TUIMessageBean messageBean) {
        ChatEventListener chatEventListener = TUIChatConfigs.getChatEventConfig().getChatEventListener();
        if (chatEventListener != null) {
            return chatEventListener.onUserIconClicked(view, messageBean);
        }
        return false;
    }

    public static boolean chatEventOnUserIconLongClicked(View view, TUIMessageBean messageBean) {
        ChatEventListener chatEventListener = TUIChatConfigs.getChatEventConfig().getChatEventListener();
        if (chatEventListener != null) {
            return chatEventListener.onUserIconLongClicked(view, messageBean);
        }
        return false;
    }

    public static boolean chatEventOnMessageClicked(View view, TUIMessageBean messageBean) {
        ChatEventListener chatEventListener = TUIChatConfigs.getChatEventConfig().getChatEventListener();
        if (chatEventListener != null) {
            return chatEventListener.onMessageClicked(view, messageBean);
        }
        return false;
    }

    public static boolean chatEventOnMessageLongClicked(View view, TUIMessageBean messageBean) {
        ChatEventListener chatEventListener = TUIChatConfigs.getChatEventConfig().getChatEventListener();
        if (chatEventListener != null) {
            return chatEventListener.onMessageLongClicked(view, messageBean);
        }
        return false;
    }

    public static void notifyProcessMessage(List<TUIMessageBean> messageBeans) {
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Event.MessageStatus.MESSAGE_LIST, messageBeans);
        TUICore.notifyEvent(TUIConstants.TUIChat.Event.MessageStatus.KEY, TUIConstants.TUIChat.Event.MessageStatus.SUB_KEY_PROCESS_MESSAGE, param);
    }

    public static String convertGroupTypeText(String groupType) {
        String groupText = "";
        if (TextUtils.isEmpty(groupType)) {
            return groupText;
        }
        if (TextUtils.equals(groupType, V2TIMManager.GROUP_TYPE_WORK)) {
            groupText = TUIChatService.getAppContext().getString(R.string.private_group);
        } else if (TextUtils.equals(groupType, V2TIMManager.GROUP_TYPE_PUBLIC)) {
            groupText = TUIChatService.getAppContext().getString(R.string.public_group);
        } else if (TextUtils.equals(groupType, V2TIMManager.GROUP_TYPE_MEETING) || TextUtils.equals(groupType, V2TIMManager.GROUP_TYPE_AVCHATROOM)) {
            groupText = TUIChatService.getAppContext().getString(R.string.chat_room);
        } else if (TextUtils.equals(groupType, TUIConstants.GroupType.TYPE_COMMUNITY)) {
            groupText = TUIChatService.getAppContext().getString(R.string.community_group);
        }
        return groupText;
    }

    @NonNull
    public static SpannableString getWaitingSpan(Context context) {
        SpannableString spannableString = new SpannableString("a");
        Drawable drawable;
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.Q) {
            drawable = ContextCompat.getDrawable(context, R.drawable.chat_chatbot_waiting_icon);
        } else {
            drawable = ContextCompat.getDrawable(context, R.drawable.chat_chatbot_waiting_icon_static);
        }
        int width = ScreenUtil.dip2px(24);
        int height = ScreenUtil.dip2px(24);
        drawable.setBounds(0, 0, width, height);
        GifSpan gifSpan = new GifSpan(drawable);
        spannableString.setSpan(gifSpan, 0, 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        return spannableString;
    }

    public static int[] calculateOptimalSizePx(int originalWidth, int originalHeight) {
        return calculateOptimalSizePx(originalWidth, originalHeight, 190, 80, 0.5f, 2.0f);
    }

    public static int[] calculateOptimalSizePx(
            int originalWidth,
            int originalHeight,
            int maxSizeDp,
            int minSizeDp,
            float minAspectRatio,
            float maxAspectRatio
    ) {
        int maxSizePx = ScreenUtil.dip2px(maxSizeDp);
        int minSizePx = ScreenUtil.dip2px(minSizeDp);

        if (originalWidth <= 0 || originalHeight <= 0) {
            return new int[] {maxSizePx, maxSizePx};
        }

        float aspectRatio = originalWidth / (float) originalHeight;

        if (aspectRatio < minAspectRatio) {
            aspectRatio = minAspectRatio;
        } else if (aspectRatio > maxAspectRatio) {
            aspectRatio = maxAspectRatio;
        }

        int displayWidth;
        int displayHeight;

        if (aspectRatio >= 1) {
            displayWidth = Math.min(originalWidth, maxSizePx);
            displayWidth = Math.max(displayWidth, minSizePx);
            displayHeight = Math.round(displayWidth / aspectRatio);
            if (displayHeight < minSizePx) {
                displayHeight = minSizePx;
                displayWidth = Math.round(displayHeight * aspectRatio);
                displayWidth = Math.min(displayWidth, maxSizePx);
            }
        } else {
            displayHeight = Math.min(originalHeight, maxSizePx);
            displayHeight = Math.max(displayHeight, minSizePx);
            displayWidth = Math.round(displayHeight * aspectRatio);
            if (displayWidth < minSizePx) {
                displayWidth = minSizePx;
                displayHeight = Math.round(displayWidth / aspectRatio);
                displayHeight = Math.min(displayHeight, maxSizePx);
            }
        }

        displayWidth = Math.min(displayWidth, maxSizePx);
        displayHeight = Math.min(displayHeight, maxSizePx);

        return new int[] {displayWidth, displayHeight};
    }
}
