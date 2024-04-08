package com.tencent.qcloud.tim.demo.config;

import com.tencent.qcloud.tim.demo.utils.Constants;

public class AppConfig {
    public static final int DEMO_UI_STYLE_CLASSIC = 0;
    public static final int DEMO_UI_STYLE_MINIMALIST = 1;

    // app flavor
    public static String DEMO_FLAVOR_VERSION = Constants.FLAVOR_LOCAL;

    public static int DEMO_UI_STYLE = DEMO_UI_STYLE_CLASSIC;
    // long connection addr: china、india ...
    public static int DEMO_TEST_ENVIRONMENT = 0;
    // logined appid
    public static int DEMO_SDK_APPID = 0;
}
