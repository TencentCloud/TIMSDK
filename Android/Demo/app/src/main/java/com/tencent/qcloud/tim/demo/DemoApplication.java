package com.tencent.qcloud.tim.demo;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;

import androidx.multidex.MultiDex;

import com.tencent.bugly.crashreport.CrashReport;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.login.LoginForDevActivity;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.thirdpush.OEMPush.HUAWEIHmsMessageService;
import com.tencent.qcloud.tim.demo.thirdpush.PushSetting;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.PrivateConstants;
import com.tencent.qcloud.tim.demo.bean.UserInfo;

import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.vivo.push.PushClient;
import com.xiaomi.mipush.sdk.MiPushClient;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class DemoApplication extends Application {

    private static final String TAG = DemoApplication.class.getSimpleName();

    private static DemoApplication instance;

    public static DemoApplication instance() {
        return instance;
    }

    private PushSetting pushSetting = new PushSetting();
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

        /**
         * TUIKit的初始化函数
         *
         * @param context  应用的上下文，一般为对应应用的ApplicationContext
         * @param sdkAppID 您在腾讯云注册应用时分配的sdkAppID
         * @param configs  TUIKit的相关配置项，一般使用默认即可，需特殊配置参考API文档
         */
        try {
            JSONObject buildInfoJson = new JSONObject();
            buildInfoJson.put("buildBrand", BrandUtil.getBuildBrand());
            buildInfoJson.put("buildManufacturer", BrandUtil.getBuildManufacturer());
            buildInfoJson.put("buildModel", BrandUtil.getBuildModel());
            buildInfoJson.put("buildVersionRelease", BrandUtil.getBuildVersionRelease());
            buildInfoJson.put("buildVersionSDKInt", BrandUtil.getBuildVersionSDKInt());
            // 工信部要求 app 在运行期间只能获取一次设备信息。因此 app 获取设备信息设置给 SDK 后，SDK 使用该值并且不再调用系统接口。
            V2TIMManager.getInstance().callExperimentalAPI("setBuildInfo", buildInfoJson.toString(), new V2TIMValueCallback<Object>() {
                @Override
                public void onSuccess(Object o) {
                    DemoLog.i(TAG, "setBuildInfo success");
                }

                @Override
                public void onError(int code, String desc) {
                    DemoLog.i(TAG, "setBuildInfo code:" + code + " desc:" + desc);
                }
            });
        } catch (JSONException e) {
            e.printStackTrace();
        }

        registerActivityLifecycleCallbacks(new StatisticActivityLifecycleCallback());
        initLoginStatusListener();
    }

    public void init() {
        TUIUtils.init(this, GenerateTestUserSig.SDKAPPID, null, null);

    }

    public void initPush() {
        if (pushSetting == null) {
            pushSetting = new PushSetting();
        }
        pushSetting.initPush();
    }

    public void bindUserID(String userId) {
        if (pushSetting == null) {
            pushSetting = new PushSetting();
        }
        pushSetting.bindUserID(userId);
    }

    public void unBindUserID(String userId) {
        if (pushSetting == null) {
            pushSetting = new PushSetting();
        }
        pushSetting.unBindUserID(userId);
    }

    public void unInitPush(){
        if (pushSetting == null) {
            pushSetting = new PushSetting();
        }
        pushSetting.unInitPush();
    }

    public void initLoginStatusListener() {
        V2TIMManager.getInstance().addIMSDKListener(loginStatusListener);
    }

    private final V2TIMSDKListener loginStatusListener = new V2TIMSDKListener() {
        @Override
        public void onKickedOffline() {
            ToastUtil.toastLongMessage(DemoApplication.instance().getString(R.string.repeat_login_tip));
            logout();
        }

        @Override
        public void onUserSigExpired() {
            ToastUtil.toastLongMessage(DemoApplication.instance().getString(R.string.expired_login_tip));
            logout();
        }
    };

    public void logout() {
        DemoLog.i(TAG, "logout");
        UserInfo.getInstance().setToken("");
        UserInfo.getInstance().setAutoLogin(false);

        unBindUserID(UserInfo.getInstance().getUserId());
        unInitPush();

        Intent intent = new Intent(this, LoginForDevActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("LOGOUT", true);
        startActivity(intent);
    }

    class StatisticActivityLifecycleCallback implements ActivityLifecycleCallbacks {
        private int foregroundActivities = 0;
        private boolean isChangingConfiguration;

        private final V2TIMConversationListener unreadListener = new V2TIMConversationListener() {
            @Override
            public void onTotalUnreadMessageCountChanged(long totalUnreadCount) {
                HUAWEIHmsMessageService.updateBadge(DemoApplication.this, (int) totalUnreadCount);
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

                V2TIMManager.getConversationManager().removeConversationListener(unreadListener);
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
                V2TIMManager.getConversationManager().getTotalUnreadMessageCount(new V2TIMValueCallback<Long>() {
                    @Override
                    public void onSuccess(Long aLong) {
                        int totalCount = aLong.intValue();
                        V2TIMManager.getOfflinePushManager().doBackground(totalCount, new V2TIMCallback() {
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

                    @Override
                    public void onError(int code, String desc) {

                    }
                });

                V2TIMManager.getConversationManager().addConversationListener(unreadListener);
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
