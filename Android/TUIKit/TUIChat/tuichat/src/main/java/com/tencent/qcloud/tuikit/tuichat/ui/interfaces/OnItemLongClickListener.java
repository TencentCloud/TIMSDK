package com.tencent.qcloud.tuikit.tuichat.ui.interfaces;

import android.view.View;

import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;

public interface OnItemLongClickListener {
    void onMessageLongClick(View view, int position, MessageInfo messageInfo);

    void onUserIconClick(View view, int position, MessageInfo messageInfo);
}
