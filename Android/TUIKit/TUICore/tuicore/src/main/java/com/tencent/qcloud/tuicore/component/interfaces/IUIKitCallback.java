package com.tencent.qcloud.tuicore.component.interfaces;

/**
 * UIKit回调的通用接口类
 */
public interface IUIKitCallback<T> {

    void onSuccess(T data);

    void onError(String module, int errCode, String errMsg);
}
