package com.tencent.qcloud.tuikit.timcommon.interfaces;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;

public abstract class ChatInputMoreListener {
    public String sendMessage(TUIMessageBean msg, IUIKitCallback<TUIMessageBean> callback) {
        return null;
    }
}
