package com.tencent.qcloud.tim.demo.utils;

import android.os.Build;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.tencent.qcloud.tim.demo.DemoApplication;

public class BrandUtil {
    /**
     * 判断是否为小米设备
     */
    public static boolean isBrandXiaoMi() {
        return "xiaomi".equalsIgnoreCase(Build.BRAND)
                || "xiaomi".equalsIgnoreCase(Build.MANUFACTURER);
    }

    /**
     * 判断是否为华为设备
     */
    public static boolean isBrandHuawei() {
        return "huawei".equalsIgnoreCase(Build.BRAND)
                || "huawei".equalsIgnoreCase(Build.MANUFACTURER);
    }

    /**
     * 判断是否为魅族设备
     */
    public static boolean isBrandMeizu() {
        return "meizu".equalsIgnoreCase(Build.BRAND)
                || "meizu".equalsIgnoreCase(Build.MANUFACTURER)
                || "22c4185e".equalsIgnoreCase(Build.BRAND);
    }

    /**
     * 判断是否是oppo设备
     *
     * @return
     */
    public static boolean isBrandOppo() {
        return "oppo".equalsIgnoreCase(Build.BRAND)
                || "oppo".equalsIgnoreCase(Build.MANUFACTURER);
    }

    /**
     * 判断是否是vivo设备
     *
     * @return
     */
    public static boolean isBrandVivo() {
        return "vivo".equalsIgnoreCase(Build.BRAND)
                || "vivo".equalsIgnoreCase(Build.MANUFACTURER);
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
}
