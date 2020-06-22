package com.tencent.qcloud.tim.demo;

import android.app.Activity;
import android.app.Application;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.media.RingtoneManager;
import android.os.Build;
import android.os.Bundle;
import android.os.SystemClock;
import android.text.TextUtils;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;
import com.huawei.android.hms.agent.HMSAgent;
import com.meizu.cloud.pushsdk.PushManager;
import com.meizu.cloud.pushsdk.util.MzSystemUtils;
import com.tencent.bugly.crashreport.CrashReport;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;
import com.tencent.qcloud.tim.demo.helper.ConfigHelper;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.thirdpush.HUAWEIPushReceiver;
import com.tencent.qcloud.tim.demo.thirdpush.ThirdPushTokenMgr;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.MessageNotification;
import com.tencent.qcloud.tim.demo.utils.PrivateConstants;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IMEventListener;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.vivo.push.PushClient;
import com.xiaomi.mipush.sdk.MiPushClient;

import androidx.multidex.MultiDex;

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
        strategy.setAppVersion(TIMManager.getInstance().getVersion());
        CrashReport.initCrashReport(getApplicationContext(), PrivateConstants.BUGLY_APPID, true, strategy);

        /**
         * TUIKit的初始化函数
         *
         * @param context  应用的上下文，一般为对应应用的ApplicationContext
         * @param sdkAppID 您在腾讯云注册应用时分配的sdkAppID
         * @param configs  TUIKit的相关配置项，一般使用默认即可，需特殊配置参考API文档
         */
        TUIKit.init(this, GenerateTestUserSig.SDKAPPID, new ConfigHelper().getConfigs());

        if (ThirdPushTokenMgr.USER_GOOGLE_FCM) {
            FirebaseInstanceId.getInstance().getInstanceId()
                    .addOnCompleteListener(new OnCompleteListener<InstanceIdResult>() {
                        @Override
                        public void onComplete(Task<InstanceIdResult> task) {
                            if (!task.isSuccessful()) {
                                DemoLog.w(TAG, "getInstanceId failed exception = " + task.getException());
                                return;
                            }

                            // Get new Instance ID token
                            String token = task.getResult().getToken();
                            DemoLog.i(TAG, "google fcm getToken = " + token);

                            ThirdPushTokenMgr.getInstance().setThirdPushToken(token);
                        }
                    });
        } else if (BrandUtil.isBrandXiaoMi()) {
            // 小米离线推送
            MiPushClient.registerPush(this, PrivateConstants.XM_PUSH_APPID, PrivateConstants.XM_PUSH_APPKEY);
        } else if (BrandUtil.isBrandHuawei()) {
            // 华为离线推送
            HMSAgent.init(this);
        } else if (MzSystemUtils.isBrandMeizu(this)) {
            // 魅族离线推送
            PushManager.register(this, PrivateConstants.MZ_PUSH_APPID, PrivateConstants.MZ_PUSH_APPKEY);
        } else if (BrandUtil.isBrandVivo()) {
            // vivo离线推送
            PushClient.getInstance(getApplicationContext()).initialize();
        } else if (com.heytap.mcssdk.PushManager.isSupportPush(this)) {
            // oppo离线推送，因为需要登录成功后向我们后台设置token，所以注册放在MainActivity中做
        }

        registerActivityLifecycleCallbacks(new StatisticActivityLifecycleCallback());

//        if (BuildConfig.DEBUG) {
//            if (LeakCanary.isInAnalyzerProcess(this)) {
//                return;
//            }
//            LeakCanary.install(this);
//        }
    }

    class StatisticActivityLifecycleCallback implements ActivityLifecycleCallbacks {
        private int foregroundActivities = 0;
        private boolean isChangingConfiguration;
        private IMEventListener mIMEventListener = new IMEventListener() {
            @Override
            public void onNewMessage(V2TIMMessage msg) {
                MessageNotification notification = MessageNotification.getInstance();
                notification.notify(msg);
            }
        };

        private ConversationManagerKit.MessageUnreadWatcher mUnreadWatcher = new ConversationManagerKit.MessageUnreadWatcher() {
            @Override
            public void updateUnread(int count) {
                // 华为离线推送角标
                HUAWEIPushReceiver.updateBadge(DemoApplication.this, count);
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
