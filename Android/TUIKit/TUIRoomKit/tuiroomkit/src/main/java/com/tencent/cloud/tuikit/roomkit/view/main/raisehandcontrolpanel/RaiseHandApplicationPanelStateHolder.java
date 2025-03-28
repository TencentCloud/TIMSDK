package com.tencent.cloud.tuikit.roomkit.view.main.raisehandcontrolpanel;

import com.tencent.cloud.tuikit.roomkit.state.entity.Request;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class RaiseHandApplicationPanelStateHolder extends StateHolder {
    private LiveData<RaiseHandApplicationPanelUiState> mUiState = new LiveData<>();

    private List<Request>             mTakeSeatRequests = mSeatState.takeSeatRequests.getList();
    private LiveListObserver<Request> mRequestsObserver = new LiveListObserver<Request>() {
        @Override
        public void onDataChanged(List<Request> list) {
            updateView();
        }

        @Override
        public void onItemInserted(int position, Request request) {
            updateView();
        }

        @Override
        public void onItemRemoved(int position, Request request) {
            updateView();
        }
    };

    private boolean           mIsScreenPortrait    = mViewState.isScreenPortrait.get();
    private Observer<Boolean> mOrientationObserver = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isPortrait) {
            mIsScreenPortrait = isPortrait;
            updateView();
        }
    };

    public void observe(Observer<RaiseHandApplicationPanelUiState> observer) {
        mUiState.observe(observer);
        mSeatState.takeSeatRequests.observe(mRequestsObserver);
        mViewState.isScreenPortrait.observe(mOrientationObserver);
    }

    public void removeObserver(Observer<RaiseHandApplicationPanelUiState> observer) {
        mUiState.removeObserver(observer);
        mSeatState.takeSeatRequests.removeObserver(mRequestsObserver);
        mViewState.isScreenPortrait.removeObserver(mOrientationObserver);
    }

    private void updateView() {
        RaiseHandApplicationPanelUiState uiState = new RaiseHandApplicationPanelUiState();
        uiState.isApplicationEmpty = mTakeSeatRequests.isEmpty();
        uiState.isScreenPortrait = mIsScreenPortrait;
        mUiState.set(uiState);
    }
}
