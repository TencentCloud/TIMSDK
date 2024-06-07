package com.tencent.qcloud.tim.demo.utils;

import android.text.TextUtils;
import com.tencent.qcloud.tuicore.util.TUIBuild;

public class BrandUtil {
    /**
     * Xiaomi device
     */
    public static boolean isBrandXiaoMi() {
        return "xiaomi".equalsIgnoreCase(getBuildBrand()) || "xiaomi".equalsIgnoreCase(getBuildManufacturer());
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
     * oppo device
     *
     * @return
     */
    public static boolean isSamsungS9Series() {
        return "samsung".equalsIgnoreCase(getBuildBrand())
            && (!TextUtils.isEmpty(getBuildModel()) && (getBuildModel().startsWith("SM-G965") || getBuildModel().startsWith("SM-G960")));
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
