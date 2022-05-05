package com.tencent.qcloud.tim.tuiofflinepush.OEMPush;

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
        // 点击vivo的通知栏时，会有两个动作，一个是触发该回调，另一个是会根据vivo的跳转配置启动activity
        // 所以这里需要把自定义的数据写到静态缓存里，启动配置activity的时候获取，进而进行下一步动作。
        //
        // 需要注意的是，如果这里携带解析的自定义数据来启动activity时，因为点击通知栏启动了相同的activity，
        // 等于启动了两遍同样的activity，因为时序无法保证，所以可能携带自定义数据的activity晚启动，跳转到聊天窗口失败
        TUIOfflinePushLog.i(TAG, "onNotificationMessageClicked upsNotificationMessage " + upsNotificationMessage.toString());
        Map<String, String> extra = upsNotificationMessage.getParams();
        sExt = extra.get("ext");
    }

    public static String getParams() {
        // 确保获取一次之后就释放，不会造成数据被滥用
        String tmp = sExt;
        sExt = "";
        return tmp;
    }

    @Override
    public void onReceiveRegId(Context context, String regId) {
        // vivo regId有变化会走这个回调。根据官网文档，获取regId需要在开启推送的回调里面调用PushClient.getInstance(getApplicationContext()).getRegId();参考LoginActivity
        TUIOfflinePushLog.i(TAG, "onReceiveRegId = " + regId);
    }
}
