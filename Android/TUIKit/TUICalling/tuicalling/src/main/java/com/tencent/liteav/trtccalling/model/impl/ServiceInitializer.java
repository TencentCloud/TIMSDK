package com.tencent.liteav.trtccalling.model.impl;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;


/**
 * 各模块如果需要初始化，需要实现此类的 init 方法，并在 Manifest 文件中以 ContentProvider 的形式注册。
 */
public final class ServiceInitializer extends ContentProvider {

    /**
     * 应用启动时自动调起的初始化方法
     * @param context applicationContext
     */
    public void init(Context context) {
        // 必然存在编译依赖
        TUICallingManager.sharedInstance().init(context);
        // 可能存在编译依赖，所以要动态反射调用
        initTUICallingService(context);
    }

    private void initTUICallingService(Context context) {
        try {
            Class clazz = Class.forName("com.tencent.liteav.trtccalling.model.impl.TUICallingService");
            Method method = clazz.getDeclaredMethod("sharedInstance");
            Object object = method.invoke(clazz);
            method = clazz.getDeclaredMethod("init", new Class[]{Context.class});
            method.invoke(object, context);
            Log.d("ServiceInitializer", "TUICallingService init success!!!");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
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
