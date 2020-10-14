package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base;

public interface TXRoomFollowCallback {
    //关注成功
    void onSuccess();
    //关注失败
    void onFailed(String message);
}
