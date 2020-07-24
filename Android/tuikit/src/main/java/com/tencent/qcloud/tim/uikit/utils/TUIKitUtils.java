package com.tencent.qcloud.tim.uikit.utils;

import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;

public class TUIKitUtils {

    public static boolean ignoreNotification(V2TIMMessage msg) {
        if (msg == null) {
            return false;
        }
        V2TIMCustomElem elem = msg.getCustomElem();
        if (elem == null) {
            return false;
        }
        byte[] bytes = elem.getData();
        if (bytes == null) {
            return false;
        }
        if (MessageInfoUtil.isTyping(bytes) || MessageInfoUtil.isOnlineIgnoredDialing(bytes)) {
            return true;
        }
        return false;
    }
}
