package com.tencent.qcloud.tim.demo;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;

import androidx.multidex.MultiDex;

import com.google.android.gms.tasks.Task;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;
import com.heytap.msp.push.HeytapPushManager;
import com.huawei.hms.push.HmsMessaging;
import com.meizu.cloud.pushsdk.PushManager;
import com.meizu.cloud.pushsdk.util.MzSystemUtils;
import com.tencent.android.tpush.XGPushConfig;
import com.tencent.bugly.crashreport.CrashReport;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tim.demo.helper.ConfigHelper;
import com.tencent.qcloud.tim.demo.helper.HelloChatController;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.thirdpush.HUAWEIHmsMessageService;
import com.tencent.qcloud.tim.demo.thirdpush.ThirdPushTokenMgr;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.MessageNotification;
import com.tencent.qcloud.tim.demo.utils.PrivateConstants;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IMEventListener;
import com.tencent.qcloud.tim.uikit.base.TUIKitListenerManager;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.utils.TUIKitUtils;
import com.tencent.rtmp.TXLiveBase;
import com.vivo.push.PushClient;
import com.xiaomi.mipush.sdk.MiPushClient;

public class DemoApplication extends Application {

    private static final String TAG = DemoApplication.class.getSimpleName();


    private static DemoApplication instance;

    public static DemoApplication instance() {
        return instance;
    }

    @Override
    public void onCreate() {
        DemoLog.i(TAG, "onCreate");
        super.onCreate();
        instance = this;
        MultiDex.install(this);
        // bugly上报
        CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(getApplicationContext());
        strategy.setAppVersion(V2TIMManager.getInstance().getVersion());
        CrashReport.initCrashReport(getApplicationContext(), PrivateConstants.BUGLY_APPID, true, strategy);
        // 是否进测试环境
        final SharedPreferences sharedPreferences = getSharedPreferences("TUIKIT_DEMO_SETTINGS", MODE_PRIVATE);
        boolean enter_test_environment = sharedPreferences.getBoolean("test_environment", false);
        V2TIMManager.getInstance().callExperimentalAPI("setTestEnvironment", new Boolean(enter_test_environment), null);

        /**
         * TUIKit的初始化函数
         *
         * @param context  应用的上下文，一般为对应应用的ApplicationContext
         * @param sdkAppID 您在腾讯云注册应用时分配的sdkAppID
         * @param configs  TUIKit的相关配置项，一般使用默认即可，需特殊配置参考API文档
         */
        TUIKit.init(this, GenerateTestUserSig.SDKAPPID, new ConfigHelper().getConfigs());
        registerCustomListeners();


        // 关闭 TPNS SDK 拉活其他 app 的功能
        // ref: https://cloud.tencent.com/document/product/548/36674#.E5.A6.82.E4.BD.95.E5.85.B3.E9.97.AD-tpns-.E7.9A.84.E4.BF.9D.E6.B4.BB.E5.8A.9F.E8.83.BD.EF.BC.9F
        XGPushConfig.enablePullUpOtherApp(this, false);


        // 厂商注册可以都由 TPNS SDK 内部完成；离线推送点击回调由于实现不同，可仍按 IM 离线推送集成文档对应部分完成
//        HeytapPushManager.init(this, true);
//        if (BrandUtil.isBrandXiaoMi()) {
//            // 小米离线推送
//            MiPushClient.registerPush(this, PrivateConstants.XM_PUSH_APPID, PrivateConstants.XM_PUSH_APPKEY);
//        } else if (BrandUtil.isBrandHuawei()) {
//            // 华为离线推送，设置是否接收Push通知栏消息调用示例
//            HmsMessaging.getInstance(this).turnOnPush().addOnCompleteListener(new com.huawei.hmf.tasks.OnCompleteListener<Void>() {
//                @Override
//                public void onComplete(com.huawei.hmf.tasks.Task<Void> task) {
//                    if (task.isSuccessful()) {
//                        DemoLog.i(TAG, "huawei turnOnPush Complete");
//                    } else {
//                        DemoLog.e(TAG, "huawei turnOnPush failed: ret=" + task.getException().getMessage());
//                    }
//                }
//            });
//        } else if (MzSystemUtils.isBrandMeizu(this)) {
//            // 魅族离线推送
//            PushManager.register(this, PrivateConstants.MZ_PUSH_APPID, PrivateConstants.MZ_PUSH_APPKEY);
//        } else if (BrandUtil.isBrandVivo()) {
//            // vivo离线推送
//            PushClient.getInstance(getApplicationContext()).initialize();
//        } else if (HeytapPushManager.isSupportPush()) {
//            // oppo离线推送，因为需要登录成功后向我们后台设置token，所以注册放在MainActivity中做
//        } else if (BrandUtil.isGoogleServiceSupport()) {
//            FirebaseInstanceId.getInstance().getInstanceId()
//                    .addOnCompleteListener(new com.google.android.gms.tasks.OnCompleteListener<InstanceIdResult>() {
//                        @Override
//                        public void onComplete(Task<InstanceIdResult> task) {
//                            if (!task.isSuccessful()) {
//                                DemoLog.w(TAG, "getInstanceId failed exception = " + task.getException());
//                                return;
//                            }
//
//                            // Get new Instance ID token
//                            String token = task.getResult().getToken();
//                            DemoLog.i(TAG, "google fcm getToken = " + token);
//
//                            ThirdPushTokenMgr.getInstance().setThirdPushToken(token);
//                        }
//                    });
//        };

        registerActivityLifecycleCallbacks(new StatisticActivityLifecycleCallback());
    }

