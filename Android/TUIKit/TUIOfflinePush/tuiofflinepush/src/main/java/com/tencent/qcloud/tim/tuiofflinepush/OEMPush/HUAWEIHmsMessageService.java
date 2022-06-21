package com.tencent.qcloud.tim.tuiofflinepush.OEMPush;

import android.content.Context;

import com.huawei.hms.push.HmsMessageService;
import com.huawei.hms.push.RemoteMessage;
import com.tencent.qcloud.tim.tuiofflinepush.utils.BrandUtil;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;

public class HUAWEIHmsMessageService extends HmsMessageService {

    private static final String TAG = HUAWEIHmsMessageService.class.getSimpleName();

    @Override
    public void onMessageReceived(RemoteMessage message) {
        TUIOfflinePushLog.i(TAG, "onMessageReceived message=" + message);
    }

    @Override
    public void onMessageSent(String msgId) {
        TUIOfflinePushLog.i(TAG, "onMessageSent msgId=" + msgId);
    }

    @Override
    public void onSendError(String msgId, Exception exception) {
        TUIOfflinePushLog.i(TAG, "onSendError msgId=" + msgId);
    }

    @Override
    public void onNewToken(String token) {
        TUIOfflinePushLog.i(TAG, "onNewToken token=" + token);

        if (OEMPushSetting.mPushCallback != null) {
            OEMPushSetting.mPushCallback.onTokenCallback(token);
        }
    }

    @Override
    public void onTokenError(Exception exception) {
        TUIOfflinePushLog.i(TAG, "onTokenError exception=" + exception);
    }

    @Override
    public void onMessageDelivered(String msgId, Exception exception) {
        TUIOfflinePushLog.i(TAG, "onMessageDelivered msgId=" + msgId);
    }


    public static void updateBadge(final Context context, final int number) {
        if (!BrandUtil.isBrandHuawei()) {
            return;
        }
        TUIOfflinePushLog.i(TAG, "huawei badge = " + number);
        if (OEMPushSetting.mPushCallback != null) {
            OEMPushSetting.mPushCallback.onBadgeCallback(context, number);
        }
    }
}
