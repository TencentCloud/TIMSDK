package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.presenter;

import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer.RoomMsgData;

public abstract class RoomPresenter {

    public static RoomPresenter getInstance() {
        return RoomPresenterImpl.getInstance();
    }

    public abstract void createRoom();

    public abstract void enterRoom(RoomMsgData roomMsgData);

    public abstract void inviteOtherMembersToJoin(RoomMsgData roomMsgData);
}
