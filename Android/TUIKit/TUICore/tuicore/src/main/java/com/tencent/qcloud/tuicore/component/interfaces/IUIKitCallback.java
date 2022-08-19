package com.tencent.qcloud.tuicore.component.interfaces;

public abstract class IUIKitCallback<T> {

    public void onSuccess(T data) {};

    public void onError(String module, int errCode, String errMsg) {}

    public void onError(int errCode, String errMsg, T data) {}

    public void onProgress(Object data) {}

}
