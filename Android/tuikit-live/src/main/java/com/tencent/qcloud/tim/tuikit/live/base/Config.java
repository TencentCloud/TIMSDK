package com.tencent.qcloud.tim.tuikit.live.base;

public class Config {
    private static boolean sEnablePKButton = true;  // 是否显示主播页底部栏PK按钮

    public static boolean getPKButtonStatus() {
        return sEnablePKButton;
    }

    public static void setPKButtonStatus(boolean enable) {
        sEnablePKButton = enable;
    }
}
