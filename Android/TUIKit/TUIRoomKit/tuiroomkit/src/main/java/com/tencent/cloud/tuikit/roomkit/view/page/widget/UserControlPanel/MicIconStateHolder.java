package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListObserver;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;
import java.util.Set;

public class MicIconStateHolder extends StateHolder {
    private String                   mUserId         = "";
    private LiveData<MicIconUiState> mMicIconData    = new LiveData<>(new MicIconUiState());
    private MicIconUiState           mMicIconUiState = new MicIconUiState();

    private boolean      mIsSeatEnable        = mRoomState.isSeatEnabled.get();
    private     List<String> mSeatedUsers         = mSeatState.seatedUsers.getList();
    private     Set<String>  mHasAudioStreamUsers = mUserState.hasAudioStreamUsers.get();
    private Observer<Boolean>        mSeatEnableObserver = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isSeatEnable) {
            mIsSeatEnable = isSeatEnable;
            updateViewData();
        }
    };
    private     LiveListObserver<String> mSeatObserver       = new LiveListObserver<String>() {
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
    private Observer<Set<String>>    mAudioStreamObserver = new Observer<Set<String>>() {
        @Override
        public void onChanged(Set<String> hasAudioStreamUsers) {
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
        mMicIconUiState.isShow = !mIsSeatEnable || mSeatedUsers.contains(mUserId);
        mMicIconData.set(mMicIconUiState);
    }
}
