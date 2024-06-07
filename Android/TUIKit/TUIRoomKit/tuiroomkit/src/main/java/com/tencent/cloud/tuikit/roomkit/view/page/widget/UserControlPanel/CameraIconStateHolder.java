package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListObserver;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;
import java.util.Set;

public class CameraIconStateHolder extends StateHolder {
    private String                      mUserId            = "";
    private LiveData<CameraIconUiState> mCameraIconData    = new LiveData<>(new CameraIconUiState());
    private CameraIconUiState           mCameraIconUiState = new CameraIconUiState();

    private boolean      mIsSeatEnable         = mRoomState.isSeatEnabled.get();
    private List<String> mSeatedUsers          = mSeatState.seatedUsers.getList();
    private Set<String>  mHasCameraStreamUsers = mUserState.hasCameraStreamUsers.get();
    private Observer<Boolean> mSeatEnableObserver = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isSeatEnable) {
            mIsSeatEnable = isSeatEnable;
            updateViewData();
        }
    };
    private LiveListObserver<String> mSeatObserver = new LiveListObserver<String>() {
        @Override
        public void onDataChanged(List<String> list) {
            updateViewData();
        }

        @Override
        public void onItemInserted(int position, String item) {
            updateViewData();
        }

        @Override
        public void onItemRemoved(int position, String item) {
            updateViewData();
        }
    };
    private Observer<Set<String>>       mCameraStreamObserver = new Observer<Set<String>>() {
        @Override
        public void onChanged(Set<String> hasCameraStreamUsers) {
            updateViewData();
        }
    };

    public void setUserId(String userId) {
        mUserId = userId;
        updateViewData();
    }

    public void observe(Observer<CameraIconUiState> observer) {
        mCameraIconData.observe(observer);
        mRoomState.isSeatEnabled.observe(mSeatEnableObserver);
        mSeatState.seatedUsers.observe(mSeatObserver);
        mUserState.hasCameraStreamUsers.observe(mCameraStreamObserver);
    }

    public void removeObserver(Observer<CameraIconUiState> observer) {
        mCameraIconData.removeObserver(observer);
        mRoomState.isSeatEnabled.removeObserver(mSeatEnableObserver);
        mSeatState.seatedUsers.removeObserver(mSeatObserver);
        mUserState.hasCameraStreamUsers.removeObserver(mCameraStreamObserver);
    }

    public void updateViewData() {
        mCameraIconUiState.hasCameraStream = mHasCameraStreamUsers.contains(mUserId);
        mCameraIconUiState.isShow = !mIsSeatEnable || mSeatedUsers.contains(mUserId);
        mCameraIconData.set(mCameraIconUiState);
    }
}
