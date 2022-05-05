package com.tencent.qcloud.tim.tuiofflinepush.OEMPush;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.tencent.qcloud.tim.tuiofflinepush.TUIOfflinePushManager;
import com.tencent.qcloud.tim.tuiofflinepush.PushSetting;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;


public class GoogleFCMMsgService extends FirebaseMessagingService {
    private final String TAG = GoogleFCMMsgService.class.getSimpleName();

    @Override
    public void onNewToken(String token) {
        super.onNewToken(token);
        TUIOfflinePushLog.i(TAG, "google fcm onNewToken : " + token);

        if (PushSetting.isTPNSChannel) {
            return;
        }

        TUIOfflinePushManager.getInstance().setPushTokenToTIM(token);
    }
}
