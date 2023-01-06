package com.tencent.qcloud.tim.tuiofflinepush.oempush;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;


public class GoogleFCMMsgService extends FirebaseMessagingService {
    private final String TAG = GoogleFCMMsgService.class.getSimpleName();

    @Override
    public void onNewToken(String token) {
        super.onNewToken(token);
        TUIOfflinePushLog.i(TAG, "onNewToken google fcm onNewToken : " + token);

        if (OEMPushSetting.mPushCallback != null) {
            OEMPushSetting.mPushCallback.onTokenCallback(token);
        }
    }
}
