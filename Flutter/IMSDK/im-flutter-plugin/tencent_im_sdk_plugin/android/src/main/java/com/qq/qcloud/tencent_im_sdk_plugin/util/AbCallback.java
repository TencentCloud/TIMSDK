package com.qq.qcloud.tencent_im_sdk_plugin.util;

public abstract class AbCallback {
    public AbCallback(){};
    public void onAbSuccess(){};
    public void onAbError(int code,String desc){};
}
