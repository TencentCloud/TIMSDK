package com.tencent.qcloud.uipojo.utils;

/**
 * Created by Administrator on 2018/7/2.
 */

public class Constants {

    public static final int SDKAPPID = 1400178783; // 替换成您在腾讯云控制台云通信的应用SDKAPPID，链接 https://console.cloud.tencent.com/avc
    public static final String DEFAULT_USER = "wwww";
    public static final String DEFAULT_SIG = "eJxlj11PgzAYhe-5FaS3M1oKjGHihWWGNYhzGfPjirDRzXcbBUsHm8b-LuISm3hun*fk5Hwapmmi5H5*ma1W5UGoVJ0qjsxrE2F08QerCvI0U6kt83*QHyuQPM3WisseWq7rEox1B3IuFKzhbLRdNFrnu7Sf*K07Xdch-ojoCmx6GN8tAjYL-Kn9tj14QULL29FVGH1Qa7l-fm9kEjVFNIenVnitOsX5eMY2D0CTOp5MlsphKhxuacQCf18-vgyOxUDScSCKEMdMvS52N9qkgoKf-1hD4vkWcTXacFlDKXqB4E4hNv4JMr6Mb*XyXRg_";

    public static final String DEFUALT_PEER = "poiuy";

    // 获取usersig的业务服务器基本URL
    public static final String BUSIZ_SERVER_BASE_URL = "您自己换取userSig的业务服务器地址";

    // 根据各个厂商的文档，集成离线推送，华为和魅族的sdk是在app的build.gradle中集成，小米和 vivo 是用jar包方式集成。注意：华为还要在project的build.gradle中集成他们的maven仓库；com.huawei 文件夹下的代码是根据华为推送平台集成文档，用华为提供的工具自动生成的
    // thirdpush 包下的 receiver 是各厂商的接收器。
    // ThirdPushTokenMgr 用来保存厂商注册离线推送token的管理类示例，当登陆im后，通过 setOfflinePushToken 上报证书 ID 及设备 token 给im后台。开发者可以根据自己的需求灵活实现
    // 各个厂商都建议在 application 初始化推送，小米和魅族初始化后可以在对应的 receiver 中拿到 token；华为和 vivo 需要再主动调用下获取接口，比如 Demo 是在 loginActivity 的 onCreate 中获取的。

    /****** 华为离线推送参数start ******/
    // 在腾讯云控制台上传第三方推送证书后分配的证书ID
    public static final long HW_PUSH_BUZID = 5557;
    // 华为开发者联盟给应用分配的应用APPID
    public static final String HW_PUSH_APPID = "100642285"; // 见清单文件
    /****** 华为离线推送参数end ******/

    /****** 小米离线推送参数start ******/
    // 在腾讯云控制台上传第三方推送证书后分配的证书ID
    public static final long XM_PUSH_BUZID = 5556;
    // 小米开放平台分配的应用APPID及APPKEY
    public static final String XM_PUSH_APPID = "2882303761517953663";
    public static final String XM_PUSH_APPKEY = "5421795368663";
    /****** 小米离线推送参数end ******/

    /****** 魅族离线推送参数start ******/
    public static final long MZ_PUSH_BUZID = 5558;
    // 魅族开放平台分配的应用APPID及APPKEY
    public static final String MZ_PUSH_APPID = "118863";
    public static final String MZ_PUSH_APPKEY = "d9c7628144e541c1a6446983531467c8";
    /****** 魅族离线推送参数end ******/

    /****** vivo离线推送参数start ******/
    public static final long VIVO_PUSH_BUZID = 5559;
    // vivo开放平台分配的应用APPID及APPKEY
    public static final String VIVO_PUSH_APPID = "11178"; // 见清单文件
    public static final String VIVO_PUSH_APPKEY = "a90685ff-ebad-4df3-a265-3d4bb8e3a389"; // 见清单文件
    /****** vivo离线推送参数end ******/

    /****** oppo ******/
    // oppo的离线推送也是支持的，但是oppo要求app要发布到应用市场才能集成他们的离线推送，由于此Demo还没有发布，暂时没集成oppo
    /****** oppo离线推送参数start ******/

    // 存储
    public static final String USERINFO = "userInfo";
    public static final String ACCOUNT = "account";
    public static final String PWD = "password";
    public static final String ROOM = "room";
    public static final String AUTO_LOGIN = "auto_login";


    public static final String IS_GROUP = "IS_GROUP";


    public static final String INTENT_DATA = "INTENT_DATA";

}
