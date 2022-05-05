package com.tencent.qcloud.tuicore.interfaces;

public interface TUICallback {
    void onSuccess();

    void onError(int errorCode, String errorMessage);

    static void onSuccess(TUICallback callback) {
        if (callback != null) {
            callback.onSuccess();
        }
    }

    static void onError(TUICallback callback, int errorCode, String errorMessage) {
        if (callback != null) {
            callback.onError(errorCode, errorMessage);
        }
    }
}
