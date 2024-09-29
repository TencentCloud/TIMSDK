package com.tencent.cloud.tuikit.roomkit.model.data;

import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListData;
import com.tencent.cloud.tuikit.roomkit.model.entity.Request;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.LiveData;

public class ViewState {
    public LiveListData<String> pendingTakeSeatRequests = new LiveListData<>();

    public LiveData<Boolean> isScreenPortrait = new LiveData<>(true);

    public LiveData<String>       searchUserKeyWord = new LiveData<>("");
    public LiveData<UserListType> userListType      = new LiveData<>(UserListType.ALL_USER_ENTERED_THE_ROOM);

    public LiveData<RoomProcess> roomProcess           = new LiveData<>(RoomProcess.NONE);
    public LiveData<Long>        enterRoomTimeFromBoot = new LiveData<>(0L);

    public LiveData<Boolean> isInvitationPending = new LiveData<>(false);

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
        ON_SEAT_INSIDE_THE_ROOM,
        OFF_SEAT_INSIDE_THE_ROOM,
        ALL_USER_ENTERED_THE_ROOM,
        ALL_USER_NOT_ENTERED_THE_ROOM
    }
}
