package com.tencent.qcloud.tuikit.timcommon.component.interfaces;

public abstract class IUIKitCallback<T> {
    public void onSuccess(T data){}

    public void onError(String module, int errCode, String errMsg) {}

    public void onError(int errCode, String errMsg, T data) {}

    public void onProgress(Object data) {}

    public static <O> void callbackOnSuccess(IUIKitCallback<O> callback, O data) {
        if (callback != null) {
            callback.onSuccess(data);
        }
    }

    public static <O> void callbackOnError(IUIKitCallback<O> callback, int errCode, String errMsg, O data) {
        if (callback != null) {
            callback.onError(errCode, errMsg, data);
        }
    }
}
