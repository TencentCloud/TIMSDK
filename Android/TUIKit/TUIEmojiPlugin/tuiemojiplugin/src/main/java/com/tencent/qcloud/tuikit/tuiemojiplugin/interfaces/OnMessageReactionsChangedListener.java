package com.tencent.qcloud.tuikit.tuiemojiplugin.interfaces;

import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;

import java.util.List;

public interface OnMessageReactionsChangedListener {
    void onMessageReactionsChanged(MessageReactionBean messageReactionBean);
}
