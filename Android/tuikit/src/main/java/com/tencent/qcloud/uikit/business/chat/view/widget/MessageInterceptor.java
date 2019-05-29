package com.tencent.qcloud.uikit.business.chat.view.widget;


import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;


public interface MessageInterceptor {
    Object intercept(MessageInfo msg);
}
