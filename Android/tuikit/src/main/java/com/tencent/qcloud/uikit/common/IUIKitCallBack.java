package com.tencent.qcloud.uikit.common;


/**
 * Created by valexhuang on 2018/8/17.
 */

public interface IUIKitCallBack {

    public void onSuccess(Object data);

    public void onError(String module, int errCode, String errMsg);
}
