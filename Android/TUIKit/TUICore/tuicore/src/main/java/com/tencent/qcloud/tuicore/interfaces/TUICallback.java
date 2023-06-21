package com.tencent.qcloud.tuicore.interfaces;

public abstract class TUICallback {
    public abstract void onSuccess();

    public static void onSuccess(TUICallback callback) {
        if (callback != null) {
            callback.onSuccess();
        }
    }

    public abstract void onError(int errorCode, String errorMessage);

    public static void onError(TUICallback callback, int errorCode, String errorMessage) {
        if (callback != null) {
            callback.onError(errorCode, errorMessage);
        }
    }
}
