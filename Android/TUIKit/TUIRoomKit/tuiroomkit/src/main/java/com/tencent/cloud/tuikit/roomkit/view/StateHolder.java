package com.tencent.cloud.tuikit.roomkit.view;

import com.tencent.cloud.tuikit.roomkit.model.controller.ViewController;
import com.tencent.cloud.tuikit.roomkit.model.data.RoomState;
import com.tencent.cloud.tuikit.roomkit.model.data.SeatState;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.cloud.tuikit.roomkit.model.data.ViewState;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;

public class StateHolder {
    protected ViewState mViewState;
    protected SeatState mSeatState;
    protected RoomState mRoomState;
    protected UserState mUserState;

    protected ViewController mViewController;

    public StateHolder() {
        ConferenceController controller = ConferenceController.sharedInstance();
        mViewState = controller.getViewState();
        mSeatState = controller.getSeatState();
        mRoomState = controller.getRoomState();
        mUserState = controller.getUserState();

        mViewController = controller.getViewController();
    }
}
