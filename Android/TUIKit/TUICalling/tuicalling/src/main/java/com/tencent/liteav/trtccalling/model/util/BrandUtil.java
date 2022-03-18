package com.tencent.liteav.trtccalling.model.util;

import android.text.TextUtils;

import com.tencent.qcloud.tuicore.util.TUIBuild;

public class BrandUtil {

    private static String mBrand        = "";
    private static String mManufacturer = "";

    private static void init() {
        if (TextUtils.isEmpty(mBrand)) {
            mBrand = TUIBuild.getBrand();
        }
        if (TextUtils.isEmpty(mManufacturer)) {
            mManufacturer = TUIBuild.getManufacturer();
        }
    }

    /**
     * 判断是否为小米设备
     */
    public static boolean isBrandXiaoMi() {
        init();
        return "xiaomi".equalsIgnoreCase(mBrand)
                || "xiaomi".equalsIgnoreCase(mManufacturer);
    }

    /**
     * 判断是否为华为设备
     */
    public static boolean isBrandHuawei() {
        init();
        return "huawei".equalsIgnoreCase(mBrand)
                || "huawei".equalsIgnoreCase(mManufacturer);
    }

    /**
     * 判断是否为魅族设备
     */
    public static boolean isBrandMeizu() {
        init();
        return "meizu".equalsIgnoreCase(mBrand)
                || "meizu".equalsIgnoreCase(mManufacturer)
                || "22c4185e".equalsIgnoreCase(mBrand);
    }

    /**
     * 判断是否是 oppo 设备, 包含子品牌
     *
     * @return
     */
    public static boolean isBrandOppo() {
        init();
        return "oppo".equalsIgnoreCase(mBrand) ||
                "realme".equalsIgnoreCase(mBrand) ||
                "oneplus".equalsIgnoreCase(mBrand) ||
                "oppo".equalsIgnoreCase(mManufacturer) ||
                "realme".equalsIgnoreCase(mManufacturer) ||
                "oneplus".equalsIgnoreCase(mManufacturer);
    }

    /**
     * 判断是否是vivo设备
     *
     * @return
     */
    public static boolean isBrandVivo() {
        init();
        return "vivo".equalsIgnoreCase(mBrand)
                || "vivo".equalsIgnoreCase(mManufacturer);
    }
}
