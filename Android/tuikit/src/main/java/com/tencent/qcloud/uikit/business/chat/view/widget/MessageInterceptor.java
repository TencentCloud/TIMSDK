package com.tencent.qcloud.uikit.business.chat.view.widget;


import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;

/**
 * Created by valexhuang on 2018/8/27.
 */

public interface MessageInterceptor {
    Object intercept(MessageInfo msg);
}
