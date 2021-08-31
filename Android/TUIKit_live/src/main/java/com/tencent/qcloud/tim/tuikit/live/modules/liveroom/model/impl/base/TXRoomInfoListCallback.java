package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base;


import java.util.List;

public interface TXRoomInfoListCallback {
    void onCallback(int code, String msg, List<TXRoomInfo> list);
}
