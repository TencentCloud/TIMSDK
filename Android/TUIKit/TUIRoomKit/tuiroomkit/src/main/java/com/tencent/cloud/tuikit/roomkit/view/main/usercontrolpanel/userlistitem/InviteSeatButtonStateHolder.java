package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.state.ViewState;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class InviteSeatButtonStateHolder extends StateHolder {
    private String                            mUserId         = "";
    private LiveData<InviteSeatButtonUiState> mInviteSeatData = new LiveData<>();
    private boolean                           mIsSeatEnabled  = mRoomState.isSeatEnabled.get();
    private List<String>                      mSeatedUsers    = mSeatState.seatedUsers.getList();
    private UserState.UserInfo                mLocalUser      = mUserState.selfInfo.get();

    private Observer<Boolean>                    mSeatEnableObserver = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isSeatEnable) {
            mIsSeatEnabled = isSeatEnable;
            updateViewData();
        }
    };
    private LiveListObserver<String>             mSeatedObserver     = new LiveListObserver<String>() {
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
    private LiveListObserver<UserState.UserInfo> mAllUserObserver    = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onDataChanged(List<UserState.UserInfo> list) {
        }

        @Override
        public void onItemChanged(int position, UserState.UserInfo item) {
            shouldShowInviteSeat();
        }
    };
    private Observer<UserState.UserInfo>         mSelfInfoObserver   = new Observer<UserState.UserInfo>() {
        @Override
        public void onChanged(UserState.UserInfo userInfo) {
            mLocalUser = userInfo;
            updateViewData();
        }
    };

    public void setUserId(String userId) {
        mUserId = userId;
        updateViewData();
    }

    public void observe(Observer<InviteSeatButtonUiState> observer) {
        mInviteSeatData.observe(observer);
        mRoomState.isSeatEnabled.observe(mSeatEnableObserver);
        mSeatState.seatedUsers.observe(mSeatedObserver);
        mUserState.selfInfo.observe(mSelfInfoObserver);
    }

    public void removeObserver(Observer<InviteSeatButtonUiState> observer) {
        mInviteSeatData.removeObserver(observer);
        mRoomState.isSeatEnabled.removeObserver(mSeatEnableObserver);
        mSeatState.seatedUsers.removeObserver(mSeatedObserver);
        mUserState.selfInfo.removeObserver(mSelfInfoObserver);
    }

    private void updateViewData() {
        InviteSeatButtonUiState uiState = new InviteSeatButtonUiState();
        uiState.isShow = shouldShowInviteSeat();
        mInviteSeatData.set(uiState);
    }

    private boolean shouldShowInviteSeat() {
        if (!ViewState.UserListType.OFF_SEAT.equals(mViewState.userListType.get())) {
            return false;
        }
        if (mSeatedUsers.contains(mUserId)) {
            return false;
        }
        if (mLocalUser.role.get() == TUIRoomDefine.Role.GENERAL_USER) {
            return false;
        }
        if (mLocalUser.role.get() == TUIRoomDefine.Role.ROOM_OWNER) {
            return true;
        }
        UserState.UserInfo userInfo = mUserState.allUsers.find(new UserState.UserInfo(mUserId));
        if (userInfo == null) {
            return false;
        }
        return userInfo.role.get() == TUIRoomDefine.Role.GENERAL_USER;
    }
}
