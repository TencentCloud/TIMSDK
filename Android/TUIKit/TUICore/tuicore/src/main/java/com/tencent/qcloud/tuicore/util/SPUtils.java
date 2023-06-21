package com.tencent.qcloud.tuicore.util;

import android.content.Context;
import android.content.SharedPreferences;
import androidx.annotation.NonNull;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import java.util.HashMap;
import java.util.Map;

public class SPUtils {
    public static final String DEFAULT_DATABASE = "tuikit";
    private static final Map<String, SPUtils> SP_UTILS_MAP = new HashMap<>();

    private final SharedPreferences mSharedPreferences;

    public static SPUtils getInstance() {
        return getInstance(DEFAULT_DATABASE, Context.MODE_PRIVATE);
    }

    public static SPUtils getInstance(final int mode) {
        return getInstance(DEFAULT_DATABASE, mode);
    }

    public static SPUtils getInstance(String spName) {
        return getInstance(spName, Context.MODE_PRIVATE);
    }

    public static SPUtils getInstance(String spName, final int mode) {
        if (isSpace(spName)) {
            spName = DEFAULT_DATABASE;
        }
        SPUtils spUtils = SP_UTILS_MAP.get(spName);
        if (spUtils == null) {
            synchronized (SPUtils.class) {
                spUtils = SP_UTILS_MAP.get(spName);
                if (spUtils == null) {
                    spUtils = new SPUtils(spName, mode);
                    SP_UTILS_MAP.put(spName, spUtils);
                }
            }
        }
        return spUtils;
    }

    private SPUtils(final String spName, final int mode) {
        mSharedPreferences = getApplicationContext().getSharedPreferences(spName, mode);
    }

    private Context getApplicationContext() {
        return ServiceInitializer.getAppContext();
    }

    public String getString(@NonNull final String key) {
        return getString(key, "");
    }

    public String getString(@NonNull final String key, final String defaultValue) {
        return mSharedPreferences.getString(key, defaultValue);
    }

    // String
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

    // boolean
    public void put(@NonNull final String key, final boolean value) {
        put(key, value, false);
    }

    public void put(@NonNull final String key, final boolean value, final boolean isCommit) {
        if (isCommit) {
            mSharedPreferences.edit().putBoolean(key, value).commit();
        } else {
            mSharedPreferences.edit().putBoolean(key, value).apply();
        }
    }

    // int
    public void put(@NonNull final String key, final int value) {
        put(key, value, false);
    }

    public void put(@NonNull final String key, final int value, final boolean isCommit) {
        if (isCommit) {
            mSharedPreferences.edit().putInt(key, value).commit();
        } else {
            mSharedPreferences.edit().putInt(key, value).apply();
        }
    }

    // float
    public void put(@NonNull final String key, final float value) {
        put(key, value, false);
    }

    public void put(@NonNull final String key, final float value, final boolean isCommit) {
        if (isCommit) {
            mSharedPreferences.edit().putFloat(key, value).commit();
        } else {
            mSharedPreferences.edit().putFloat(key, value).apply();
        }
    }

    // long
    public void put(@NonNull final String key, final long value) {
        put(key, value, false);
    }

    public void put(@NonNull final String key, final long value, final boolean isCommit) {
        if (isCommit) {
            mSharedPreferences.edit().putLong(key, value).commit();
        } else {
            mSharedPreferences.edit().putLong(key, value).apply();
        }
    }

    public boolean getBoolean(@NonNull final String key) {
        return getBoolean(key, false);
    }

    public boolean getBoolean(@NonNull final String key, final boolean defaultValue) {
        return mSharedPreferences.getBoolean(key, defaultValue);
    }

    public int getInt(@NonNull final String key) {
        return getInt(key, -1);
    }

    public int getInt(@NonNull final String key, final int defaultValue) {
        return mSharedPreferences.getInt(key, defaultValue);
    }

    public float getFloat(@NonNull final String key) {
        return getFloat(key, -1f);
    }

    public float getFloat(@NonNull final String key, final float defaultValue) {
        return mSharedPreferences.getFloat(key, defaultValue);
    }

    public long getLong(@NonNull final String key) {
        return getLong(key, -1L);
    }

    public long getLong(@NonNull final String key, final long defaultValue) {
        return mSharedPreferences.getLong(key, defaultValue);
    }

    public boolean contains(@NonNull final String key) {
        return mSharedPreferences.contains(key);
    }

    public void remove(@NonNull final String key) {
        remove(key, false);
    }

    public void remove(@NonNull final String key, final boolean isCommit) {
        if (isCommit) {
            mSharedPreferences.edit().remove(key).commit();
        } else {
            mSharedPreferences.edit().remove(key).apply();
        }
    }

    public void clear() {
        clear(false);
    }

    public void clear(final boolean isCommit) {
        if (isCommit) {
            mSharedPreferences.edit().clear().commit();
        } else {
            mSharedPreferences.edit().clear().apply();
        }
    }

    private static boolean isSpace(final String s) {
        if (s == null) {
            return true;
        }
        for (int i = 0, len = s.length(); i < len; ++i) {
            if (!Character.isWhitespace(s.charAt(i))) {
                return false;
            }
        }
        return true;
    }
}