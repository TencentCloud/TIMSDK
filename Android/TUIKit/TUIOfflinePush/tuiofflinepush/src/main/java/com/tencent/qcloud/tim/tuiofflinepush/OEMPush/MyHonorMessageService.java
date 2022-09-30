package com.tencent.qcloud.tim.tuiofflinepush.oempush;

import android.text.TextUtils;

import com.hihonor.push.sdk.HonorMessageService;
import com.hihonor.push.sdk.bean.DataMessage;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;

public class MyHonorMessageService extends HonorMessageService {
    private static final String TAG = MyHonorMessageService.class.getSimpleName();

    @Override
    public void onNewToken(String token) {
        TUIOfflinePushLog.i(TAG, "onNewToken token=" + token);

        if (TextUtils.isEmpty(token)) {
            return;
        }

        if (OEMPushSetting.mPushCallback != null) {
            OEMPushSetting.mPushCallback.onTokenCallback(token);
        }
    }

    @Override
    public void onMessageReceived(DataMessage dataMessage) {
        TUIOfflinePushLog.i(TAG, "onMessageReceived message=" + dataMessage);
    }
}
