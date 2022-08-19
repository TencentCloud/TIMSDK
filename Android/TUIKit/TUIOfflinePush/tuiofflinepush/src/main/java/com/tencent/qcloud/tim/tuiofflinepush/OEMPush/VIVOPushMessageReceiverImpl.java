package com.tencent.qcloud.tim.tuiofflinepush.oempush;

import android.content.Context;

import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;
import com.vivo.push.model.UPSNotificationMessage;
import com.vivo.push.sdk.OpenClientPushMessageReceiver;

import java.util.Map;


public class VIVOPushMessageReceiverImpl extends OpenClientPushMessageReceiver {

    private static final String TAG = VIVOPushMessageReceiverImpl.class.getSimpleName();

    private static String sExt = "";

    @Override
    public void onNotificationMessageClicked(Context context, UPSNotificationMessage upsNotificationMessage) {
        TUIOfflinePushLog.i(TAG, "onNotificationMessageClicked upsNotificationMessage " + upsNotificationMessage.toString());
        Map<String, String> extra = upsNotificationMessage.getParams();
        sExt = extra.get("ext");
    }

    public static String getParams() {
        String tmp = sExt;
        sExt = "";
        return tmp;
    }

    @Override
    public void onReceiveRegId(Context context, String regId) {
        TUIOfflinePushLog.i(TAG, "onReceiveRegId = " + regId);
    }
}
