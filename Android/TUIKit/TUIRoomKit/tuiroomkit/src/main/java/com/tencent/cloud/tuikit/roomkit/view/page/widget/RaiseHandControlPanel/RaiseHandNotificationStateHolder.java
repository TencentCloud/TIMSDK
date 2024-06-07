package com.tencent.cloud.tuikit.roomkit.view.page.widget.RaiseHandControlPanel;

import static com.tencent.cloud.tuikit.roomkit.model.ConferenceConstant.DURATION_FOREVER;

import android.os.SystemClock;

import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListObserver;
import com.tencent.cloud.tuikit.roomkit.model.entity.Request;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class RaiseHandNotificationStateHolder extends StateHolder {
    private int mDuration;

    private LiveData<RaiseHandNotificationUiState> mRaiseHandNotificationUiState = new LiveData<>();

    private List<String> mPendingRequests = mViewState.pendingTakeSeatRequests.getList();

    private LiveListObserver<String> mPendingObserver = new LiveListObserver<String>() {
        @Override
        public void onDataChanged(List<String> list) {
            updateNotification();
        }

        @Override
        public void onItemInserted(int position, String requestId) {
            updateNotification();
        }

        @Override
        public void onItemRemoved(int position, String requestId) {
            updateNotification();
        }
    };

    public RaiseHandNotificationStateHolder(int duration) {
        mDuration = duration;
    }

    public void observe(Observer<RaiseHandNotificationUiState> observer) {
        mRaiseHandNotificationUiState.observe(observer);
        mViewState.pendingTakeSeatRequests.observe(mPendingObserver);
    }

    public void removeObserver(Observer<RaiseHandNotificationUiState> observer) {
        mRaiseHandNotificationUiState.removeObserver(observer);
        mViewState.pendingTakeSeatRequests.removeObserver(mPendingObserver);
    }

    private void updateNotification() {
        RaiseHandNotificationUiState uiState = new RaiseHandNotificationUiState();
        uiState.duration = mDuration;
        if (mPendingRequests.isEmpty()) {
            uiState.isShow = false;
            mRaiseHandNotificationUiState.set(uiState);
            return;
        }
        String latestRequestId = mPendingRequests.get(mPendingRequests.size() - 1);
        Request takeSeatRequest = mSeatState.findTakeSeatRequestByRequestId(latestRequestId);
        if (takeSeatRequest == null) {
            return;
        }
        boolean isShow = (mDuration == DURATION_FOREVER) || (SystemClock.elapsedRealtime() - takeSeatRequest.timestamp
                < mDuration);
        uiState.isShow = isShow;
        uiState.userId = takeSeatRequest.userId;
        uiState.userName = takeSeatRequest.userName;
        uiState.count = mSeatState.takeSeatRequests.size();
        mRaiseHandNotificationUiState.set(uiState);
    }
}
