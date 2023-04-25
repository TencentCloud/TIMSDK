package com.tencent.qcloud.tuicore.interfaces;

public abstract class TUIValueCallback<T> {
    public abstract void onSuccess(T object);

    public abstract void onError(int errorCode, String errorMessage);

    public static <T> void onSuccess(TUIValueCallback<T> callback, T result) {
        if (callback != null) {
            callback.onSuccess(result);
        }
    }

    public static <T> void onError(TUIValueCallback<T> callback, int errorCode, String errorMessage) {
        if (callback != null) {
            callback.onError(errorCode, errorMessage);
        }
    }
}
