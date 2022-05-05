package com.tencent.qcloud.tim.demo.utils;

import com.tencent.qcloud.tuicore.util.TUIBuild;

public class BrandUtil {
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
        return "huawei".equalsIgnoreCase(getBuildBrand()) ||
                "huawei".equalsIgnoreCase(getBuildManufacturer()) ||
                "honor".equalsIgnoreCase(getBuildBrand()) ||
                "honor".equalsIgnoreCase(getBuildManufacturer());
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

    public static String getBuildBrand() {
        return TUIBuild.getBrand();
    }

    public static String getBuildManufacturer() {
        return TUIBuild.getManufacturer();
    }

    public static String getBuildModel() {
        return TUIBuild.getModel();
    }

    public static String getBuildVersionRelease() {
        return TUIBuild.getVersion();
    }

    public static int getBuildVersionSDKInt() {
        return TUIBuild.getVersionInt();
    }
}
