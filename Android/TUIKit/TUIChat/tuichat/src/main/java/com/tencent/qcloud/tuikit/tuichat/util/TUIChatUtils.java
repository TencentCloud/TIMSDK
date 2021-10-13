package com.tencent.qcloud.tuikit.tuichat.util;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ImageUtil;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;

import java.io.File;

import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_C2C_PREFIX;
import static com.tencent.qcloud.tuicore.TUIConstants.TUIConversation.CONVERSATION_GROUP_PREFIX;

public class TUIChatUtils {

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

    /**
     * 获取 MessageInfo 中原图的路径
     * @param msg
     * @return
     */
    public static String getOriginImagePath(final MessageInfo msg) {
        if (msg == null) {
            return null;
        }
        V2TIMMessage v2TIMMessage = msg.getTimMessage();
        if (v2TIMMessage == null) {
            return null;
        }
        V2TIMImageElem v2TIMImageElem = v2TIMMessage.getImageElem();
        if (v2TIMImageElem == null) {
            return null;
        }
        String localImgPath = ChatMessageInfoUtil.getLocalImagePath(msg);
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

}
