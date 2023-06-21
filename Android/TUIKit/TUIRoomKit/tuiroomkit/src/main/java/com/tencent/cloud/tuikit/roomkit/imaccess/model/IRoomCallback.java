package com.tencent.cloud.tuikit.roomkit.imaccess.model;

import com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.RoomResult;

public interface IRoomCallback {
    void onLoginSuccess();

    void onCreateRoom(String roomId, RoomResult result);

    void onEnterRoom(String roomId, RoomResult result);

    void onExitRoom(String roomId);

    void onDestroyRoom(String roomId);

    void onFetchUserListComplete(String roomId);
}
