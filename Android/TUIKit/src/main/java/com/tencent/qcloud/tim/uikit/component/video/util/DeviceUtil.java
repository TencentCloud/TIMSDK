package com.tencent.qcloud.tim.uikit.component.video.util;

import android.os.Build;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;

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
                TUIKit.getAppContext().getString(R.string.device_info) + Build.DEVICE +
                        TUIKit.getAppContext().getString(R.string.system_version) + Build.VERSION.RELEASE +
                        TUIKit.getAppContext().getString(R.string.sdk_version) + Build.VERSION.SDK_INT;
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

    public static boolean isVivoX21() {
        return "vivo X21".equalsIgnoreCase(Build.MODEL);
    }
}
