package com.tencent.liteav.trtccalling.model.impl;

/**
 * 结果回调
 */
public interface TRTCCallingCallback {

    //用于返回IM 设置头像和昵称的结果
    void onCallback(int code, String msg);
}
