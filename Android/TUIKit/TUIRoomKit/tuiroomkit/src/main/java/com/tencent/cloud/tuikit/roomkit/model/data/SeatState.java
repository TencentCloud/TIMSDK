package com.tencent.cloud.tuikit.roomkit.model.data;

import static com.tencent.cloud.tuikit.roomkit.model.ConferenceConstant.USER_NOT_FOUND;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListData;
import com.tencent.cloud.tuikit.roomkit.model.entity.Request;
import com.trtc.tuikit.common.livedata.LiveData;

import java.util.LinkedHashSet;
import java.util.List;

public class SeatState {
    public LiveListData<Request> takeSeatRequests = new LiveListData<>();
    public LiveListData<String>            seatedUsers         = new LiveListData<>();

    public void addTakeSeatRequest(TUIRoomDefine.Request engineRequest) {
        Request request = new Request(engineRequest);
        takeSeatRequests.add(request);
    }

    public void removeTakeSeatRequestByUserId(String userId) {
        List<Request> takeSeatRequestList = takeSeatRequests.getList();
        int position = USER_NOT_FOUND;
        for (int i = 0; i < takeSeatRequestList.size(); i++) {
            if (TextUtils.equals(userId, takeSeatRequestList.get(i).userId)) {
                position = i;
                break;
            }
        }
        if (position == USER_NOT_FOUND) {
            return;
        }
        takeSeatRequests.remove(position);
    }

    public void removeTakeSeatRequest(String requestId) {
        List<Request> takeSeatRequestList = takeSeatRequests.getList();
        int position = USER_NOT_FOUND;
        for (int i = 0; i < takeSeatRequestList.size(); i++) {
            if (TextUtils.equals(requestId, takeSeatRequestList.get(i).requestId)) {
                position = i;
                break;
            }
        }
        if (position == USER_NOT_FOUND) {
            return;
        }
        takeSeatRequests.remove(position);
    }

    public void clearTakeSeatRequests() {
        takeSeatRequests.clear();
    }

    @Nullable
    public Request findTakeSeatRequestByUserId(String userId) {
        List<Request> takeSeatRequestList = takeSeatRequests.getList();
        int size = takeSeatRequestList.size();
        for (int i = 0; i < size; i++) {
            if (TextUtils.equals(userId, takeSeatRequestList.get(i).userId)) {
                return takeSeatRequestList.get(i);
            }
        }
        return null;
    }

    public Request findTakeSeatRequestByRequestId(String requestId) {
        List<Request> takeSeatRequestList = takeSeatRequests.getList();
        int size = takeSeatRequestList.size();
        for (int i = 0; i < size; i++) {
            if (TextUtils.equals(requestId, takeSeatRequestList.get(i).requestId)) {
                return takeSeatRequestList.get(i);
            }
        }
        return null;
    }
}
