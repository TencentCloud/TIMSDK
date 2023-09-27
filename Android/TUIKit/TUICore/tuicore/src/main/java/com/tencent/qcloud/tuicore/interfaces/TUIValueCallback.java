package com.tencent.qcloud.tuicore.interfaces;

public abstract class TUIValueCallback<T> {
    public abstract void onSuccess(T object);

    public static <T> void onSuccess(TUIValueCallback<T> callback, T result) {
        if (callback != null) {
            callback.onSuccess(result);
        }
    }

    public abstract void onError(int errorCode, String errorMessage);

    public static <T> void onError(TUIValueCallback<T> callback, int errorCode, String errorMessage) {
        if (callback != null) {
            callback.onError(errorCode, errorMessage);
        }
    }

    public void onProgress(long current, long total) {}

    public static <T> void onProgress(TUIValueCallback<T> callback, long current, long total) {
        if (callback != null) {
            callback.onProgress(current, total);
        }
    }
}
