package com.tencent.qcloud.tuikit.tuichat.util;

import android.util.DisplayMetrics;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.util.TUIBuild;

public class DeviceUtil {
    private static String[] huaweiAndHonorDevice = {
        "hwH60", // 荣耀6
        "hwPE", // 荣耀6 plus
        "hwH30", // 3c
        "hwHol", // 3c畅玩版
        "hwG750", // 3x
        "hw7D", // x1
        "hwChe2", // x1
    };

    public static boolean isHuaWeiOrHonor() {
        String device = TUIBuild.getDevice();
        int length = huaweiAndHonorDevice.length;
        for (int i = 0; i < length; i++) {
            if (huaweiAndHonorDevice[i].equals(device)) {
                return true;
            }
        }
        return false;
    }

    public static boolean isVivoX21() {
        String model = TUIBuild.getModel();
        return "vivo X21".equalsIgnoreCase(model);
    }

    public static int[] getScreenSize() {
        int[] size = new int[2];
        DisplayMetrics dm = TUIConfig.getAppContext().getResources().getDisplayMetrics();
        size[0] = dm.widthPixels;
        size[1] = dm.heightPixels;
        return size;
    }
}
