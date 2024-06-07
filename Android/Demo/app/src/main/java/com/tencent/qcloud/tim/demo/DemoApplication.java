package com.tencent.qcloud.tim.demo;

import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ApplicationInfo;
import android.text.TextUtils;
import android.util.Log;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.multidex.MultiDex;
import com.tencent.bugly.crashreport.CrashReport;
import com.tencent.qcloud.tim.demo.config.AppConfig;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.PrivateConstants;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIObjectFactory;
import com.tencent.qcloud.tuikit.timcommon.util.TUIUtil;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.config.TUICustomerServiceConfig;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class DemoApplication extends Application {
    private static final String TAG = DemoApplication.class.getSimpleName();

    @Override
    public void onCreate() {
        Log.i(TAG, "onCreate");
        super.onCreate();

        if (isMainProcess()) {
            MultiDex.install(this);

            initBugly();
            initIMDemoAppInfo();
            setPermissionRequestContent();
            registerLanguageChangedReceiver();
            initTUICustomerServiceAccounts();
        }
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        // add language changed listener
        TUICore.registerEvent(
            TUIConstants.TUICore.LANGUAGE_EVENT, TUIConstants.TUICore.LANGUAGE_EVENT_SUB_KEY, new ITUINotification() {
                @Override
                public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
                    TUIThemeManager.setWebViewLanguage(base);
                }
            });
    }

    private void registerLanguageChangedReceiver() {
        BroadcastReceiver languageChangedReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                setPermissionRequestContent();
            }
        };

        IntentFilter languageFilter = new IntentFilter();
        languageFilter.addAction(Constants.DEMO_LANGUAGE_CHANGED_ACTION);
        LocalBroadcastManager.getInstance(this).registerReceiver(languageChangedReceiver, languageFilter);
    }

    private void initTUICustomerServiceAccounts() {
        List<String> customerServiceAccountList = new ArrayList<>();
        customerServiceAccountList.add("@im_agent#online_shopping_mall");
        customerServiceAccountList.add("@im_agent#online_doctor");
        TUICustomerServiceConfig.getInstance().setCustomerServiceAccounts(customerServiceAccountList);
    }

    public void setPermissionRequestContent() {
        ApplicationInfo applicationInfo = getApplicationInfo();
        CharSequence labelCharSequence = applicationInfo.loadLabel(getPackageManager());
        String appName = "App";
        if (!TextUtils.isEmpty(labelCharSequence)) {
            appName = labelCharSequence.toString();
        }
        String micReason = getResources().getString(R.string.demo_permission_mic_reason);
        String micDeniedAlert = getResources().getString(R.string.demo_permission_mic_dialog_alert, appName);

        String cameraReason = getResources().getString(R.string.demo_permission_camera_reason);
        String cameraDeniedAlert = getResources().getString(R.string.demo_permission_camera_dialog_alert, appName);

        TUICore.unregisterObjectFactory(TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME);
        TUICore.registerObjectFactory(TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME, new ITUIObjectFactory() {
            @Override
            public Object onCreateObject(String objectName, Map<String, Object> param) {
                if (TextUtils.equals(
                        objectName, TUIConstants.Privacy.PermissionsFactory.PermissionsName.CAMERA_PERMISSIONS)) {
                    return cameraReason;
                } else if (TextUtils.equals(objectName,
                               TUIConstants.Privacy.PermissionsFactory.PermissionsName.MICROPHONE_PERMISSIONS)) {
                    return micReason;
                } else if (TextUtils.equals(objectName,
                               TUIConstants.Privacy.PermissionsFactory.PermissionsName.CAMERA_PERMISSIONS_TIP)) {
                    return cameraDeniedAlert;
                } else if (TextUtils.equals(objectName,
                               TUIConstants.Privacy.PermissionsFactory.PermissionsName.MICROPHONE_PERMISSIONS_TIP)) {
                    return micDeniedAlert;
                }
                return null;
            }
        });
    }

    private void initBugly() {
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT, new ITUINotification() {
                @Override
                public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
                    CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(getApplicationContext());
                    strategy.setAppVersion(BuildConfig.VERSION_NAME);
                    strategy.setDeviceModel(BrandUtil.getBuildModel());
                    CrashReport.initCrashReport(getApplicationContext(), PrivateConstants.BUGLY_APPID, true, strategy);
                }
            });
    }

    private void initIMDemoAppInfo() {
        TUIConfig.setTUIHostType(TUIConfig.TUI_HOST_TYPE_IMAPP);
        try {
            Field field = BuildConfig.class.getField("FLAVOR");
            AppConfig.DEMO_FLAVOR_VERSION = (String) field.get(null);
        } catch (NoSuchFieldException | IllegalAccessException | ClassCastException e) {
            // ignore
        }
    }

    private boolean isMainProcess() {
        String mainProcessName = this.getPackageName();
        String currentProcessName = TUIUtil.getProcessName();
        if (mainProcessName.equals(currentProcessName)) {
            return true;
        } else {
            return false;
        }
    }
}