    private static void registerCustomListeners() {
        TUIKitListenerManager.getInstance().addChatListener(new HelloChatController());
        TUIKitListenerManager.getInstance().addConversationListener(new HelloChatController.HelloConversationController());
    }

    class StatisticActivityLifecycleCallback implements ActivityLifecycleCallbacks {
        private int foregroundActivities = 0;
        private boolean isChangingConfiguration;
        private IMEventListener mIMEventListener = new IMEventListener() {
            @Override
            public void onNewMessage(V2TIMMessage msg) {
                String imSdkVersion = V2TIMManager.getInstance().getVersion();
                // IMSDK 5.0.1及以后版本 doBackground 之后同时会离线推送
                if (TUIKitUtils.compareVersion(imSdkVersion, "5.0.1") < 0) {
                    MessageNotification notification = MessageNotification.getInstance();
                    notification.notify(msg);
                }
            }
        };

        private ConversationManagerKit.MessageUnreadWatcher mUnreadWatcher = new ConversationManagerKit.MessageUnreadWatcher() {
            @Override
            public void updateUnread(int count) {
                // 华为离线推送角标
                HUAWEIHmsMessageService.updateBadge(DemoApplication.this, count);
            }
        };

        @Override
        public void onActivityCreated(Activity activity, Bundle bundle) {
            DemoLog.i(TAG, "onActivityCreated bundle: " + bundle);
            if (bundle != null) { // 若bundle不为空则程序异常结束
                // 重启整个程序
                Intent intent = new Intent(activity, SplashActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        }

        @Override
        public void onActivityStarted(Activity activity) {
            foregroundActivities++;
            if (foregroundActivities == 1 && !isChangingConfiguration) {
                // 应用切到前台
                DemoLog.i(TAG, "application enter foreground");
                V2TIMManager.getOfflinePushManager().doForeground(new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        DemoLog.e(TAG, "doForeground err = " + code + ", desc = " + desc);
                    }

                    @Override
                    public void onSuccess() {
                        DemoLog.i(TAG, "doForeground success");
                    }
                });
                TUIKit.removeIMEventListener(mIMEventListener);
                ConversationManagerKit.getInstance().removeUnreadWatcher(mUnreadWatcher);
                MessageNotification.getInstance().cancelTimeout();
            }
            isChangingConfiguration = false;
        }

        @Override
        public void onActivityResumed(Activity activity) {

        }

        @Override
        public void onActivityPaused(Activity activity) {

        }

        @Override
        public void onActivityStopped(Activity activity) {
            foregroundActivities--;
            if (foregroundActivities == 0) {
                // 应用切到后台
                DemoLog.i(TAG, "application enter background");
                int unReadCount = ConversationManagerKit.getInstance().getUnreadTotal();
                V2TIMManager.getOfflinePushManager().doBackground(unReadCount, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        DemoLog.e(TAG, "doBackground err = " + code + ", desc = " + desc);
                    }

                    @Override
                    public void onSuccess() {
                        DemoLog.i(TAG, "doBackground success");
                    }
                });
                // 应用退到后台，消息转化为系统通知
                TUIKit.addIMEventListener(mIMEventListener);
                ConversationManagerKit.getInstance().addUnreadWatcher(mUnreadWatcher);
            }
            isChangingConfiguration = activity.isChangingConfigurations();
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {

        }

        @Override
        public void onActivityDestroyed(Activity activity) {

        }
    }
}
