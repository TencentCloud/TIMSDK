package com.tencent.qcloud.tim.demo.push;

import android.content.Context;
import android.content.IntentFilter;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.google.gson.Gson;
import com.tencent.qcloud.tim.demo.config.AppConfig;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.TUIServiceCallback;
import com.tencent.qcloud.tuikit.tuichat.util.OfflinePushInfoUtils;

import java.util.HashMap;
import java.util.Map;

public class OfflinePushAPIDemo {
    public static final String TAG = OfflinePushAPIDemo.class.getSimpleName();
    /**
     *  Register offline push service, called when IM account login is successful.Calling this interface does not require filling parameters into the
     * component's PrivateConstants.
     *
     *  @note  json：
     * {
     *    // huawei
     *   "huaweiPushBussinessId": "",    
     *   "huaweiBadgeClassName": "", 
     * launcher interface
     *
     *   // xiaomi
     *   "xiaomiPushBussinessId": "",
     *   "xiaomiPushAppId": "",
     *   "xiaomiPushAppKey": "",
     *
     *   // meizu
     *   "meizuPushBussinessId": "", 
     *   "meizuPushAppId": "",
     *   "meizuPushAppKey": "",
     *
     *   // vivo
     *   "vivoPushBussinessId": "", 
     *
     *   // google
     *   "fcmPushBussinessId": "", 
     *
     *   // oppo
     *   "oppoPushBussinessId": "", 
     *   "oppoPushAppKey": "",
     *   "oppoPushAppSecret": "",
     *
     *   // honor
     *   "honorPushBussinessId": "",    
     *  }
     *
     */
    public void registerPush(Context context) {
        OfflinePushParamBean offlinePushParamBean = new OfflinePushParamBean();

        String huaweiBussinessId, xiaomiBussinessId, meizuBussinessId, vivoBussinessId, oppoBussinessId;
        String fcmBussinessId, honorBussinessId;

        int callbackMode = OfflinePushConfigs.getOfflinePushConfigs().getClickNotificationCallbackMode();
        Log.d(TAG, "OfflinePush callback mode:" + callbackMode);
        if (callbackMode == OfflinePushConfigs.CLICK_NOTIFICATION_CALLBACK_NOTIFY ||
                callbackMode == OfflinePushConfigs.CLICK_NOTIFICATION_CALLBACK_BROADCAST) {
            if (TextUtils.equals(AppConfig.DEMO_FLAVOR_VERSION, Constants.FLAVOR_INTERNATIONAL)) {
                huaweiBussinessId = "";
                xiaomiBussinessId = "";
                meizuBussinessId = "";
                vivoBussinessId = "";
                oppoBussinessId = "";
                fcmBussinessId = "";
                honorBussinessId = "";
            } else {
                huaweiBussinessId = "";
                xiaomiBussinessId = "";
                meizuBussinessId = "";
                vivoBussinessId = "";
                oppoBussinessId = "";
                fcmBussinessId = "";
                honorBussinessId = "";
            }
        } else {
            if (TextUtils.equals(AppConfig.DEMO_FLAVOR_VERSION, Constants.FLAVOR_INTERNATIONAL)) {
                huaweiBussinessId = "";
                xiaomiBussinessId = "";
                meizuBussinessId = "";
                vivoBussinessId = "";
                oppoBussinessId = "";
                fcmBussinessId = "";
                honorBussinessId = "";
            } else {
                huaweiBussinessId = "";
                xiaomiBussinessId = "";
                meizuBussinessId = "";
                vivoBussinessId = "";
                oppoBussinessId = "";
                fcmBussinessId = "";
                honorBussinessId = "";
            }
        }

        offlinePushParamBean.setHuaweiPushBussinessId(huaweiBussinessId);
        offlinePushParamBean.setHuaweiBadgeClassName("com.tencent.qcloud.tim.demo.SplashActivity");

        offlinePushParamBean.setXiaomiPushBussinessId(xiaomiBussinessId);
        offlinePushParamBean.setXiaomiPushAppId("");
        offlinePushParamBean.setXiaomiPushAppKey("");

        offlinePushParamBean.setMeizuPushBussinessId(meizuBussinessId);
        offlinePushParamBean.setMeizuPushAppId("");
        offlinePushParamBean.setMeizuPushAppKey("");

        offlinePushParamBean.setVivoPushBussinessId(vivoBussinessId);

        offlinePushParamBean.setFcmPushBussinessId(fcmBussinessId);
        offlinePushParamBean.setFcmPushChannelId(OfflinePushInfoUtils.FCM_PUSH_CHANNEL_ID);
        offlinePushParamBean.setFcmPushChannelSoundName(OfflinePushInfoUtils.PRIVATE_RING_NAME);

        offlinePushParamBean.setOppoPushBussinessId(oppoBussinessId);
        offlinePushParamBean.setOppoPushAppKey("");
        offlinePushParamBean.setOppoPushAppSecret("");

        offlinePushParamBean.setHonorPushBussinessId(honorBussinessId);

        String jsonStr = new Gson().toJson(offlinePushParamBean);
        if (TextUtils.isEmpty(jsonStr)) {
            DemoLog.e(TAG, "registerPush json is null");
            return;
        }

        DemoLog.d(TAG, "registerPush json = " + jsonStr);
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TIMPush.REGISTER_PUSH_WITH_JSON_KEY, jsonStr);
        TUICore.callService(TUIConstants.TIMPush.SERVICE_NAME, TUIConstants.TIMPush.METHOD_REGISTER_PUSH_WITH_JSON, param, new TUIServiceCallback() {
            @Override
            public void onServiceCallback(int errorCode, String errorMessage, Bundle bundle) {
                DemoLog.d(TAG, "registerPush errorCode = " + errorCode + ", errorMessage = " + errorMessage);
            }
        });

