package com.tencent.qcloud.tim.tuiofflinepush;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;
import com.huawei.agconnect.config.AGConnectServicesConfig;
import com.huawei.agconnect.config.LazyInputStream;
import java.io.IOException;
import java.io.InputStream;

public class TUIOfflinePushService extends ContentProvider {
    public static final String TAG = TUIOfflinePushService.class.getSimpleName();

    public static Context appContext;

    @Override
    public boolean onCreate() {
        appContext = getContext().getApplicationContext();
        ;
        initPush(appContext);
        return false;
    }

    private void initPush(Context context) {
        // 可写初始化触发逻辑
        Log.d(TAG, "onCreate--");
        AGConnectServicesConfig config = AGConnectServicesConfig.fromContext(context);
        config.overlayWith(new LazyInputStream(context) {
            public InputStream get(Context context) {
                try {
                    return context.getAssets().open("agconnect-services.json");
                } catch (IOException e) {
                    Log.d(TAG, "onCreate-- e = " + e);
                    return null;
                }
            }
        });

        String packageName = context.getPackageName();
        PackageManager packageManager = context.getPackageManager();
        Intent intent = packageManager.getLaunchIntentForPackage(packageName);
        Log.d(TAG, "onCreate package_name = " + packageName);
        if (intent != null) {
            Log.d(TAG, "startActivity begin");
            context.startActivity(intent);
            Log.d(TAG, "startActivity end");
        } else {
            Log.d(TAG, "intent == null");
        }

        TUIOfflinePushManager.getInstance().callJsNotificationCallback();
        TUIOfflinePushManager.getInstance().initActivityLifecycle(context);
        TUIOfflinePushConfig.getInstance().setContext(context);
    }

    @Override
    public Cursor query(Uri uri, String[] strings, String s, String[] strings1, String s1) {
        return null;
    }

    @Override
    public String getType(Uri uri) {
        return null;
    }

    @Override
    public Uri insert(Uri uri, ContentValues contentValues) {
        return null;
    }

    @Override
    public int delete(Uri uri, String s, String[] strings) {
        return 0;
    }

    @Override
    public int update(Uri uri, ContentValues contentValues, String s, String[] strings) {
        return 0;
    }
}
