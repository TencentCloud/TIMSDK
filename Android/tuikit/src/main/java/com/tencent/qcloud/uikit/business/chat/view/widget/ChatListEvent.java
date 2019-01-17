package com.tencent.qcloud.uikit.business.chat.view.widget;

import android.view.View;

import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;

/**
 * Created by valxehuang on 2018/7/18.
 */

public interface ChatListEvent {
    void onMessageLongClick(View view, int position, MessageInfo messageInfo);

    void onUserIconClick(View view, int position, MessageInfo messageInfo);
}
