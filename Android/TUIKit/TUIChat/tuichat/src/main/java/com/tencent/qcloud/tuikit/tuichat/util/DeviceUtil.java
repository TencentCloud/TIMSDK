package com.tencent.qcloud.tuikit.tuichat.util;

import android.util.DisplayMetrics;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.util.TUIBuild;

public class DeviceUtil {
    private static String[] huaweiAndHonorDevice = {
        "hwH60", 
        "hwPE", 
        "hwH30",
        "hwHol", 
        "hwG750",
        "hw7D",
        "hwChe2",
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
}
