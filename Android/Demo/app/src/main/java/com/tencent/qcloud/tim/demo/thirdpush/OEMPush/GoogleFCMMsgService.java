package com.tencent.qcloud.tim.demo.thirdpush.OEMPush;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.tencent.qcloud.tim.demo.thirdpush.PushSetting;
import com.tencent.qcloud.tim.demo.thirdpush.ThirdPushTokenMgr;
import com.tencent.qcloud.tim.demo.utils.DemoLog;

public class GoogleFCMMsgService extends FirebaseMessagingService {
    private final String TAG = GoogleFCMMsgService.class.getSimpleName();

    @Override
    public void onNewToken(String token) {
        super.onNewToken(token);
        DemoLog.i(TAG, "google fcm onNewToken : " + token);

        if (PushSetting.isTPNSChannel) {
            return;
        }

        ThirdPushTokenMgr.getInstance().setThirdPushToken(token);
        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
    }
}
