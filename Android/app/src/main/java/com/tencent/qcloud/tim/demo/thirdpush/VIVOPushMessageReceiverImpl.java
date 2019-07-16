package com.tencent.qcloud.tim.demo.thirdpush;

import android.content.Context;

import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.vivo.push.model.UPSNotificationMessage;
import com.vivo.push.sdk.OpenClientPushMessageReceiver;


public class VIVOPushMessageReceiverImpl extends OpenClientPushMessageReceiver {

    private static final String TAG = VIVOPushMessageReceiverImpl.class.getSimpleName();

    @Override
    public void onNotificationMessageClicked(Context context, UPSNotificationMessage upsNotificationMessage) {
        DemoLog.i(TAG, "onNotificationMessageClicked");
    }

    @Override
    public void onReceiveRegId(Context context, String regId) {
        // vivo regId有变化会走这个回调。根据官网文档，获取regId需要在开启推送的回调里面调用PushClient.getInstance(getApplicationContext()).getRegId();参考LoginActivity
        DemoLog.i(TAG, "onReceiveRegId = " + regId);
    }
}
