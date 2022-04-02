package com.tencent.liteav.trtccalling.model.impl;

import android.app.Activity;
import android.app.Application;
import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.liteav.trtccalling.TUICallingImpl;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;


/**
 * 各模块如果需要初始化，需要实现此类的 init 方法，并在 Manifest 文件中以 ContentProvider 的形式注册。
 */
public final class ServiceInitializer extends ContentProvider {
    private static final String TAG = "ServiceInitializer";

    /**
     * 应用启动时自动调起的初始化方法
     *
     * @param context applicationContext
     */
    public void init(Context context) {
        TUICallingService callingService = TUICallingService.sharedInstance();
        callingService.init(context);
        TUICore.registerService(TUIConstants.TUICalling.SERVICE_NAME, callingService);
        TUICore.registerExtension(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_AUDIO_CALL, callingService);
        TUICore.registerExtension(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL, callingService);
        if (context instanceof Application) {
            ((Application) context).registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
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
                        Log.i(TAG, "application enter foreground");
                        //应用回到前台,需要主动去查询是否有未处理的通话请求
                        //例如应用在后台时没有拉起应用的权限,当用户听到铃声,从桌面或通知栏进入应用时,主动查询,拉起通话
                        if (TUILogin.isUserLogined()) {
                            TUICallingImpl.sharedInstance(context).queryOfflineCalling();
                        }
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
                    isChangingConfiguration = activity.isChangingConfigurations();
                }

                @Override
                public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

                }

                @Override
                public void onActivityDestroyed(Activity activity) {

                }
            });
        }
    }

/////////////////////////////////////////////////////////////////////////////////
//                               以下方法无需重写                                 //
/////////////////////////////////////////////////////////////////////////////////

    @Override
    public boolean onCreate() {
        Context appContext = getContext().getApplicationContext();
        init(appContext);
        return false;
    }

    @Nullable
    @Override
    public Cursor query(@NonNull Uri uri, @Nullable String[] projection, @Nullable String selection, @Nullable String[] selectionArgs, @Nullable String sortOrder) {
        return null;
    }

    @Nullable
    @Override
    public String getType(@NonNull Uri uri) {
        return null;
    }

    @Nullable
    @Override
    public Uri insert(@NonNull Uri uri, @Nullable ContentValues values) {
        return null;
    }

    @Override
    public int delete(@NonNull Uri uri, @Nullable String selection, @Nullable String[] selectionArgs) {
        return 0;
    }

    @Override
    public int update(@NonNull Uri uri, @Nullable ContentValues values, @Nullable String selection, @Nullable String[] selectionArgs) {
        return 0;
    }
}
