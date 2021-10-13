package com.tencent.qcloud.tim.uikit.live.modules.liveroom.model.impl.base;


import java.util.List;

public interface TXRoomInfoListCallback {
    void onCallback(int code, String msg, List<TXRoomInfo> list);
}
