package com.tencent.qcloud.uipojo.thirdpush;

import android.content.Context;
import android.util.Log;

import com.vivo.push.model.UPSNotificationMessage;
import com.vivo.push.sdk.OpenClientPushMessageReceiver;

/**
 * Created by vinsonswang on 2019/2/27.
 */

public class VIVOPushMessageReceiverImpl extends OpenClientPushMessageReceiver {
    private static final String TAG = "VIVOPushMessageReceiver";
    @Override
    public void onNotificationMessageClicked(Context context, UPSNotificationMessage upsNotificationMessage) {
        Log.i(TAG, "onNotificationMessageClicked");
    }

    @Override
    public void onReceiveRegId(Context context, String regId) {
        // vivo regId有变化会走这个回调。根据官网文档，获取regId需要在开启推送的回调里面调用PushClient.getInstance(getApplicationContext()).getRegId();参考LoginActivity
        Log.i(TAG, "onReceiveRegId = " + regId);
    }
}
