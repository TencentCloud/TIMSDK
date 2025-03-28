package com.tencent.cloud.tuikit.roomkit.view.main.raisehandcontrolpanel;

import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.DURATION_FOREVER;

import android.os.SystemClock;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.state.entity.Request;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class RaiseHandNotificationStateHolder extends StateHolder {
    private int mDuration;

    private LiveData<RaiseHandNotificationUiState> mRaiseHandNotificationUiState = new LiveData<>();

    private List<String> mPendingRequests = mViewState.pendingTakeSeatRequests.getList();

    private LiveListObserver<String> mPendingObserver = new LiveListObserver<String>() {
        @Override
        public void onDataChanged(List<String> list) {
            updateNotification(null);
        }

        @Override
        public void onItemInserted(int position, String requestId) {
            updateNotification(null);
        }

        @Override
        public void onItemRemoved(int position, String requestId) {
            updateNotification(null);
        }
    };

    private LiveListObserver<UserState.UserInfo> mAllUserObserver = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onItemChanged(int position, UserState.UserInfo item) {
            updateNotification(item.userId);
        }
    };

    public RaiseHandNotificationStateHolder(int duration) {
        mDuration = duration;
    }

    public void observe(Observer<RaiseHandNotificationUiState> observer) {
        mRaiseHandNotificationUiState.observe(observer);
        mViewState.pendingTakeSeatRequests.observe(mPendingObserver);
        mUserState.allUsers.observe(mAllUserObserver);
    }

    public void removeObserver(Observer<RaiseHandNotificationUiState> observer) {
        mRaiseHandNotificationUiState.removeObserver(observer);
        mViewState.pendingTakeSeatRequests.removeObserver(mPendingObserver);
        mUserState.allUsers.removeObserver(mAllUserObserver);
    }

    private void updateNotification(String userId) {
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
        if (!TextUtils.isEmpty(userId) && !TextUtils.equals(userId, takeSeatRequest.userId)) {
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
