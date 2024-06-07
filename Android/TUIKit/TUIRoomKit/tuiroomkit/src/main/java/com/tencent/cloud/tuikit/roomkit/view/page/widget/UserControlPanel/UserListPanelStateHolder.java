package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListObserver;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class UserListPanelStateHolder extends StateHolder {
    private LiveData<UserListPanelUiState> mUserListUiData  = new LiveData<>();
    private UserListPanelUiState           mUserListUiState = new UserListPanelUiState();
    private List<UserState.UserInfo>       mAllUserList     = mUserState.allUsers.getList();
    private List<String>                   mOnSeatUserList  = mSeatState.seatedUsers.getList();

    private Observer<Boolean> mSeatEnableObserver = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isSeatEnable) {
            mUserListUiState.isShowOnOffSeatTab = isSeatEnable;
            mUserListUiData.set(mUserListUiState);
        }
    };

    private Observer<Boolean> mOnSeatTabObserver = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isOnSeatTabSelected) {
            mUserListUiState.isOnSeatTabSelected = isOnSeatTabSelected;
            mUserListUiData.set(mUserListUiState);
        }
    };

    private LiveListObserver<String> mOnSeatObserver = new LiveListObserver<String>() {
        @Override
        public void onDataChanged(List<String> list) {
            updateSeatCount();
        }

        @Override
        public void onItemInserted(int position, String item) {
            updateSeatCount();
        }

        @Override
        public void onItemRemoved(int position, String item) {
            updateSeatCount();
        }
    };

    private LiveListObserver<UserState.UserInfo> mAllUserObserver = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onDataChanged(List<UserState.UserInfo> list) {
            updateSeatCount();
        }

        @Override
        public void onItemInserted(int position, UserState.UserInfo item) {
            updateSeatCount();
        }

        @Override
        public void onItemRemoved(int position, UserState.UserInfo item) {
            updateSeatCount();
        }
    };

    public void observe(Observer<UserListPanelUiState> observer) {
        mUserListUiData.observe(observer);
        mRoomState.isSeatEnabled.observe(mSeatEnableObserver);
        mSeatState.seatedUsers.observe(mOnSeatObserver);
        mUserState.allUsers.observe(mAllUserObserver);
        mViewState.isSeatedTabSelected.observe(mOnSeatTabObserver);
    }

    public void removeObserver(Observer<UserListPanelUiState> observer) {
        mUserListUiData.removeObserver(observer);
        mRoomState.isSeatEnabled.removeObserver(mSeatEnableObserver);
        mSeatState.seatedUsers.removeObserver(mOnSeatObserver);
        mUserState.allUsers.removeObserver(mAllUserObserver);
        mViewState.isSeatedTabSelected.removeObserver(mOnSeatTabObserver);
    }

    private void updateSeatCount() {
        mUserListUiState.onSeatUserCount = mOnSeatUserList.size();
        mUserListUiState.offSeatUserCount = mAllUserList.size() - mUserListUiState.onSeatUserCount;
        mUserListUiData.set(mUserListUiState);
    }
}
