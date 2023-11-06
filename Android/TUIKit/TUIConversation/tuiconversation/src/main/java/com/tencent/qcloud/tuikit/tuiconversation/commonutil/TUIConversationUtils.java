package com.tencent.qcloud.tuikit.tuiconversation.commonutil;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;

public class TUIConversationUtils {
    public static <T> void callbackOnError(IUIKitCallback<T> callBack, String module, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(module, errCode, ErrorMessageConverter.convertIMError(errCode, desc));
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

    public static boolean hasRiskContent(V2TIMMessage v2TIMMessage) {
        if (v2TIMMessage != null) {
            return v2TIMMessage.hasRiskContent() && v2TIMMessage.getStatus() != V2TIMMessage.V2TIM_MSG_STATUS_LOCAL_REVOKED;
        }
        return false;
    }
}
