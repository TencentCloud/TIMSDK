package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base;

public interface TXRoomFollowStateCallback {
    //已经关注了该主播
    void isFollowed();
    //没有关注该主播
    void isNotFollowed();
    //查询关注状态失败
    void onFailed(String errorMessage);
}
