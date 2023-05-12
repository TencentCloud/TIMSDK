package com.tencent.qcloud.tim.demo;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import androidx.multidex.MultiDex;

import com.tencent.bugly.crashreport.CrashReport;
import com.tencent.imsdk.BuildConfig;
import com.tencent.qcloud.tim.demo.bean.UserInfo;
import com.tencent.qcloud.tim.demo.config.AppConfig;
import com.tencent.qcloud.tim.demo.login.LoginForDevActivity;
import com.tencent.qcloud.tim.demo.main.MainActivity;
import com.tencent.qcloud.tim.demo.main.MainMinimalistActivity;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.PrivateConstants;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUILoginListener;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TUIUtil;

import java.util.Map;

public class DemoApplication extends Application {

    private static final String TAG = DemoApplication.class.getSimpleName();

    private static DemoApplication instance;
    public static DemoApplication instance() {
        return instance;
    }


    @Override
    public void onCreate() {
        Log.i(TAG, "onCreate");
        super.onCreate();

        if (isMainProcess()) {
            instance = this;
            MultiDex.install(this);

            registerActivityLifecycleCallbacks(new StatisticActivityLifecycleCallback());
            initLoginStatusListener();
            initBugly();
            initIMDemoAppInfo();
        }
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        // add language changed listener
        TUICore.registerEvent(TUIConstants.TUICore.LANGUAGE_EVENT, TUIConstants.TUICore.LANGUAGE_EVENT_SUB_KEY, new ITUINotification() {
            @Override
            public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
                TUIThemeManager.setWebViewLanguage(base);
            }
        });
    }

    private void initBugly() {
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT, new ITUINotification() {
            @Override
            public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
                CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(getApplicationContext());
                strategy.setAppVersion(AppConfig.DEMO_VERSION_NAME);
                strategy.setDeviceModel(BrandUtil.getBuildModel());
                CrashReport.initCrashReport(getApplicationContext(), PrivateConstants.BUGLY_APPID, true, strategy);
            }
        });
    }

    private void initIMDemoAppInfo() {
        TUIConfig.setTUIHostType(TUIConfig.TUI_HOST_TYPE_IMAPP);
        if (TextUtils.equals(BuildConfig.FLAVOR, Constants.FLAVOR_INTERNATIONAL)){
            AppConfig.DEMO_FLAVOR_VERSION = Constants.FLAVOR_INTERNATIONAL;
        }
        AppConfig.DEMO_VERSION_NAME = BuildConfig.VERSION_NAME;
    }

    public void initLoginStatusListener() {
        TUILogin.addLoginListener(loginStatusListener);
    }

    private final TUILoginListener loginStatusListener = new TUILoginListener() {
        @Override
        public void onKickedOffline() {
            ToastUtil.toastLongMessage(DemoApplication.instance().getString(R.string.repeat_login_tip));
            logout();
        }

        @Override
        public void onUserSigExpired() {
            ToastUtil.toastLongMessage(DemoApplication.instance().getString(R.string.expired_login_tip));
            TUILogin.logout(new TUICallback() {
                @Override
                public void onSuccess() {
                    logout();
                }

                @Override
                public void onError(int errorCode, String errorMessage) {
                    logout();
                }
            });
        }
    };

    public void logout() {
        DemoLog.i(TAG, "logout");
        UserInfo.getInstance().cleanUserInfo();

        Intent intent = new Intent(this, LoginForDevActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("LOGOUT", true);
        startActivity(intent);

        if (AppConfig.DEMO_UI_STYLE == 0) {
            MainActivity.finishMainActivity();
        } else {
            MainMinimalistActivity.finishMainActivity();
        }
    }

    class StatisticActivityLifecycleCallback implements ActivityLifecycleCallbacks {


        @Override
        public void onActivityCreated(Activity activity, Bundle bundle) {
            DemoLog.i(TAG, "onActivityCreated bundle: " + bundle);
            if (bundle != null) {
                // restart app
                Intent intent = new Intent(activity, SplashActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        }

        @Override
        public void onActivityStarted(Activity activity) {

        }

        @Override
        public void onActivityResumed(Activity activity) {

        }

        @Override
        public void onActivityPaused(Activity activity) {

        }

        @Override
        public void onActivityStopped(Activity activity) {

        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {

        }

        @Override
        public void onActivityDestroyed(Activity activity) {

        }
    }

    private boolean isMainProcess() {
        ActivityManager am = ((ActivityManager) this.getSystemService(Context.ACTIVITY_SERVICE));
        String mainProcessName = this.getPackageName();
        String currentProcessName = TUIUtil.getProcessName();
        if (mainProcessName.equals(currentProcessName)) {
            return true;
        } else {
            return false;
        }
    }
}