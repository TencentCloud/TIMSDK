package com.tencent.qcloud.tim.tuiofflinepush;

public class PrivateConstants {

    /****** 华为离线推送参数start ******/
    // 在腾讯云控制台上传第三方推送证书后分配的证书ID
    public static final long HW_PUSH_BUZID = 0;
    // 海外证书 ID，不需要直接删掉
    public static final long HW_PUSH_BUZID_ABROAD = 0;
    // 角标参数，默认为应用的 launcher 界面的类名
    public static final String BADGE_CLASS_NAME = "com.tencent.qcloud.tim.demo.SplashActivity";
    /****** 华为离线推送参数end ******/

    /****** 小米离线推送参数start ******/
    // 在腾讯云控制台上传第三方推送证书后分配的证书ID
    public static final long XM_PUSH_BUZID = 0;
    // 海外证书 ID，不需要直接删掉
    public static final long XM_PUSH_BUZID_ABROAD = 0;
    // 小米开放平台分配的应用APPID及APPKEY
    public static final String XM_PUSH_APPID = "";
    public static final String XM_PUSH_APPKEY = "";
    /****** 小米离线推送参数end ******/

    /****** 魅族离线推送参数start ******/
    // 在腾讯云控制台上传第三方推送证书后分配的证书ID
    public static final long MZ_PUSH_BUZID = 0;
    // 海外证书 ID，不需要直接删掉
    public static final long MZ_PUSH_BUZID_ABROAD = 0;
    // 魅族开放平台分配的应用APPID及APPKEY
    public static final String MZ_PUSH_APPID = "";
    public static final String MZ_PUSH_APPKEY = "";
    /****** 魅族离线推送参数end ******/

    /****** vivo离线推送参数start ******/
    // 在腾讯云控制台上传第三方推送证书后分配的证书ID
    public static final long VIVO_PUSH_BUZID = 0;
    // 海外证书 ID，不需要直接删掉
    public static final long VIVO_PUSH_BUZID_ABROAD = 0;
    /****** vivo离线推送参数end ******/

    /****** google离线推送参数start ******/
    // 在腾讯云控制台上传第三方推送证书后分配的证书ID
    public static final long GOOGLE_FCM_PUSH_BUZID = 0;
    // 海外证书 ID，不需要直接删掉
    public static final long GOOGLE_FCM_PUSH_BUZID_ABROAD = 0;
    /****** google离线推送参数end ******/

    /****** oppo离线推送参数start ******/
    // 在腾讯云控制台上传第三方推送证书后分配的证书ID
    public static final long OPPO_PUSH_BUZID = 0;
    // 海外证书 ID，不需要直接删掉
    public static final long OPPO_PUSH_BUZID_ABROAD = 0;
    // oppo开放平台分配的应用APPID及APPKEY
    public static final String OPPO_PUSH_APPKEY = "";
    public static final String OPPO_PUSH_APPSECRET = "";
    /****** oppo离线推送参数end ******/

    /**
     *  是否选择 TPNS 方案接入，默认为 IM 厂商通道，不需要修改配置
     *
     *  @note 组件实现了厂商和 TPNS 两种方式，以此变量作为接入方案区分
     *
     *  - 当接入推送方案选择 TPNS 通道，设置 isTPNSChannel 为 true，推送由 TPNS 提供服务；
     *  - 当接入推送方案选择 IM 厂商通道，设置 isTPNSChannel 为 false，走厂商推送逻辑；
     */
    public static final boolean isTPNSChannel = false;
}
