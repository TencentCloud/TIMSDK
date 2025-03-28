package com.tencent.cloud.tuikit.roomkit.manager;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;

public class UserController extends Controller {

    public UserController(ConferenceState roomStore, TUIRoomEngine engine) {
        super(roomStore, engine);
    }

    public boolean isSelf(String userId) {
        return TextUtils.equals(userId, mUserState.selfInfo.get().userId);
    }

    @Override
    public void destroy() {

    }
}
