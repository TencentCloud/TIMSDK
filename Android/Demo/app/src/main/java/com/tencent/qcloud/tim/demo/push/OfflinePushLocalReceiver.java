package com.tencent.qcloud.tim.demo.push;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.TUIConstants;

import java.util.HashMap;
import java.util.Map;

public class OfflinePushLocalReceiver extends BroadcastReceiver {
    public static final String TAG = OfflinePushLocalReceiver.class.getSimpleName();

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d(TAG, "BROADCAST_PUSH_RECEIVER intent = " + intent);
        if (intent != null) {
            String action = intent.getAction();
            if (TextUtils.equals(TUIConstants.TIMPush.NOTIFICATION_BROADCAST_ACTION, action)) {
                String ext = intent.getStringExtra(TUIConstants.TIMPush.NOTIFICATION_EXT_KEY);
                TUIUtils.handleOfflinePush(ext, null);
            } else if (TextUtils.equals(TUIConstants.TIMPush.BROADCAST_IM_LOGIN_AFTER_APP_WAKEUP, action)) {
                Bundle receivedBundle = intent.getExtras();
                if (receivedBundle != null) {
                    Map<String, String> receivedMap = new HashMap<>();
                    for (String key : receivedBundle.keySet()) {
                        String value = receivedBundle.getString(key);
                        receivedMap.put(key, value);
                        Log.d(TAG, "key = " + key + ", value = " + value);
                    }
                    

                } else {
                    DemoLog.e(TAG, "receivedBundle is null");
                }
            }
        } else {
            DemoLog.e(TAG, "onReceive intent is null");
        }
    }
}
