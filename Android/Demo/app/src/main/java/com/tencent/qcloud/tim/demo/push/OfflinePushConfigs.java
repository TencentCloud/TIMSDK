package com.tencent.qcloud.tim.demo.push;

public class OfflinePushConfigs {
    private static OfflinePushConfigs offlinePushConfigs;

    public static final int REGISTER_PUSH_MODE_AUTO = 0;
    public static final int REGISTER_PUSH_MODE_API = 1;

    public static final int CLICK_NOTIFICATION_CALLBACK_INTENT = 0;
    public static final int CLICK_NOTIFICATION_CALLBACK_NOTIFY = 1;
    public static final int CLICK_NOTIFICATION_CALLBACK_BROADCAST = 2;

    private int registerPushMode = 0;
    private int clickNotificationCallbackMode = 0;

    public static OfflinePushConfigs getOfflinePushConfigs() {
        if (offlinePushConfigs == null) {
            offlinePushConfigs = new OfflinePushConfigs();
        }
        return offlinePushConfigs;
    }

    /*
     * Demo 集成了两种推送注册方式，获取应用正在使用的推送服务注册方式：
     *
     * REGISTER_PUSH_MODE_AUTO，组件自动监听账号登录成功后，注册推送服务，需要手动配置推送参数到推送组件的 PrivateConstants 里；
     * REGISTER_PUSH_MODE_API，手动注册离线推送服务, IM 账号登录成功时调用，推送参数见接口说明;
     *
     *
     * Demo integrates two push registration methods to obtain the push service registration method that the application is using:
     *
     * REGISTER_PUSH_MODE_AUTO，After the component monitors the account login successfully, to register the push service automatically, you need to manually
     * configure the push parameters to the PrivateConstants of the push component； REGISTER_PUSH_MODE_API，Manual registration of offline push service, called
     * when the IM account is successfully logged in, see the interface description for push parameters;
     */
    public int getRegisterPushMode() {
        return registerPushMode;
    }

    public void setRegisterPushMode(int registerPushMode) {
        this.registerPushMode = registerPushMode;
    }

    /*
     * Demo 集成了三种点击通知栏跳转界面方式，获取应用正在使用的跳转方式：
     *
     * CLICK_NOTIFICATION_CALLBACK_INTENT，按照规范在 IM 控制台配置跳转参数，点击通知栏跳转到配置界面，解析透传参数并进行界面重定向；
     * CLICK_NOTIFICATION_CALLBACK_NOTIFY，IM 控制台配置跳转参数选择 "使用推送组件回调跳转"，点击通知栏事件注册回调接收即可；
     * CLICK_NOTIFICATION_CALLBACK_BROADCAST，IM 控制台配置跳转参数选择 "使用推送组件回调跳转"，点击通知栏事件注册接收广播即可；
     *
     *
     * Demo integrates three ways to click the notification bar to jump to the interface to get the jumping method the application is using:
     *
     * CLICK_NOTIFICATION_CALLBACK_INTENT，Configure the jump parameters in the IM console according to the specifications, click the notification bar to jump
     * to the configuration interface, parse the transparent transmission parameters and perform interface redirection; CLICK_NOTIFICATION_CALLBACK_NOTIFY，In
     * the IM console configuration jump parameter, select "Use push component callback to jump", and click the notification bar event registration callback to
     * receive; CLICK_NOTIFICATION_CALLBACK_BROADCAST，In the IM console configuration jump parameter, select "Use push component callback to jump", and click
     * the notification bar event to register to receive the broadcast;
     */
    public int getClickNotificationCallbackMode() {
        return clickNotificationCallbackMode;
    }

    public void setClickNotificationCallbackMode(int clickNotificationCallbackMode) {
        this.clickNotificationCallbackMode = clickNotificationCallbackMode;
    }
}
