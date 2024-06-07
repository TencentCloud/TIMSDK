package com.tencent.cloud.tuikit.roomkit.common.utils;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.tuicore.util.TUIBuild;

public class BrandUtils {
    private static final String TAG = "BrandUtils";

    private static String mBrand        = "";
    private static String mManufacturer = "";
    private static String mModel        = "";
    private static String mOsVersion    = "";

    private static void init() {
        getBrand();
        getManufacturer();
        getModel();
        getOsVersion();
    }

    private static void getBrand() {
        if (TextUtils.isEmpty(mBrand)) {
            synchronized (BrandUtils.class) {
                if (TextUtils.isEmpty(mBrand)) {
                    mBrand = TUIBuild.getBrand();
                    Log.i(TAG, "get BRAND by Build.BRAND :" + mBrand);
                }
            }
        }
    }

    private static void getManufacturer() {
        if (TextUtils.isEmpty(mManufacturer)) {
            synchronized (BrandUtils.class) {
                if (TextUtils.isEmpty(mManufacturer)) {
                    mManufacturer = TUIBuild.getManufacturer();
                    Log.i(TAG, "get MANUFACTURER by Build.MANUFACTURER :" + mManufacturer);
                }
            }
        }
    }

    public static String getModel() {
        if (TextUtils.isEmpty(mModel)) {
            synchronized (BrandUtils.class) {
                if (TextUtils.isEmpty(mModel)) {
                    mModel = TUIBuild.getModel();
                    Log.i(TAG, "get MODEL by Build.MODEL :" + mModel);
                }
            }
        }
        return mModel;
    }

    public static String getOsVersion() {
        if (TextUtils.isEmpty(mOsVersion)) {
            synchronized (BrandUtils.class) {
                if (TextUtils.isEmpty(mOsVersion)) {
                    mOsVersion = String.valueOf(TUIBuild.getVersionInt());
                    Log.i(TAG, "get OS version by Build.VERSION :" + mOsVersion);
                }
            }
        }
        return mOsVersion;
    }

    public static boolean isBrandXiaoMi() {
        init();
        return "xiaomi".equalsIgnoreCase(mBrand)
                || "xiaomi".equalsIgnoreCase(mManufacturer);
    }

    public static boolean isBrandHuawei() {
        init();
        return "huawei".equalsIgnoreCase(mBrand)
                || "huawei".equalsIgnoreCase(mManufacturer);
    }

    public static boolean isBrandMeizu() {
        init();
        return "meizu".equalsIgnoreCase(mBrand)
                || "meizu".equalsIgnoreCase(mManufacturer)
                || "22c4185e".equalsIgnoreCase(mBrand);
    }

    public static boolean isBrandOppo() {
        init();
        return "oppo".equalsIgnoreCase(mBrand)
                || "realme".equalsIgnoreCase(mBrand)
                || "oneplus".equalsIgnoreCase(mBrand)
                || "oppo".equalsIgnoreCase(mManufacturer)
                || "realme".equalsIgnoreCase(mManufacturer)
                || "oneplus".equalsIgnoreCase(mManufacturer);
    }

    public static boolean isBrandVivo() {
        init();
        return "vivo".equalsIgnoreCase(mBrand)
                || "vivo".equalsIgnoreCase(mManufacturer);
    }
}
