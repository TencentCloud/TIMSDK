package com.tencent.cloud.tuikit.roomkit.view;

import com.tencent.cloud.tuikit.roomkit.manager.ViewController;
import com.tencent.cloud.tuikit.roomkit.state.InvitationState;
import com.tencent.cloud.tuikit.roomkit.state.RoomState;
import com.tencent.cloud.tuikit.roomkit.state.SeatState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.state.ViewState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;

public class StateHolder {
    protected ViewState       mViewState;
    protected SeatState       mSeatState;
    protected RoomState       mRoomState;
    protected UserState       mUserState;
    protected InvitationState mInvitationState;

    protected ViewController mViewController;

    public StateHolder() {
        ConferenceController controller = ConferenceController.sharedInstance();
        mViewState = controller.getViewState();
        mSeatState = controller.getSeatState();
        mRoomState = controller.getRoomState();
        mUserState = controller.getUserState();
        mInvitationState = controller.getInvitationState();

        mViewController = controller.getViewController();
    }
}
