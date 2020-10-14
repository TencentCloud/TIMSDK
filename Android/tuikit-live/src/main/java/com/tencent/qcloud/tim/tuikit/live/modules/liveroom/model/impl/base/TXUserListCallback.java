package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base;

import java.util.List;

public interface TXUserListCallback {
    void onCallback(int code, String msg, List<TXUserInfo> list);
}
