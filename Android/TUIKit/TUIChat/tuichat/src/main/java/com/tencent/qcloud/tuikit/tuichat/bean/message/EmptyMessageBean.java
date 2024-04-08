package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

public class EmptyMessageBean extends TUIMessageBean {
    @Override
    public String onGetDisplayString() {
        return "";
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {

    }
}
