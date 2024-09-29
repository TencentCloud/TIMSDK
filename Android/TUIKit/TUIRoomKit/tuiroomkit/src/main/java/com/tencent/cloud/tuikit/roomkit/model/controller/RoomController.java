package com.tencent.cloud.tuikit.roomkit.model.controller;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceState;

public class RoomController extends Controller {

    public RoomController(ConferenceState roomStore, TUIRoomEngine engine) {
        super(roomStore, engine);
    }

    public boolean isInRoom() {
        return !TextUtils.isEmpty(mRoomState.roomId.get());
    }

    @Override
    public void destroy() {
    }
}
