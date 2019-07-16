package com.tencent.qcloud.tim.demo;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import com.huawei.android.hms.agent.HMSAgent;
import com.meizu.cloud.pushsdk.PushManager;
import com.meizu.cloud.pushsdk.util.MzSystemUtils;
import com.tencent.bugly.crashreport.CrashReport;
import com.tencent.imsdk.TIMBackgroundParam;
import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.session.SessionWrapper;
import com.tencent.imsdk.utils.IMFunc;
import com.tencent.qcloud.tim.demo.helper.ConfigHelper;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.vivo.push.PushClient;
import com.xiaomi.mipush.sdk.MiPushClient;

import java.util.List;

public class DemoApplication extends Application {

    private static final String TAG = DemoApplication.class.getSimpleName();

    private static DemoApplication instance;

    @Override
    public void onCreate() {
        super.onCreate();

        // bugly上报
        CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(getApplicationContext());
        strategy.setAppVersion(TIMManager.getInstance().getVersion());
        CrashReport.initCrashReport(getApplicationContext(), Constants.BUGLY_APPID, true, strategy);

        //判断是否是在主线程
        if (SessionWrapper.isMainProcess(getApplicationContext())) {
            /**
             * TUIKit的初始化函数
             *
             * @param context  应用的上下文，一般为对应应用的ApplicationContext
             * @param sdkAppID 您在腾讯云注册应用时分配的sdkAppID
             * @param configs  TUIKit的相关配置项，一般使用默认即可，需特殊配置参考API文档
             */
            TUIKit.init(this, Constants.SDKAPPID, new ConfigHelper().getConfigs());

            if (IMFunc.isBrandXiaoMi()) {
                // 小米离线推送
                MiPushClient.registerPush(this, Constants.XM_PUSH_APPID, Constants.XM_PUSH_APPKEY);
            }
            if (IMFunc.isBrandHuawei()) {
                // 华为离线推送
                HMSAgent.init(this);
            }
            if (MzSystemUtils.isBrandMeizu(this)) {
                // 魅族离线推送
                PushManager.register(this, Constants.MZ_PUSH_APPID, Constants.MZ_PUSH_APPKEY);
            }
            if (IMFunc.isBrandVivo()) {
                // vivo离线推送
                PushClient.getInstance(getApplicationContext()).initialize();
            }

            registerActivityLifecycleCallbacks(new StatisticActivityLifecycleCallback());
        }
        instance = this;
       /* if (LeakCanary.isInAnalyzerProcess(this)) {
            return;
        }
        LeakCanary.install(this);*/
    }

    class StatisticActivityLifecycleCallback implements ActivityLifecycleCallbacks {
        private int foregroundActivities = 0;
        private boolean isChangingConfiguration;

        @Override
        public void onActivityCreated(Activity activity, Bundle bundle) {

        }

        @Override
        public void onActivityStarted(Activity activity) {
            foregroundActivities++;
            if (foregroundActivities == 1 && !isChangingConfiguration) {
                // 应用切到前台
                DemoLog.i(TAG, "application enter foreground");
                TIMManager.getInstance().doForeground(new TIMCallBack() {
                    @Override
                    public void onError(int code, String desc) {
                        DemoLog.e(TAG, "doForeground err = " + code + ", desc = " + desc);
                    }

                    @Override
                    public void onSuccess() {
                        DemoLog.i(TAG, "doForeground success");
                    }
                });
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
                int unReadCount = 0;
                List<TIMConversation> conversationList = TIMManager.getInstance().getConversationList();
                for (TIMConversation timConversation : conversationList) {
                    unReadCount += timConversation.getUnreadMessageNum();
                }
                TIMBackgroundParam param = new TIMBackgroundParam();
                param.setC2cUnread(unReadCount);
                TIMManager.getInstance().doBackground(param, new TIMCallBack() {
                    @Override
                    public void onError(int code, String desc) {
                        DemoLog.e(TAG, "doBackground err = " + code + ", desc = " + desc);
                    }

                    @Override
                    public void onSuccess() {
                        DemoLog.i(TAG, "doBackground success");
                    }
                });
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

    public static DemoApplication instance() {
        return instance;
    }

}
