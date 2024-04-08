package com.tencent.qcloud.tim.demo.config;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.custom.CustomConfigHelper;
import com.tencent.qcloud.tim.demo.push.OfflinePushAPIDemo;
import com.tencent.qcloud.tim.demo.push.OfflinePushConfigs;
import com.tencent.qcloud.tim.demo.push.OfflinePushLocalReceiver;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.PermissionRequester;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class InitSetting {
    private static final String TAG = InitSetting.class.getSimpleName();
    public Context mContext;
    private OfflinePushAPIDemo offlinePushAPIDemo;
    private OfflinePushLocalReceiver offlinePushLocalReceiver = null;

    public InitSetting(Context context) {
        this.mContext = context;
    }

    public void init() {
        // add Demo theme
        TUIThemeManager.addLightTheme(R.style.DemoLightTheme);
        TUIThemeManager.addLivelyTheme(R.style.DemoLivelyTheme);
        TUIThemeManager.addSeriousTheme(R.style.DemoSeriousTheme);
        setPermissionRequestContent();
        TUIChatConfigs.getConfigs().getGeneralConfig().setEnableMultiDeviceForCall(true);
        CustomConfigHelper.initCustom(mContext);
        initOfflinePushConfigs();
        initDemoStyle();
    }

    private void initDemoStyle() {
        final SharedPreferences sharedPreferences = mContext.getSharedPreferences("TUIKIT_DEMO_SETTINGS", mContext.MODE_PRIVATE);
        AppConfig.DEMO_UI_STYLE = sharedPreferences.getInt("tuikit_demo_style", AppConfig.DEMO_UI_STYLE_CLASSIC);
    }

    public void setPermissionRequestContent() {
        if (mContext == null) {
            return;
        }
        ApplicationInfo applicationInfo = mContext.getApplicationInfo();
        CharSequence labelCharSequence = applicationInfo.loadLabel(mContext.getPackageManager());
        String appName = "App";
        if (!TextUtils.isEmpty(labelCharSequence)) {
            appName = labelCharSequence.toString();
        }

        PermissionRequester.PermissionRequestContent microphoneContent = new PermissionRequester.PermissionRequestContent();
        microphoneContent.setReasonTitle(mContext.getResources().getString(R.string.demo_permission_mic_reason_title, appName));
        String micReason = mContext.getResources().getString(R.string.demo_permission_mic_reason);
        microphoneContent.setReason(micReason);
        microphoneContent.setIconResId(R.drawable.demo_permission_icon_mic);
        String micDeniedAlert = mContext.getResources().getString(R.string.demo_permission_mic_dialog_alert, appName);
        microphoneContent.setDeniedAlert(micDeniedAlert);
        PermissionRequester.setPermissionRequestContent(PermissionRequester.PermissionConstants.MICROPHONE, microphoneContent);

        PermissionRequester.PermissionRequestContent cameraContent = new PermissionRequester.PermissionRequestContent();
        cameraContent.setReasonTitle(mContext.getResources().getString(R.string.demo_permission_camera_reason_title, appName));
        String cameraReason = mContext.getResources().getString(R.string.demo_permission_camera_reason);
        cameraContent.setReason(cameraReason);
        cameraContent.setIconResId(R.drawable.demo_permission_icon_camera);
        String cameraDeniedAlert = mContext.getResources().getString(R.string.demo_permission_camera_dialog_alert, appName);
        cameraContent.setDeniedAlert(cameraDeniedAlert);
        PermissionRequester.setPermissionRequestContent(PermissionRequester.PermissionConstants.CAMERA, cameraContent);
    }

    private void initOfflinePushConfigs() {
        final SharedPreferences sharedPreferences = mContext.getSharedPreferences("TUIKIT_DEMO_SETTINGS", mContext.MODE_PRIVATE);
        int registerMode = sharedPreferences.getInt("test_OfflinePushRegisterMode_v2", 0);
        int callbackMode = sharedPreferences.getInt("test_OfflinePushCallbackMode_v2", 1);
        Log.i(TAG, "initOfflinePushConfigs registerMode = " + registerMode);
        Log.i(TAG, "initOfflinePushConfigs callbackMode = " + callbackMode);

        OfflinePushConfigs.getOfflinePushConfigs().setRegisterPushMode(registerMode);
        OfflinePushConfigs.getOfflinePushConfigs().setClickNotificationCallbackMode(callbackMode);

        // auto register
        boolean auto = registerMode == 0 ? false : true;
        Map<String, Object> autoParam = new HashMap<>();
        autoParam.put(TUIConstants.TIMPush.DISABLE_AUTO_REGISTER_PUSH_KEY, auto);
        TUICore.callService(TUIConstants.TIMPush.SERVICE_NAME, TUIConstants.TIMPush.METHOD_DISABLE_AUTO_REGISTER_PUSH, autoParam);

        // ring
        boolean enablePrivateRing = sharedPreferences.getBoolean("test_enable_private_ring", false);
        Map<String, Object> param = new HashMap<>();
        param.put(TUIChatConstants.OFFLINE_MESSAGE_PRIVATE_RING, enablePrivateRing);
        TUICore.notifyEvent(TUIChatConstants.EVENT_KEY_OFFLINE_MESSAGE_PRIVATE_RING, TUIChatConstants.EVENT_SUB_KEY_OFFLINE_MESSAGE_PRIVATE_RING, param);

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
        offlinePushAPIDemo.registerPush(mContext);
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
                offlinePushAPIDemo.registerNotificationReceiver(mContext, offlinePushLocalReceiver);
                break;
            default:
                // 3 intent
                break;
        }
    }

    public void initBeforeLogin(int imsdkAppId) {
        Log.d(TAG, "initBeforeLogin sdkAppid = " + imsdkAppId);
        initBuildInformation();
        int sdkAppId = 0;
        if (imsdkAppId != 0) {
            sdkAppId = imsdkAppId;
        } else {
            sdkAppId = GenerateTestUserSig.SDKAPPID;;
        }
        AppConfig.DEMO_SDK_APPID = sdkAppId;
    }

    private void initBuildInformation() {
        try {
            JSONObject buildInfoJson = new JSONObject();
            buildInfoJson.put("buildBrand", BrandUtil.getBuildBrand());
            buildInfoJson.put("buildManufacturer", BrandUtil.getBuildManufacturer());
            buildInfoJson.put("buildModel", BrandUtil.getBuildModel());
            buildInfoJson.put("buildVersionRelease", BrandUtil.getBuildVersionRelease());
            buildInfoJson.put("buildVersionSDKInt", BrandUtil.getBuildVersionSDKInt());
            
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

}
