package com.tencent.qcloud.tuicore;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * If each module needs to be initialized, it needs to implement the init method of this class 
 * and register it in the form of ContentProvider in the Manifest file.
 */
public class ServiceInitializer extends ContentProvider {

    /**
     * @param context applicationContext
     */
    public void init(Context context) {}

    /**
     * LightTheme id
     */
    public int getLightThemeResId() {
        return R.style.TUIBaseLightTheme;
    }

    /**
     * LivelyTheme id
     */
    public int getLivelyThemeResId() {
        return R.style.TUIBaseLivelyTheme;
    }

    /**
     * SeriousTheme id
     */
    public int getSeriousThemeResId() {
        return R.style.TUIBaseSeriousTheme;
    }

/////////////////////////////////////////////////////////////////////////////////
//             The following methods do not need to be overridden                      //
/////////////////////////////////////////////////////////////////////////////////

    private static Context appContext;

    public static Context getAppContext() {
        return appContext;
    }

    @Override
    public boolean onCreate() {
        if (appContext == null) {
            appContext = getContext().getApplicationContext();
        }
        
        TUIRouter.init(appContext);
        TUIConfig.init(appContext);
        TUIThemeManager.addLightTheme(getLightThemeResId());
        TUIThemeManager.addLivelyTheme(getLivelyThemeResId());
        TUIThemeManager.addSeriousTheme(getSeriousThemeResId());
        TUIThemeManager.setTheme(appContext);
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
