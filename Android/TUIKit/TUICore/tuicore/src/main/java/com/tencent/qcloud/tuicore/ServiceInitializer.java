package com.tencent.qcloud.tuicore;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * 各模块如果需要初始化，需要实现此类的 init 方法，并在 Manifest 文件中以 ContentProvider 的形式注册。
 */
public class ServiceInitializer extends ContentProvider {

    /**
     * 应用启动时自动调起的初始化方法
     * @param context applicationContext
     */
    public void init(Context context) {}


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
