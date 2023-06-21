package com.tencent.cloud.tuikit.roomkit.imaccess.model;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit.RoomScene;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.observer.RoomMsgData;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;

public interface IRoomManager {
    void raiseUi();

    void createRoom(RoomInfo roomInfo, RoomScene scene);

    void enterRoom(RoomInfo roomInfo);

    void exitRoom();

    void destroyRoom();

    void changeUserRole(String userId, TUIRoomDefine.Role role, TUIRoomDefine.ActionCallback callback);

    void inviteOtherMembersToJoin(RoomMsgData roomMsgData, TUIRoomDefine.LoginUserInfo inviteUser);
}
