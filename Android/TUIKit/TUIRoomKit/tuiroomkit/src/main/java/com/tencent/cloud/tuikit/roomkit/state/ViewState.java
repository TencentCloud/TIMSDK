package com.tencent.cloud.tuikit.roomkit.state;

import com.tencent.cloud.tuikit.roomkit.state.entity.Request;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListData;

public class ViewState {
    public LiveListData<String> pendingTakeSeatRequests = new LiveListData<>();

    public LiveData<Boolean> isScreenPortrait = new LiveData<>(true);

    public LiveData<String>       searchUserKeyWord = new LiveData<>("");
    public LiveData<UserListType> userListType      = new LiveData<>(UserListType.IN_ROOM);

    public LiveData<RoomProcess> roomProcess           = new LiveData<>(RoomProcess.NONE);
    public LiveData<Long>        enterRoomTimeFromBoot = new LiveData<>(0L);

    public LiveData<Boolean> isInvitationPending           = new LiveData<>(false);
    public LiveData<Boolean> isSpeechToTextSubTitleShowing = new LiveData<>(false);

    public FloatWindowType   floatWindowType          = FloatWindowType.NONE;
    public LiveData<Boolean> isInPictureInPictureMode = new LiveData<>(false);

    public void addPendingTakeSeatRequest(String requestId) {
        pendingTakeSeatRequests.add(requestId);
    }

    public void removePendingTakeSeatRequestByUserId(String userId) {
        SeatState seatState = ConferenceController.sharedInstance().getSeatState();
        Request request = seatState.findTakeSeatRequestByUserId(userId);
        if (request == null) {
            return;
        }
        removePendingTakeSeatRequest(request.requestId);
    }

    public void removePendingTakeSeatRequest(String requestId) {
        pendingTakeSeatRequests.remove(requestId);
    }

    public void clearPendingTakeSeatRequests() {
        pendingTakeSeatRequests.clear();
    }

    public enum RoomProcess {
        NONE,
        COMING,
        IN,
        OUTING
    }

    public enum UserListType {
        ON_SEAT,
        OFF_SEAT,
        IN_ROOM,
        OUT_ROOM
    }

    public enum FloatWindowType {
        NONE,
        WINDOW_MANAGER,
        PICTURE_IN_PICTURE,
    }
}
