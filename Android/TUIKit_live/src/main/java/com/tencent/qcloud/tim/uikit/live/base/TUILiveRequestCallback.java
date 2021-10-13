package com.tencent.qcloud.tim.uikit.live.base;

public interface TUILiveRequestCallback<T> {

    void onError(int code, String desc);

    void onSuccess(T t);
}