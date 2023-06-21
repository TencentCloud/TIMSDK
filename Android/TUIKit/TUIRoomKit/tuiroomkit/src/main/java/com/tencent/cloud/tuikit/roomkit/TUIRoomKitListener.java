package com.tencent.cloud.tuikit.roomkit;

public interface TUIRoomKitListener {
    void onLogin(int code, String message);

    void onRoomCreate(int code, String message);

    void onRoomEnter(int code, String message);

    void onDestroyRoom();

    void onExitRoom();
}
