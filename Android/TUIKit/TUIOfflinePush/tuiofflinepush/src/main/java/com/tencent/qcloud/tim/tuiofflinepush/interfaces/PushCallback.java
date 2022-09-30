package com.tencent.qcloud.tim.tuiofflinepush.interfaces;

import android.content.Context;

import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushErrorBean;

public interface PushCallback {
    void onTokenCallback(String token);
    void onBadgeCallback(Context context, int number);
    void onTokenErrorCallBack(TUIOfflinePushErrorBean errorBean);
}
