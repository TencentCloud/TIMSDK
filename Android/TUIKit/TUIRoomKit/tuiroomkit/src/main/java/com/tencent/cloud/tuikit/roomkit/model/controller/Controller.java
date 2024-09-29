package com.tencent.cloud.tuikit.roomkit.model.controller;

import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.model.data.InvitationState;
import com.tencent.cloud.tuikit.roomkit.model.data.MediaState;
import com.tencent.cloud.tuikit.roomkit.model.data.RoomState;
import com.tencent.cloud.tuikit.roomkit.model.data.SeatState;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.cloud.tuikit.roomkit.model.data.ViewState;

public abstract class Controller {
    protected ConferenceState mConferenceState;
    protected ViewState       mViewState;
    protected SeatState       mSeatState;
    protected RoomState       mRoomState;
    protected UserState       mUserState;
    protected MediaState      mMediaState;
    protected InvitationState mInvitationState;

    protected TUIRoomEngine mRoomEngine;

    protected Controller(ConferenceState conferenceState, TUIRoomEngine engine) {
        mConferenceState = conferenceState;
        mViewState = conferenceState.viewState;
        mSeatState = conferenceState.seatState;
        mRoomState = conferenceState.roomState;
        mUserState = conferenceState.userState;
        mMediaState = conferenceState.mediaState;
        mInvitationState = conferenceState.invitationState;

        mRoomEngine = engine;
    }

    public abstract void destroy();
}
