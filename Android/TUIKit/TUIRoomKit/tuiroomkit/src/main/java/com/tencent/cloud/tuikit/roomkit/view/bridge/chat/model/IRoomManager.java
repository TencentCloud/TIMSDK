package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer.RoomMsgData;

public interface IRoomManager {
    void enableAutoShowRoomMainUi(boolean enable);

    void createRoom(String roomId, boolean isOpenMic, boolean isOpenCamera, boolean isUseSpeaker);

    void enterRoom(String roomId, boolean isOpenMic, boolean isOpenCamera, boolean isUseSpeaker);

    void exitRoom();

    void destroyRoom();

    void changeUserRole(String userId, TUIRoomDefine.Role role, TUIRoomDefine.ActionCallback callback);

    void inviteOtherMembersToJoin(RoomMsgData roomMsgData, TUIRoomDefine.LoginUserInfo inviteUser);
}
