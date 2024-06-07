package com.tencent.cloud.tuikit.roomkit.model.entity;

import android.os.SystemClock;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;

public class Request {
    public String requestId;
    public String userId;
    public String userName;
    public String avatarUrl;
    public long   timestamp;

    public Request(TUIRoomDefine.Request request) {
        this.requestId = request.requestId;
        this.userName = request.userName;
        this.avatarUrl = request.avatarUrl;
        this.userId = request.userId;
        this.timestamp = SystemClock.elapsedRealtime();
    }
}
