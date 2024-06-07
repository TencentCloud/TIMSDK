package com.tencent.cloud.tuikit.roomkit.model.data;

import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListData;
import com.tencent.cloud.tuikit.roomkit.model.entity.Request;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.LiveData;

public class ViewState {
    public LiveListData<String> pendingTakeSeatRequests = new LiveListData<>();

    public LiveData<Boolean> isScreenPortrait = new LiveData<>(true);

    public LiveData<String>  searchUserKeyWord   = new LiveData<>("");
    public LiveData<Boolean> isSeatedTabSelected = new LiveData<>(true);

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
}
