package com.tencent.qcloud.tim.demo.utils;

import com.tencent.qcloud.tuicore.util.TUIBuild;

public class BrandUtil {
    /**
     * Xiaomi device
     */
    public static boolean isBrandXiaoMi() {
        return "xiaomi".equalsIgnoreCase(getBuildBrand()) || "xiaomi".equalsIgnoreCase(getBuildManufacturer());
    }

    /**
     * huawei device
     */
    public static boolean isBrandHuawei() {
        return "huawei".equalsIgnoreCase(getBuildBrand()) || "huawei".equalsIgnoreCase(getBuildManufacturer()) || "honor".equalsIgnoreCase(getBuildBrand());
    }

    /**
     * meizu device
     */
    public static boolean isBrandMeizu() {
        return "meizu".equalsIgnoreCase(getBuildBrand()) || "meizu".equalsIgnoreCase(getBuildManufacturer()) || "22c4185e".equalsIgnoreCase(getBuildBrand());
    }

    /**
     * oppo device
     *
     * @return
     */
    public static boolean isBrandOppo() {
        return "oppo".equalsIgnoreCase(getBuildBrand()) || "realme".equalsIgnoreCase(getBuildBrand()) || "oneplus".equalsIgnoreCase(getBuildBrand())
            || "oppo".equalsIgnoreCase(getBuildManufacturer()) || "realme".equalsIgnoreCase(getBuildManufacturer())
            || "oneplus".equalsIgnoreCase(getBuildManufacturer());
    }

    /**
     * vivo device
     *
     * @return
     */
    public static boolean isBrandVivo() {
        return "vivo".equalsIgnoreCase(getBuildBrand()) || "vivo".equalsIgnoreCase(getBuildManufacturer());
    }

    /**
     * honor device
     *
     * @return
     */
    public static boolean isBrandHonor() {
        return "honor".equalsIgnoreCase(getBuildBrand()) && "honor".equalsIgnoreCase(getBuildManufacturer());
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
