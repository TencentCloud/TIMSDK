package com.tencent.qcloud.tim.tuiofflinepush.oempush;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.os.Build;
import com.heytap.msp.push.callback.ICallBackResultService;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushErrorBean;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;

public class OPPOPushImpl implements ICallBackResultService {
    private static final String TAG = OPPOPushImpl.class.getSimpleName();

    @Override
    public void onRegister(int responseCode, String registerID) {
        TUIOfflinePushLog.i(TAG, "onRegister responseCode: " + responseCode + " registerID: " + registerID);

        if (OEMPushSetting.mPushCallback != null) {
            if (responseCode != 0) {
                TUIOfflinePushErrorBean errorBean = new TUIOfflinePushErrorBean();
                errorBean.setErrorCode(responseCode);
                errorBean.setErrorDescription("oppo error code: " + String.valueOf(responseCode));
                OEMPushSetting.mPushCallback.onTokenErrorCallBack(errorBean);
            } else {
                OEMPushSetting.mPushCallback.onTokenCallback(registerID);
            }
        }
    }

    @Override
    public void onUnRegister(int responseCode) {
        TUIOfflinePushLog.i(TAG, "onUnRegister responseCode: " + responseCode);
    }

    @Override
    public void onSetPushTime(int responseCode, String s) {
        TUIOfflinePushLog.i(TAG, "onSetPushTime responseCode: " + responseCode + " s: " + s);
    }

    @Override
    public void onGetPushStatus(int responseCode, int status) {
        TUIOfflinePushLog.i(TAG, "onGetPushStatus responseCode: " + responseCode + " status: " + status);
    }

    @Override
    public void onGetNotificationStatus(int responseCode, int status) {
        TUIOfflinePushLog.i(TAG, "onGetNotificationStatus responseCode: " + responseCode + " status: " + status);
    }

    @Override
    public void onError(int i, String s) {
        TUIOfflinePushLog.i(TAG, "onError code: " + i + " string: " + s);
    }

    public void createNotificationChannel(Context context) {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = "oppotest";
            String description = "this is opptest";
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel("tuikit", name, importance);
            channel.setDescription(description);
            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            NotificationManager notificationManager = context.getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }
}
