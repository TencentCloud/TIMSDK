package com.tencent.liteav.demo.beauty.utils;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.NonNull;

public class SPUtils {

    private static final String SP_NAME_DEFAULT = "beauty_default";

    private static SPUtils    sInstance;
    private SharedPreferences mSharedPreferences;

    public static SPUtils get() {
        return get(SP_NAME_DEFAULT, Context.MODE_PRIVATE);
    }

    public static SPUtils get(final int mode) {
        return get(SP_NAME_DEFAULT, mode);
    }

    public static SPUtils get(String spName) {
        return get(spName, Context.MODE_PRIVATE);
    }

    public static SPUtils get(String spName, final int mode) {
        if (sInstance == null) {
            synchronized (SPUtils.class) {
                if (sInstance == null) {
                    sInstance = new SPUtils(spName, mode);
                }
            }
        }
        return sInstance;
    }

    private SPUtils(final String spName, final int mode) {
        mSharedPreferences = BeautyUtils.getApplication().getSharedPreferences(spName, mode);
    }

    public void put(@NonNull final String key, final String value) {
        put(key, value, false);
    }

    public void put(@NonNull final String key, final String value, final boolean isCommit) {
        if (isCommit) {
            mSharedPreferences.edit().putString(key, value).commit();
        } else {
            mSharedPreferences.edit().putString(key, value).apply();
        }
    }

    public String getString(@NonNull final String key) {
        return getString(key, "");
    }

    public String getString(@NonNull final String key, final String defaultValue) {
        return mSharedPreferences.getString(key, defaultValue);
    }

}
