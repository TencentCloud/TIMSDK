package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem;

import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.IN_ROOM;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.roomkit.state.ViewState;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class MicIconStateHolder extends StateHolder {
    private String                   mUserId         = "";
    private LiveData<MicIconUiState> mMicIconData    = new LiveData<>(new MicIconUiState());
    private MicIconUiState           mMicIconUiState = new MicIconUiState();

    private boolean                  mIsSeatEnable        = mRoomState.isSeatEnabled.get();
    private List<String>             mSeatedUsers         = mSeatState.seatedUsers.getList();
    private List<String>             mHasAudioStreamUsers = mUserState.hasAudioStreamUsers.getList();
    private Observer<Boolean>        mSeatEnableObserver  = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isSeatEnable) {
            mIsSeatEnable = isSeatEnable;
            updateViewData();
        }
    };
    private LiveListObserver<String> mSeatObserver        = new LiveListObserver<String>() {
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
    private LiveListObserver<String> mAudioStreamObserver = new LiveListObserver<String>() {
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

    public void observe(Observer<MicIconUiState> observer) {
        mMicIconData.observe(observer);
        mRoomState.isSeatEnabled.observe(mSeatEnableObserver);
        mSeatState.seatedUsers.observe(mSeatObserver);
        mUserState.hasAudioStreamUsers.observe(mAudioStreamObserver);
    }

    public void removeObserver(Observer<MicIconUiState> observer) {
        mMicIconData.removeObserver(observer);
        mRoomState.isSeatEnabled.removeObserver(mSeatEnableObserver);
        mSeatState.seatedUsers.removeObserver(mSeatObserver);
        mUserState.hasAudioStreamUsers.removeObserver(mAudioStreamObserver);
    }

    public void updateViewData() {
        mMicIconUiState.hasAudioStream = mHasAudioStreamUsers.contains(mUserId);
        mMicIconUiState.isShow = isShowView();
        mMicIconData.set(mMicIconUiState);
    }

    private boolean isShowView() {
        if (IN_ROOM.equals(mViewState.userListType.get())) {
            return true;
        }
        return ViewState.UserListType.ON_SEAT.equals(mViewState.userListType.get()) && mSeatedUsers.contains(mUserId);
    }
}
