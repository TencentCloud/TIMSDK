package com.tencent.qcloud.tim.demo.utils;

import android.os.Build;
import android.text.TextUtils;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.tencent.qcloud.tim.demo.DemoApplication;

public class BrandUtil {
    private static String buildBrand = "";
    private static String buildManufacturer = "";
    private static String buildModel = "";
    private static String buildVersionRelease = "";
    private static int buildVersionSDKInt = 0;

    /**
     * 判断是否为小米设备
     */
    public static boolean isBrandXiaoMi() {
        return "xiaomi".equalsIgnoreCase(getBuildBrand())
                || "xiaomi".equalsIgnoreCase(getBuildManufacturer());
    }

    /**
     * 判断是否为华为设备
     */
    public static boolean isBrandHuawei() {
        return "huawei".equalsIgnoreCase(getBuildBrand())
                || "huawei".equalsIgnoreCase(getBuildManufacturer());
    }

    /**
     * 判断是否为魅族设备
     */
    public static boolean isBrandMeizu() {
        return "meizu".equalsIgnoreCase(getBuildBrand())
                || "meizu".equalsIgnoreCase(getBuildManufacturer())
                || "22c4185e".equalsIgnoreCase(getBuildBrand());
    }

    /**
     * 判断是否是 oppo 设备, 包含子品牌
     *
     * @return
     */
    public static boolean isBrandOppo() {
        return "oppo".equalsIgnoreCase(getBuildBrand()) ||
                "realme".equalsIgnoreCase(getBuildBrand()) ||
                "oneplus".equalsIgnoreCase(getBuildBrand()) ||
                "oppo".equalsIgnoreCase(getBuildManufacturer()) ||
                "realme".equalsIgnoreCase(getBuildManufacturer()) ||
                "oneplus".equalsIgnoreCase(getBuildManufacturer());
    }

    /**
     * 判断是否是vivo设备
     *
     * @return
     */
    public static boolean isBrandVivo() {
        return "vivo".equalsIgnoreCase(getBuildBrand())
                || "vivo".equalsIgnoreCase(getBuildManufacturer());
    }

    /**
     * 判断是否支持谷歌服务
     *
     * @return
     */
    public static boolean isGoogleServiceSupport() {
        GoogleApiAvailability googleApiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = googleApiAvailability.isGooglePlayServicesAvailable(DemoApplication.instance());
        return resultCode == ConnectionResult.SUCCESS;
    }

    public static String getBuildBrand() {
        if (TextUtils.isEmpty(buildBrand)) {
            buildBrand = Build.BRAND;
        }

        return buildBrand;
    }

    public static String getBuildManufacturer() {
        if (TextUtils.isEmpty(buildManufacturer)) {
            buildManufacturer = Build.MANUFACTURER;
        }

        return buildManufacturer;
    }

    public static String getBuildModel() {
        if (TextUtils.isEmpty(buildModel)) {
            buildModel = Build.MODEL;
        }

        return buildModel;
    }

    public static String getBuildVersionRelease() {
        if (TextUtils.isEmpty(buildVersionRelease)) {
            buildVersionRelease = Build.VERSION.RELEASE;
        }

        return buildVersionRelease;
    }

    public static int getBuildVersionSDKInt() {
        if (buildVersionSDKInt == 0) {
            buildVersionSDKInt = Build.VERSION.SDK_INT;
        }

        return buildVersionSDKInt;
    }
}
