package com.tencent.qcloud.tim.tuikit.live.base;

public interface ITUILiveCallBack {
    void onSuccess(Object data);

    void onError(String module, int errCode, String errMsg);
}
