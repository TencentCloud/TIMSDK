package com.tencent.qcloud.tuicore.interfaces;

public abstract class TUILoginListener {
    /**
     * The SDK is connecting to the CVM instance
     */
    public void onConnecting() {}

    /**
     * The SDK is successfully connected to the CVM instance
     */
    public void onConnectSuccess() {}

    /**
     * The SDK failed to connect to the CVM instance
     */
    public void onConnectFailed(int code, String error) {}

    /**
     * The current user is kicked offline: the SDK notifies the user on the UI, and the user can choose to call the login() function of V2TIMManager to log in
     * again.
     */
    public void onKickedOffline() {}

    /**
     * The ticket expires when the user is online: the user needs to generate a new userSig and call the login() function of V2TIMManager to log in again.
     */
    public void onUserSigExpired() {
    }
}
