package com.tencent.cloud.tuikit.roomkit.state.entity;

import android.os.SystemClock;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;

public class TakeSeatRequestEntity {
    public final long receiveTimeMS = SystemClock.elapsedRealtime();

    private String userId;
    private String userName;
    private String avatarUrl;

    private TUIRoomDefine.Request request;

    private boolean isChecked = false;

    public TakeSeatRequestEntity(String userId, String userName, String avatarUrl, TUIRoomDefine.Request request) {
        this.userId = userId;
        this.userName = userName;
        this.avatarUrl = avatarUrl;
        this.request = request;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public TUIRoomDefine.Request getRequest() {
        return request;
    }

    public void setRequest(TUIRoomDefine.Request request) {
        this.request = request;
    }

    public boolean isChecked() {
        return isChecked;
    }

    public void setChecked(boolean checked) {
        isChecked = checked;
    }
}
