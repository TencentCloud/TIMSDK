package com.tencent.qcloud.uikit.common;


public interface IUIKitCallBack {

    void onSuccess(Object data);

    void onError(String module, int errCode, String errMsg);
}
