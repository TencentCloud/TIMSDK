package com.tencent.liteav.trtccalling.model;

public class TRTCCallingCallback {
    /**
     * 通用回调
     */
    public interface ActionCallback {
        void onCallback(int code, String msg);
    }
}
