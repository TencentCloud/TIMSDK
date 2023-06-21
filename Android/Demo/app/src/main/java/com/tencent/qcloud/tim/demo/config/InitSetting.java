package com.tencent.qcloud.tim.demo.config;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.res.Resources;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.push.OfflinePushAPIDemo;
import com.tencent.qcloud.tim.demo.push.OfflinePushConfigs;
import com.tencent.qcloud.tim.demo.push.OfflinePushLocalReceiver;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.tuiofflinepush.utils.BrandUtil;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.interfaces.ITUIObjectFactory;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.PermissionRequester;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
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
        initOfflinePushConfigs();
        initDemoStyle();
    }

    private void initDemoStyle() {
        final SharedPreferences sharedPreferences = mContext.getSharedPreferences("TUIKIT_DEMO_SETTINGS", mContext.MODE_PRIVATE);
        AppConfig.DEMO_UI_STYLE = sharedPreferences.getInt("tuikit_demo_style", 0);
    }

    public void setPermissionRequestContent() {
        ApplicationInfo applicationInfo = TUIChatService.getAppContext().getApplicationInfo();
        Resources resources = TUIChatService.getAppContext().getResources();
        String appName = resources.getString(applicationInfo.labelRes);

        PermissionRequester.PermissionRequestContent microphoneContent = new PermissionRequester.PermissionRequestContent();
        microphoneContent.setReasonTitle(mContext.getResources().getString(R.string.demo_permission_mic_reason_title, appName));
        String micReason = mContext.getResources().getString(R.string.demo_permission_mic_reason);
        microphoneContent.setReason(micReason);
        microphoneContent.setIconResId(R.drawable.demo_permission_icon_mic);
        microphoneContent.setDeniedAlert(mContext.getResources().getString(R.string.demo_permission_mic_dialog_alert, appName));
        PermissionRequester.setPermissionRequestContent(PermissionRequester.PermissionConstants.MICROPHONE, microphoneContent);

        PermissionRequester.PermissionRequestContent cameraContent = new PermissionRequester.PermissionRequestContent();
        cameraContent.setReasonTitle(mContext.getResources().getString(R.string.demo_permission_camera_reason_title, appName));
        String cameraReason = mContext.getResources().getString(R.string.demo_permission_camera_reason);
        cameraContent.setReason(cameraReason);
        cameraContent.setIconResId(R.drawable.demo_permission_icon_camera);
        cameraContent.setDeniedAlert(mContext.getResources().getString(R.string.demo_permission_camera_dialog_alert, appName));
        PermissionRequester.setPermissionRequestContent(PermissionRequester.PermissionConstants.CAMERA, cameraContent);

        TUICore.unregisterObjectFactory(TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME);
        TUICore.registerObjectFactory(TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME, new ITUIObjectFactory() {
            @Override
            public Object onCreateObject(String objectName, Map<String, Object> param) {
                if (TextUtils.equals(objectName, TUIConstants.Privacy.PermissionsFactory.PermissionsName.CAMERA_PERMISSIONS)) {
                    return cameraReason;
                } else if (TextUtils.equals(objectName, TUIConstants.Privacy.PermissionsFactory.PermissionsName.MICROPHONE_PERMISSIONS)) {
                    return micReason;
                }
                return null;
            }
        });

    }

    private void initOfflinePushConfigs() {
        final SharedPreferences sharedPreferences = mContext.getSharedPreferences("TUIKIT_DEMO_SETTINGS", mContext.MODE_PRIVATE);
        int registerMode = sharedPreferences.getInt("test_OfflinePushRegisterMode_v2", 1);
        int callbackMode = sharedPreferences.getInt("test_OfflinePushCallbackMode_v2", 1);
        Log.i(TAG, "initOfflinePushConfigs registerMode = " + registerMode);
        Log.i(TAG, "initOfflinePushConfigs callbackMode = " + callbackMode);

        OfflinePushConfigs.getOfflinePushConfigs().setRegisterPushMode(registerMode);
        OfflinePushConfigs.getOfflinePushConfigs().setClickNotificationCallbackMode(callbackMode);

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

}
