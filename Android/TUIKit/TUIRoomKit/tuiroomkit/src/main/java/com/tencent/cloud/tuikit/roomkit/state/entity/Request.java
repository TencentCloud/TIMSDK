package com.tencent.cloud.tuikit.roomkit.state.entity;

import android.os.SystemClock;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;

public class Request {
    public String requestId;
    public String userId;
    public String userName;
    public String avatarUrl;
    public long   timestamp;

    public Request(TUIRoomDefine.Request request) {
        this.requestId = request.requestId;
        this.userName = TextUtils.isEmpty(request.nameCard) ? request.userName : request.nameCard;
        this.avatarUrl = request.avatarUrl;
        this.userId = request.userId;
        this.timestamp = SystemClock.elapsedRealtime();
    }
}
