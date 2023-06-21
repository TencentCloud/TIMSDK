package com.tencent.cloud.tuikit.roomkit.imaccess.presenter;

import com.tencent.cloud.tuikit.roomkit.imaccess.model.observer.RoomMsgData;

public abstract class RoomPresenter {

    public static RoomPresenter getInstance() {
        return RoomPresenterImpl.getInstance();
    }

    public abstract void createRoom();

    public abstract void enterRoom(RoomMsgData roomMsgData);

    public abstract void inviteOtherMembersToJoin(RoomMsgData roomMsgData);
}
