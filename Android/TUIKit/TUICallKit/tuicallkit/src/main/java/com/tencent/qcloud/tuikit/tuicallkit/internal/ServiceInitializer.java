package com.tencent.qcloud.tuikit.tuicallkit.internal;

import android.app.Activity;
import android.app.Application;
import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKitImpl;

/**
 * `TUICallKit` uses `ContentProvider` to be registered with `TUICore`.
 * (`TUICore` is the connection and communication class of each component)
 */
public final class ServiceInitializer extends ContentProvider {
    public void init(Context context) {
        TUICallingService callingService = TUICallingService.sharedInstance();
        callingService.init(context);
        TUICore.registerService(TUIConstants.TUICalling.SERVICE_NAME, callingService);
        TUICore.registerExtension(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_AUDIO_CALL, callingService);
        TUICore.registerExtension(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL, callingService);

        TUIAudioMessageRecordService audioRecordService = new TUIAudioMessageRecordService(context);
        TUICore.registerService(TUIConstants.TUICalling.SERVICE_NAME_AUDIO_RECORD, audioRecordService);

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
                        if (TUILogin.isUserLogined()) {
                            TUICallKitImpl.createInstance(context).queryOfflineCall();
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

    @Override
    public boolean onCreate() {
        Context appContext = getContext().getApplicationContext();
        init(appContext);
        return false;
    }

    @Nullable
    @Override
    public Cursor query(@NonNull Uri uri, @Nullable String[] projection, @Nullable String selection,
                        @Nullable String[] selectionArgs, @Nullable String sortOrder) {
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
    public int update(@NonNull Uri uri, @Nullable ContentValues values, @Nullable String selection,
                      @Nullable String[] selectionArgs) {
        return 0;
    }
}
