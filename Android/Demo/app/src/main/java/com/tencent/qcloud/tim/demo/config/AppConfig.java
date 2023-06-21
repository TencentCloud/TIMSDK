package com.tencent.qcloud.tim.demo.config;

import com.tencent.qcloud.tim.demo.utils.Constants;

public class AppConfig {
    // 0,else; 1,imdemo
    public static int IS_IM_DEMO = 0;
    // app flavor
    public static String DEMO_FLAVOR_VERSION = Constants.FLAVOR_LOCAL;
    // app build version
    public static String DEMO_VERSION_NAME = "7.3.4358";
    // 0,classic; 1,minimalist
    public static int DEMO_UI_STYLE = 0;
    // long connection addr: china、india ...
    public static int DEMO_TEST_ENVIRONMENT = 0;
    // logined appid
    public static int DEMO_SDK_APPID = 0;
}
