package com.tencent.cloud.tuikit.roomkit.model.controller;

import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceState;

public class UserController extends Controller {

    public UserController(ConferenceState roomStore, TUIRoomEngine engine) {
        super(roomStore, engine);
    }

    @Override
    public void destroy() {

    }
}
