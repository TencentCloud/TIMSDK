package com.tencent.qcloud.tuicore.interfaces;

public abstract class TUILoginListener {
    /**
     * SDK 正在连接到腾讯云服务器
     *
     * The SDK is connecting to the CVM instance
     */
    public void onConnecting() {}

    /**
     * SDK 已经成功连接到腾讯云服务器
     *
     * The SDK is successfully connected to the CVM instance
     */
    public void onConnectSuccess() {}

    /**
     * SDK 连接腾讯云服务器失败
     *
     * The SDK failed to connect to the CVM instance
     */
    public void onConnectFailed(int code, String error) {}

    /**
     * 当前用户被踢下线，此时可以 UI 提示用户，并再次调用 TUILogin 的 login() 函数重新登录。
     *
     * The current user is kicked offline: the SDK notifies the user on the UI, and the user can choose to call the login() function of V2TIMManager to log in
     * again.
     */
    public void onKickedOffline() {}

    /**
     * 在线时票据过期：此时您需要生成新的 userSig 并再次调用 TUILogin 的 login() 函数重新登录。
     *
     * The ticket expires when the user is online: the user needs to generate a new userSig and call the login() function of V2TIMManager to log in again.
     */
    public void onUserSigExpired() {
    }
}
