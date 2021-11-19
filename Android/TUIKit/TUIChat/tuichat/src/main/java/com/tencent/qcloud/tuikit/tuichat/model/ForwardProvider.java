package com.tencent.qcloud.tuikit.tuichat.model;

import com.tencent.imsdk.v2.V2TIMMergerElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.List;

public class ForwardProvider {
    public void downloadMergerMessage(MergeMessageBean messageBean, IUIKitCallback<List<TUIMessageBean>> callback) {
        V2TIMMergerElem mergerElem = messageBean.getMergerElem();
        if (mergerElem != null) {
            mergerElem.downloadMergerMessage(new V2TIMValueCallback<List<V2TIMMessage>>() {
                @Override
                public void onSuccess(List<V2TIMMessage> messageList) {
                    List<TUIMessageBean> messageInfoList = ChatMessageParser.parseMessageList(messageList);
                    TUIChatUtils.callbackOnSuccess(callback, messageInfoList);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatUtils.callbackOnError(callback, "MergeMessageElemBean", code, desc);
                }
            });
        }
    }
}
