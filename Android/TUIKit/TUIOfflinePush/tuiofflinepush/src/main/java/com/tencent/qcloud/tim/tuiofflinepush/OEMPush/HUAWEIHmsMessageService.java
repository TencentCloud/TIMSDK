package com.tencent.qcloud.tim.tuiofflinepush.oempush;

import com.huawei.hms.push.HmsMessageService;
import com.huawei.hms.push.RemoteMessage;
import com.tencent.qcloud.tim.tuiofflinepush.TUIOfflinePushConfig;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushErrorBean;
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

        if (com.tencent.qcloud.tim.tuiofflinepush.oempush.OEMPushSetting.mPushCallback != null) {
            OEMPushSetting.mPushCallback.onTokenCallback(token);
        }
    }

    @Override
    public void onTokenError(Exception exception) {
        TUIOfflinePushLog.i(TAG, "onTokenError exception=" + exception);
        if (OEMPushSetting.mPushCallback != null) {
            TUIOfflinePushErrorBean errorBean = new TUIOfflinePushErrorBean();
            errorBean.setErrorCode(TUIOfflinePushConfig.REGISTER_TOKEN_ERROR_CODE);
            errorBean.setErrorDescription("huawei onTokenError exception = " + exception);
            OEMPushSetting.mPushCallback.onTokenErrorCallBack(errorBean);
        }
    }

    @Override
    public void onMessageDelivered(String msgId, Exception exception) {
        TUIOfflinePushLog.i(TAG, "onMessageDelivered msgId=" + msgId);
    }
}