        /*try {
            Class clz = Class.forName("com.tencent.qcloud.tim.push.TIMPushService");
            Method methodIntance = clz.getDeclaredMethod("getInstance", new Class[0]);
            Object intance = methodIntance.invoke(null, new Object[] {});
            Method methodRegister = clz.getDeclaredMethod("registerPush", String.class, Context.class);
            methodRegister.setAccessible(true);
            methodRegister.invoke(intance, jsonStr, context);
        } catch (Exception e) {
            DemoLog.e(TAG, "registerPush exception = " + e);
        }*/
    }

    /**
     * When the IM console sets the click follow-up action to "use push component callback to jump"，After the push is successful, register NotifyEvent through
     * TUICore, and click the notification bar event will be returned through the TUICore.onNotifyEvent callback.
     */
    public void registerNotifyEvent() {
        TUICore.registerEvent(TUIConstants.TIMPush.EVENT_NOTIFY, TUIConstants.TIMPush.EVENT_NOTIFY_NOTIFICATION, new ITUINotification() {
            @Override
            public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
                Log.d(TAG, "onNotifyEvent key = " + key + "subKey = " + subKey);
                if (TUIConstants.TIMPush.EVENT_NOTIFY.equals(key)) {
                    if (TUIConstants.TIMPush.EVENT_NOTIFY_NOTIFICATION.equals(subKey)) {
                        if (param != null) {
                            String extString = (String) param.get(TUIConstants.TIMPush.NOTIFICATION_EXT_KEY);
                            TUIUtils.handleOfflinePush(extString, null);
                        }
                    }
                }
            }
        });
    }

    /**
     * When the IM console sets the click follow-up action to "use push component callback to jump"，After the push is successful, register the broadcast
     * receiver, click the notification bar event to return by sending the broadcast callback. IntentFilter 
     * TUIConstants.TIMPush.NOTIFICATION_BROADCAST_ACTION.
     */
    public void registerNotificationReceiver(Context context, OfflinePushLocalReceiver localReceiver) {
        DemoLog.d(TAG, "registerNotificationReceiver ");
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(TUIConstants.TIMPush.NOTIFICATION_BROADCAST_ACTION);
        intentFilter.addAction(TUIConstants.TIMPush.BROADCAST_IM_LOGIN_AFTER_APP_WAKEUP);
        LocalBroadcastManager.getInstance(context).registerReceiver(localReceiver, intentFilter);
    }
}
