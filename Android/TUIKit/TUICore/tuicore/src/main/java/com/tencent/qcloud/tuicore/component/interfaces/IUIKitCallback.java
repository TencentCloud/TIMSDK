package com.tencent.qcloud.tuicore.component.interfaces;

/**
 * UIKit回调的通用接口类
 */
public abstract class IUIKitCallback<T> {

    public void onSuccess(T data) {};

    public void onError(String module, int errCode, String errMsg) {}

    public void onError(int errCode, String errMsg, T data) {}

    public void onProgress(Object data) {}

}
