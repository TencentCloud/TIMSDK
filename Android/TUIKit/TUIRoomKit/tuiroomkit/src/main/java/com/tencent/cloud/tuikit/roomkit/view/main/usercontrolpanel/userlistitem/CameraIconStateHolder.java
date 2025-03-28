package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem;

import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.IN_ROOM;
import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.ON_SEAT;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class CameraIconStateHolder extends StateHolder {
    private String                      mUserId            = "";
    private LiveData<CameraIconUiState> mCameraIconData    = new LiveData<>(new CameraIconUiState());
    private CameraIconUiState           mCameraIconUiState = new CameraIconUiState();

    private boolean                  mIsSeatEnable         = mRoomState.isSeatEnabled.get();
    private List<String>             mSeatedUsers          = mSeatState.seatedUsers.getList();
    private List<String>             mHasCameraStreamUsers = mUserState.hasCameraStreamUsers.getList();
    private Observer<Boolean>        mSeatEnableObserver   = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isSeatEnable) {
            mIsSeatEnable = isSeatEnable;
            updateViewData();
        }
    };
    private LiveListObserver<String> mSeatObserver         = new LiveListObserver<String>() {
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
    private LiveListObserver<String> mCameraStreamObserver = new LiveListObserver<String>() {
        @Override
        public void onItemInserted(int position, String item) {
            if (!TextUtils.equals(item, mUserId)) {
                return;
            }
            updateViewData();
        }

        @Override
        public void onItemRemoved(int position, String item) {
            if (!TextUtils.equals(item, mUserId)) {
                return;
            }
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
        mCameraIconUiState.isShow = isShowView();
        mCameraIconData.set(mCameraIconUiState);
    }

    private boolean isShowView() {
        if (IN_ROOM.equals(mViewState.userListType.get())) {
            return true;
        }
        return ON_SEAT.equals(mViewState.userListType.get()) && mSeatedUsers.contains(mUserId);
    }
}
