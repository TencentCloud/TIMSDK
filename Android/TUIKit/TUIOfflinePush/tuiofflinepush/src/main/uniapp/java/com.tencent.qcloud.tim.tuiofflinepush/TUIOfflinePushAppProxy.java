package com.tencent.qcloud.tim.tuiofflinepush;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;

import com.huawei.agconnect.config.AGConnectServicesConfig;
import com.huawei.agconnect.config.LazyInputStream;

import java.io.IOException;
import java.io.InputStream;

import io.dcloud.feature.uniapp.UniAppHookProxy;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;


public class TUIOfflinePushAppProxy implements UniAppHookProxy {
    public static final String TAG = TUIOfflinePushAppProxy.class.getSimpleName();

    @Override
    public void onCreate(Application application) {
        Context context = application.getApplicationContext();

        init(context);
    }

    private void init(Context context) {
        //可写初始化触发逻辑
        TUIOfflinePushLog.d(TAG, "onCreate--");
        AGConnectServicesConfig config = AGConnectServicesConfig.fromContext(context);
        config.overlayWith(new LazyInputStream(context) {
            public InputStream get(Context context) {
                try {
                    return context.getAssets().open("agconnect-services.json");
                } catch (IOException e) {
                    TUIOfflinePushLog.d(TAG, "onCreate-- e = " + e);
                    return null;
                }
            }
        });

        String package_name=context.getPackageName();
        PackageManager packageManager = context.getPackageManager();
        Intent intent = packageManager.getLaunchIntentForPackage(package_name);
        if (intent != null) {
            context.startActivity(intent);
        } else {
            TUIOfflinePushLog.d(TAG, "getLaunchIntentForPackage is null");
        }

        TUIOfflinePushManager.getInstance().callJsNotificationCallback();
        TUIOfflinePushManager.getInstance().initActivityLifecycle(context);
        TUIOfflinePushConfig.getInstance().setContext(context);
    }

    @Override
    public void onSubProcessCreate(Application application) {
        //子进程初始化回调
    }
}
