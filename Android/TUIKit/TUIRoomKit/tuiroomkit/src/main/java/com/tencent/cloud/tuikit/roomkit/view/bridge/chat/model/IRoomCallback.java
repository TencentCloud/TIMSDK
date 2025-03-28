package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model;

import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.RoomResult;

public interface IRoomCallback {
    void onCreateRoom(String roomId, RoomResult result);

    void onEnterRoom(String roomId, RoomResult result);

    void onExitRoom(String roomId);

    void onDestroyRoom(String roomId);

    void onFetchUserListComplete(String roomId);
}
