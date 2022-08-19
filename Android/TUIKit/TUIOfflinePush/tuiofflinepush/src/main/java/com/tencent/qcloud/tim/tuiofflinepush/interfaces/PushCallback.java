package com.tencent.qcloud.tim.tuiofflinepush.interfaces;

import android.content.Context;

public interface PushCallback {
    void onTokenCallback(String token);
    void onBadgeCallback(Context context, int number);
}
