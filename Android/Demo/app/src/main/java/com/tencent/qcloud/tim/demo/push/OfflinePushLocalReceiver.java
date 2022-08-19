package com.tencent.qcloud.tim.demo.push;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.TUIConstants;

public class OfflinePushLocalReceiver extends BroadcastReceiver {
    public static final String TAG = OfflinePushLocalReceiver.class.getSimpleName();

    @Override
    public void onReceive(Context context, Intent intent) {
        DemoLog.d(TAG, "BROADCAST_PUSH_RECEIVER intent = " + intent);
        if (intent != null) {
            String ext = intent.getStringExtra(TUIConstants.TUIOfflinePush.NOTIFICATION_EXT_KEY);
            TUIUtils.handleOfflinePush(ext, null);
        } else {
            DemoLog.e(TAG, "onReceive ext is null");
        }
    }
}
