package com.tencent.qcloud.tuicore.component.interfaces;

/**
 * UIKit回调的通用接口类
 */
public abstract class IUIKitCallback<T> {

    public abstract void onSuccess(T data);

    public abstract void onError(String module, int errCode, String errMsg);

    public void onProgress(Object data) {};
}
