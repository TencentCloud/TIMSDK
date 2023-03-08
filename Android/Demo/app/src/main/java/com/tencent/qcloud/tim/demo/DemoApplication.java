package com.tencent.qcloud.tim.demo;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.res.Resources;
import android.os.Bundle;
import android.util.Log;

import androidx.multidex.MultiDex;

import com.tencent.bugly.crashreport.CrashReport;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.bean.UserInfo;
import com.tencent.qcloud.tim.demo.login.LoginForDevActivity;
import com.tencent.qcloud.tim.demo.main.MainActivity;
import com.tencent.qcloud.tim.demo.main.MainMinimalistActivity;
import com.tencent.qcloud.tim.demo.push.OfflinePushAPIDemo;
import com.tencent.qcloud.tim.demo.push.OfflinePushConfigs;
import com.tencent.qcloud.tim.demo.push.OfflinePushLocalReceiver;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.PrivateConstants;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUILoginListener;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.PermissionRequester;
import com.tencent.qcloud.tuicore.util.TUIUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class DemoApplication extends Application {

    private static final String TAG = DemoApplication.class.getSimpleName();

    private static DemoApplication instance;

    public static DemoApplication instance() {
        return instance;
    }

    private int sdkAppId = 0;
    private OfflinePushLocalReceiver offlinePushLocalReceiver = null;
    private OfflinePushAPIDemo offlinePushAPIDemo;
    public static int tuikit_demo_style = 0; //0,classic; 1,minimalist
    @Override
    public void onCreate() {
        Log.i(TAG, "onCreate");
        super.onCreate();

        if (isMainProcess()) {
            instance = this;
            MultiDex.install(this);

            // add Demo theme
            TUIThemeManager.addLightTheme(R.style.DemoLightTheme);
            TUIThemeManager.addLivelyTheme(R.style.DemoLivelyTheme);
            TUIThemeManager.addSeriousTheme(R.style.DemoSeriousTheme);

            // add language changed listener
            TUICore.registerEvent(TUIConstants.TUICore.LANGUAGE_EVENT, TUIConstants.TUICore.LANGUAGE_EVENT_SUB_KEY, new ITUINotification() {
                @Override
                public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
                    TUIThemeManager.setWebViewLanguage(DemoApplication.this);
                }
            });

            registerActivityLifecycleCallbacks(new StatisticActivityLifecycleCallback());
            initLoginStatusListener();
            setPermissionRequestContent();
            TUIChatConfigs.getConfigs().getGeneralConfig().setEnableMultiDeviceForCall(true);
            TUIChatConfigs.getConfigs().getGeneralConfig().setEnableTextTranslation(true);
            initOfflinePushConfigs();
            initDemoStyle();
        }
    }

    private void initDemoStyle() {
        final SharedPreferences sharedPreferences = getSharedPreferences("TUIKIT_DEMO_SETTINGS", MODE_PRIVATE);
        tuikit_demo_style = sharedPreferences.getInt("tuikit_demo_style", 0);
    }

    private void initBugly() {
        CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(getApplicationContext());
        strategy.setAppVersion(BuildConfig.VERSION_NAME);
        strategy.setDeviceModel(BrandUtil.getBuildModel());
        CrashReport.initCrashReport(getApplicationContext(), PrivateConstants.BUGLY_APPID, true, strategy);
    }

    private void initBuildInformation() {
        try {
            JSONObject buildInfoJson = new JSONObject();
            buildInfoJson.put("buildBrand", BrandUtil.getBuildBrand());
            buildInfoJson.put("buildManufacturer", BrandUtil.getBuildManufacturer());
            buildInfoJson.put("buildModel", BrandUtil.getBuildModel());
            buildInfoJson.put("buildVersionRelease", BrandUtil.getBuildVersionRelease());
            buildInfoJson.put("buildVersionSDKInt", BrandUtil.getBuildVersionSDKInt());
            // 工信部要求 app 在运行期间只能获取一次设备信息。因此 app 获取设备信息设置给 SDK 后，SDK 使用该值并且不再调用系统接口。
            // The Ministry of Industry and Information Technology requires the app to obtain device information only once 
            // during its operation. Therefore, after the app obtains the device information and sets it to the SDK, the SDK 
            // uses this value and no longer calls the system interface.
            V2TIMManager.getInstance().callExperimentalAPI("setBuildInfo", buildInfoJson.toString(), new V2TIMValueCallback<Object>() {
                @Override
                public void onSuccess(Object o) {
                    DemoLog.i(TAG, "setBuildInfo success");
                }

                @Override
                public void onError(int code, String desc) {
                    DemoLog.i(TAG, "setBuildInfo code:" + code + " desc:" + ErrorMessageConverter.convertIMError(code, desc));
                }
            });
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void init(int imsdkAppId) {
        initBuildInformation();
        initBugly();
        if (imsdkAppId != 0) {
            sdkAppId = imsdkAppId;
        } else {
            sdkAppId = GenerateTestUserSig.SDKAPPID;
        }
    }

    public int getSdkAppId() {
        return sdkAppId;
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

        if (DemoApplication.tuikit_demo_style == 0) {
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
    private void setPermissionRequestContent() {
        ApplicationInfo applicationInfo = this.getApplicationInfo();
        Resources resources = this.getResources();
        String appName = resources.getString(applicationInfo.labelRes);

        PermissionRequester.PermissionRequestContent microphoneContent = new PermissionRequester.PermissionRequestContent();
        microphoneContent.setReasonTitle(getString(R.string.demo_permission_mic_reason_title, appName));
        microphoneContent.setReason(getString(R.string.demo_permission_mic_reason));
        microphoneContent.setIconResId(R.drawable.demo_permission_icon_mic);
        microphoneContent.setDeniedAlert(getString(R.string.demo_permission_mic_dialog_alert, appName));
        PermissionRequester.setPermissionRequestContent(PermissionRequester.PermissionConstants.MICROPHONE, microphoneContent);

        PermissionRequester.PermissionRequestContent cameraContent = new PermissionRequester.PermissionRequestContent();
        cameraContent.setReasonTitle(getString(R.string.demo_permission_camera_reason_title, appName));
        cameraContent.setReason(getString(R.string.demo_permission_camera_reason));
        cameraContent.setIconResId(R.drawable.demo_permission_icon_camera);
        cameraContent.setDeniedAlert(getString(R.string.demo_permission_camera_dialog_alert, appName));
        PermissionRequester.setPermissionRequestContent(PermissionRequester.PermissionConstants.CAMERA, cameraContent);
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

    private void initOfflinePushConfigs() {
        final SharedPreferences sharedPreferences = getSharedPreferences("TUIKIT_DEMO_SETTINGS", MODE_PRIVATE);
        int registerMode= sharedPreferences.getInt("test_OfflinePushRegisterMode_v2", 1);
        int callbackMode= sharedPreferences.getInt("test_OfflinePushCallbackMode_v2", 1);
        Log.i(TAG, "initOfflinePushConfigs registerMode = " + registerMode);
        Log.i(TAG, "initOfflinePushConfigs callbackMode = " + callbackMode);

        OfflinePushConfigs.getOfflinePushConfigs().setRegisterPushMode(registerMode);
        OfflinePushConfigs.getOfflinePushConfigs().setClickNotificationCallbackMode(callbackMode);

        // register callback
        registerNotify();
    }

    // call after login success
    public void registerPushManually() {
        int registerMode = OfflinePushConfigs.getOfflinePushConfigs().getRegisterPushMode();
        DemoLog.d(TAG, "OfflinePush register mode:" + registerMode);
        if (registerMode == OfflinePushConfigs.REGISTER_PUSH_MODE_AUTO) {
            return;
        }
        if (offlinePushAPIDemo == null) {
            offlinePushAPIDemo = new OfflinePushAPIDemo();
        }
        offlinePushAPIDemo.registerPush(instance);
    }

    // call in Application onCreate
    private void registerNotify() {
        if (offlinePushAPIDemo == null) {
            offlinePushAPIDemo = new OfflinePushAPIDemo();
        }

        int callbackMode = OfflinePushConfigs.getOfflinePushConfigs().getClickNotificationCallbackMode();
        Log.d(TAG, "OfflinePush callback mode:" + callbackMode);
        switch (callbackMode) {
            case OfflinePushConfigs.CLICK_NOTIFICATION_CALLBACK_NOTIFY:
                // 1 TUICore NotifyEvent
                offlinePushAPIDemo.registerNotifyEvent();
                break;
            case OfflinePushConfigs.CLICK_NOTIFICATION_CALLBACK_BROADCAST:
                // 2 broadcast
                if (offlinePushLocalReceiver == null) {
                    offlinePushLocalReceiver = new OfflinePushLocalReceiver();
                }
                offlinePushAPIDemo.registerNotificationReceiver(instance, offlinePushLocalReceiver);
                break;
            default:
                // 3 intent
                break;
        }
    }
}
