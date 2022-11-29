package com.tencent.qcloud.tuikit.tuichat.util;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ImageUtil;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

import java.io.File;

import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX;
import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_GROUP_PREFIX;

import android.text.TextUtils;

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

    public static String getOriginImagePath(final TUIMessageBean msg) {
        if (msg == null) {
            return null;
        }
        V2TIMMessage v2TIMMessage = msg.getV2TIMMessage();
        if (v2TIMMessage == null) {
            return null;
        }
        V2TIMImageElem v2TIMImageElem = v2TIMMessage.getImageElem();
        if (v2TIMImageElem == null) {
            return null;
        }
        String localImgPath = ChatMessageParser.getLocalImagePath(msg);
        if (localImgPath == null) {
            String originUUID = null;
            for(V2TIMImageElem.V2TIMImage image : v2TIMImageElem.getImageList()) {
                if (image.getType() == V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN) {
                    originUUID = image.getUUID();
                    break;
                }
            }
            String originPath = ImageUtil.generateImagePath(originUUID, V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN);
            File file = new File(originPath);
            if (file.exists()) {
                localImgPath = originPath;
            }
        }
        return localImgPath;
    }

    public static boolean isCommunityGroup(String groupID) {
        if (TextUtils.isEmpty(groupID)) {
            return false;
        }

        return groupID.startsWith("@TGS#_");

    }

    public static boolean isTopicGroup(String groupID) {
        // topicID 格式：@TGS#_xxxx@TOPIC#_xxxx
        if (!isCommunityGroup(groupID)) {
            return false;
        }
        return groupID.contains("@TOPIC#_");
    }

    public static String getGroupIDFromTopicID(String topicID) {
        // topicID 格式：@TGS#_xxxx@TOPIC#_xxxx
        int index = topicID.indexOf("@TOPIC#_");
        return topicID.substring(0, index);
    }

    public static long getServerTime() {
        return V2TIMManager.getInstance().getServerTime();
    }
}
