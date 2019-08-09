package com.tencent.qcloud.tim.uikit.component.video.util;

import android.os.Build;

public class DeviceUtil {

    private static String[] huaweiRongyao = {
            "hwH60",    //荣耀6
            "hwPE",     //荣耀6 plus
            "hwH30",    //3c
            "hwHol",    //3c畅玩版
            "hwG750",   //3x
            "hw7D",      //x1
            "hwChe2",      //x1
    };

    public static String getDeviceInfo() {
        String handSetInfo =
                "手机型号：" + Build.DEVICE +
                        "\n系统版本：" + Build.VERSION.RELEASE +
                        "\nSDK版本：" + Build.VERSION.SDK_INT;
        return handSetInfo;
    }

    public static String getDeviceModel() {
        return Build.DEVICE;
    }

    public static boolean isHuaWeiRongyao() {
        int length = huaweiRongyao.length;
        for (int i = 0; i < length; i++) {
            if (huaweiRongyao[i].equals(getDeviceModel())) {
                return true;
            }
        }
        return false;
    }
}
