package com.tencent.cloud.tuikit.roomkit.view.main.bottomnavigationbar;

import com.tencent.cloud.tuikit.roomkit.state.entity.Request;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class SeatRequestCountStateHolder extends StateHolder {

    private LiveData<SeatRequestCountUiState> mSeatRequestCountUiState = new LiveData<>();

    private List<Request>             mTakeSeatRequests;
    private LiveListObserver<Request> mSeatRequestObserver = new LiveListObserver<Request>() {
        @Override
        public void onDataChanged(List<Request> list) {
            mTakeSeatRequests = list;
            updateSeatQuestCount();
        }

        @Override
        public void onItemInserted(int position, Request item) {
            updateSeatQuestCount();
        }

        @Override
        public void onItemRemoved(int position, Request item) {
            updateSeatQuestCount();
        }
    };

    public void observe(Observer<SeatRequestCountUiState> observer) {
        mSeatRequestCountUiState.observe(observer);
        mSeatState.takeSeatRequests.observe(mSeatRequestObserver);
    }

    public void removeObserver(Observer<SeatRequestCountUiState> observer) {
        mSeatRequestCountUiState.removeObserver(observer);
        mSeatState.takeSeatRequests.removeObserver(mSeatRequestObserver);
    }

    private void updateSeatQuestCount() {
        SeatRequestCountUiState uiState = new SeatRequestCountUiState();
        if (mTakeSeatRequests.isEmpty()) {
            uiState.isShow = false;
            mSeatRequestCountUiState.set(uiState);
            return;
        }
        uiState.isShow = true;
        uiState.message = String.valueOf(mTakeSeatRequests.size());
        mSeatRequestCountUiState.set(uiState);
    }
}
