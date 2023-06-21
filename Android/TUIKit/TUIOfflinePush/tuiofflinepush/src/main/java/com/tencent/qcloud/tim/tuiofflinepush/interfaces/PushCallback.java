package com.tencent.qcloud.tim.tuiofflinepush.interfaces;

import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushErrorBean;

public interface PushCallback {
    void onTokenCallback(String token);

    void onTokenErrorCallBack(TUIOfflinePushErrorBean errorBean);
}
