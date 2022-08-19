package com.tencent.qcloud.tim.tuiofflinepush.oempush;

import android.content.Context;
import android.text.TextUtils;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.tasks.Task;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;
import com.heytap.msp.push.HeytapPushManager;
import com.huawei.agconnect.config.AGConnectServicesConfig;
import com.huawei.hms.aaid.HmsInstanceId;
import com.huawei.hms.common.ApiException;
import com.huawei.hms.push.HmsMessaging;
import com.meizu.cloud.pushsdk.PushManager;
import com.tencent.qcloud.tim.tuiofflinepush.PrivateConstants;
import com.tencent.qcloud.tim.tuiofflinepush.TUIOfflinePushConfig;
import com.tencent.qcloud.tim.tuiofflinepush.interfaces.PushCallback;
import com.tencent.qcloud.tim.tuiofflinepush.interfaces.PushSettingInterface;
import com.tencent.qcloud.tim.tuiofflinepush.utils.BrandUtil;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;
import com.vivo.push.IPushActionListener;
import com.vivo.push.PushClient;
import com.xiaomi.mipush.sdk.MiPushClient;

public class OEMPushSetting implements PushSettingInterface{
    private static final String TAG = OEMPushSetting.class.getSimpleName();
    protected static PushCallback mPushCallback = null;

    public void initPush(Context context) {
        int brand = BrandUtil.getInstanceType();
        switch (brand) {
            case TUIOfflinePushConfig.BRAND_XIAOMI:
                // 小米离线推送
                MiPushClient.registerPush(context, PrivateConstants.xiaomiPushAppId, PrivateConstants.xiaomiPushAppKey);
                break;
            case TUIOfflinePushConfig.BRAND_HUAWEI:
                // 华为离线推送，设置是否接收Push通知栏消息调用示例
                HmsMessaging.getInstance(context).turnOnPush().addOnCompleteListener(new com.huawei.hmf.tasks.OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(com.huawei.hmf.tasks.Task<Void> task) {
                        if (task.isSuccessful()) {
                            TUIOfflinePushLog.i(TAG, "huawei turnOnPush Complete");
                        } else {
                            TUIOfflinePushLog.e(TAG, "huawei turnOnPush failed: ret=" + task.getException().getMessage());
                        }
                    }
                });

                // 华为离线推送
                new Thread() {
                    @Override
                    public void run() {
                        try {
                            // read from agconnect-services.json
                            String appId = AGConnectServicesConfig.fromContext(context).getString("client/app_id");
                            String token = HmsInstanceId.getInstance(context).getToken(appId, "HCM");
                            TUIOfflinePushLog.i(TAG, "huawei get token:" + token);
                            if(!TextUtils.isEmpty(token)) {
                                if (mPushCallback != null) {
                                    mPushCallback.onTokenCallback(token);
                                } else {
                                    TUIOfflinePushLog.e(TAG, "mPushCallback is null");
                                }
                            }
                        } catch (ApiException e) {
                            TUIOfflinePushLog.e(TAG, "huawei get token failed, " + e);
                        }
                    }
                }.start();
                break;
            case TUIOfflinePushConfig.BRAND_MEIZU:
                // 魅族离线推送
                PushManager.register(context, PrivateConstants.meizuPushAppId, PrivateConstants.meizuPushAppKey);
                break;
            case TUIOfflinePushConfig.BRAND_OPPO:
                HeytapPushManager.init(context, false);
                if (HeytapPushManager.isSupportPush(context)) {
                    // oppo离线推送
                    OPPOPushImpl oppo = new OPPOPushImpl();
                    oppo.createNotificationChannel(context);
                    HeytapPushManager.register(context, PrivateConstants.oppoPushAppKey, PrivateConstants.oppoPushAppSecret, oppo);

                    // OPPO 手机默认关闭通知，需要申请
                    HeytapPushManager.requestNotificationPermission();
                }
                break;
            case TUIOfflinePushConfig.BRAND_VIVO:
                // vivo离线推送
                PushClient.getInstance(context).initialize();

                TUIOfflinePushLog.i(TAG, "vivo support push: " + PushClient.getInstance(context).isSupport());
                PushClient.getInstance(context).turnOnPush(new IPushActionListener() {
                    @Override
                    public void onStateChanged(int state) {
                        if (state == 0) {
                            String regId = PushClient.getInstance(context).getRegId();
                            TUIOfflinePushLog.i(TAG, "vivopush open vivo push success regId = " + regId);
                            if (mPushCallback != null) {
                                mPushCallback.onTokenCallback(regId);
                            } else {
                                TUIOfflinePushLog.e(TAG, "mPushCallback is null");
                            }
                        } else {
                            // 根据vivo推送文档说明，state = 101 表示该vivo机型或者版本不支持vivo推送，链接：https://dev.vivo.com.cn/documentCenter/doc/156
                            TUIOfflinePushLog.i(TAG, "vivopush open vivo push fail state = " + state);
                        }
                    }
                });
                break;
            default:
                if (isGoogleServiceSupport()) {
                    FirebaseInstanceId.getInstance().getInstanceId()
                            .addOnCompleteListener(new com.google.android.gms.tasks.OnCompleteListener<InstanceIdResult>() {
                                @Override
                                public void onComplete(Task<InstanceIdResult> task) {
                                    if (!task.isSuccessful()) {
                                        TUIOfflinePushLog.w(TAG, "getInstanceId failed exception = " + task.getException());
                                        return;
                                    }

                                    // Get new Instance ID token
                                    String token = task.getResult().getToken();
                                    TUIOfflinePushLog.i(TAG, "google fcm getToken = " + token);

                                    if (mPushCallback != null) {
                                        mPushCallback.onTokenCallback(token);
                                    } else {
                                        TUIOfflinePushLog.e(TAG, "mPushCallback is null");
                                    }
                                }
                            });
                }
                break;
        }
    }

    public void setPushCallback(PushCallback callback){
        mPushCallback = callback;
    }

    public boolean isGoogleServiceSupport() {
        GoogleApiAvailability googleApiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = googleApiAvailability.isGooglePlayServicesAvailable(TUIOfflinePushConfig.getInstance().getContext());
        return resultCode == ConnectionResult.SUCCESS;
    }

}
