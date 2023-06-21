package com.tencent.qcloud.tim.tuiofflinepush.utils;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.meizu.cloud.pushsdk.util.MzSystemUtils;
import com.tencent.qcloud.tim.tuiofflinepush.TUIOfflinePushConfig;

public class BrandUtil {
    public static int vendorId = 0;

    public static boolean isBrandXiaoMi() {
        return "xiaomi".equalsIgnoreCase(getBuildBrand()) || "xiaomi".equalsIgnoreCase(getBuildManufacturer());
    }

    public static boolean isBrandHuawei() {
        return "huawei".equalsIgnoreCase(getBuildBrand()) || "huawei".equalsIgnoreCase(getBuildManufacturer()) || "honor".equalsIgnoreCase(getBuildBrand());
    }

    public static boolean isBrandMeizu() {
        return "meizu".equalsIgnoreCase(getBuildBrand()) || "meizu".equalsIgnoreCase(getBuildManufacturer()) || "22c4185e".equalsIgnoreCase(getBuildBrand())
            || MzSystemUtils.isBrandMeizu(TUIOfflinePushConfig.getInstance().getContext());
    }

    public static boolean isBrandOppo() {
        return "oppo".equalsIgnoreCase(getBuildBrand()) || "realme".equalsIgnoreCase(getBuildBrand()) || "oneplus".equalsIgnoreCase(getBuildBrand())
            || "oppo".equalsIgnoreCase(getBuildManufacturer()) || "realme".equalsIgnoreCase(getBuildManufacturer())
            || "oneplus".equalsIgnoreCase(getBuildManufacturer());
    }

    public static boolean isBrandVivo() {
        return "vivo".equalsIgnoreCase(getBuildBrand()) || "vivo".equalsIgnoreCase(getBuildManufacturer());
    }

    public static boolean isBrandHonor() {
        return "honor".equalsIgnoreCase(getBuildBrand()) && "honor".equalsIgnoreCase(getBuildManufacturer());
    }

    public static boolean isGoogleServiceSupport() {
        GoogleApiAvailability googleApiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = googleApiAvailability.isGooglePlayServicesAvailable(TUIOfflinePushConfig.getInstance().getContext());
        return resultCode == ConnectionResult.SUCCESS;
    }

    public static int getInstanceType() {
        if (vendorId != 0) {
            return vendorId;
        }

        int vendorId = TUIOfflinePushConfig.BRAND_GOOLE_ELSE;
        if (isBrandXiaoMi()) {
            vendorId = TUIOfflinePushConfig.BRAND_XIAOMI;
        } else if (isBrandHonor()) {
            vendorId = TUIOfflinePushConfig.BRAND_HONOR;
        } else if (isBrandHuawei()) {
            vendorId = TUIOfflinePushConfig.BRAND_HUAWEI;
        } else if (isBrandMeizu()) {
            vendorId = TUIOfflinePushConfig.BRAND_MEIZU;
        } else if (isBrandOppo()) {
            vendorId = TUIOfflinePushConfig.BRAND_OPPO;
        } else if (isBrandVivo()) {
            vendorId = TUIOfflinePushConfig.BRAND_VIVO;
        }

        return vendorId;
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
