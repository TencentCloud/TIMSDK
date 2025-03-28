package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel;

import com.tencent.cloud.tuikit.roomkit.state.InvitationState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class UserListTypeSelectViewStateHolder extends StateHolder {
    private LiveData<Integer> mOnSeatUserCount        = new LiveData<>();
    private LiveData<Integer> mOffSeatUserCount       = new LiveData<>();
    private LiveData<Integer> mAllEnteredUserCount    = new LiveData<>();
    private LiveData<Integer> mAllNotEnteredUserCount = new LiveData<>();
    private LiveData<Boolean> mIsSeatEnabled          = new LiveData<>();

    private Observer<Boolean> mSeatEnableObserver = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isSeatEnable) {
            mIsSeatEnabled.set(isSeatEnable);
        }
    };

    private LiveListObserver<InvitationState.Invitation> mInvitationObserver = new LiveListObserver<InvitationState.Invitation>() {
        @Override
        public void onDataChanged(List<InvitationState.Invitation> list) {
            updateAllNotEnteredUserCount();
        }

        @Override
        public void onItemChanged(int position, InvitationState.Invitation item) {
            updateAllNotEnteredUserCount();
        }

        @Override
        public void onItemInserted(int position, InvitationState.Invitation item) {
            updateAllNotEnteredUserCount();
        }

        @Override
        public void onItemRemoved(int position, InvitationState.Invitation item) {
            updateAllNotEnteredUserCount();
        }

        @Override
        public void onItemMoved(int fromPosition, int toPosition, InvitationState.Invitation item) {
            updateAllNotEnteredUserCount();
        }
    };

    public UserListTypeSelectViewStateHolder() {
        mRoomState.isSeatEnabled.observe(mSeatEnableObserver);
        mSeatState.seatedUsers.observe(mOnSeatObserver);
        mUserState.allUsers.observe(mAllUserObserver);
        mInvitationState.invitationList.observe(mInvitationObserver);
    }

    public void destroy() {
        mRoomState.isSeatEnabled.removeObserver(mSeatEnableObserver);
        mSeatState.seatedUsers.removeObserver(mOnSeatObserver);
        mUserState.allUsers.removeObserver(mAllUserObserver);
        mInvitationState.invitationList.removeObserver(mInvitationObserver);
    }

    private LiveListObserver<String> mOnSeatObserver = new LiveListObserver<String>() {
        @Override
        public void onDataChanged(List<String> list) {
            updateOnSeatUserCount();
            updateOffSeatUserCount();
        }

        @Override
        public void onItemInserted(int position, String item) {
            updateOnSeatUserCount();
            updateOffSeatUserCount();
        }

        @Override
        public void onItemRemoved(int position, String item) {
            updateOnSeatUserCount();
            updateOffSeatUserCount();
        }
    };

    private LiveListObserver<UserState.UserInfo> mAllUserObserver = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onDataChanged(List<UserState.UserInfo> list) {
            updateAllEnteredUserCount();

        }

        @Override
        public void onItemInserted(int position, UserState.UserInfo item) {
            updateAllEnteredUserCount();
        }

        @Override
        public void onItemRemoved(int position, UserState.UserInfo item) {
            updateAllEnteredUserCount();
        }
    };

    public void observeSeatEnabled(Observer<Boolean> observer) {
        mIsSeatEnabled.observe(observer);
    }

    public void observeOnSeatUserCount(Observer<Integer> observer) {
        mOnSeatUserCount.observe(observer);
    }

    public void observeOffSeatUserCount(Observer<Integer> observer) {
        mOffSeatUserCount.observe(observer);
    }

    public void observeAllEnteredSeatUserCount(Observer<Integer> observer) {
        mAllEnteredUserCount.observe(observer);
    }

    public void observeAllNotEnteredUserCount(Observer<Integer> observer) {
        mAllNotEnteredUserCount.observe(observer);
    }

    public void removeSeatEnabledObserver(Observer<Boolean> observer) {
        mIsSeatEnabled.removeObserver(observer);
    }

    public void removeOnSeatUserCountObserver(Observer<Integer> observer) {
        mOnSeatUserCount.removeObserver(observer);
    }

    public void removeOffSeatUserCountObserver(Observer<Integer> observer) {
        mOffSeatUserCount.removeObserver(observer);
    }

    public void removeAllEnteredSeatUserCountObserver(Observer<Integer> observer) {
        mAllEnteredUserCount.removeObserver(observer);
    }

    public void removeAllNotEnteredUserCountObserver(Observer<Integer> observer) {
        mAllNotEnteredUserCount.removeObserver(observer);
    }

    private void updateOnSeatUserCount() {
        mOnSeatUserCount.set(mSeatState.seatedUsers.size());
    }

    private void updateOffSeatUserCount() {
        mOffSeatUserCount.set(mUserState.allUsers.size() - mSeatState.seatedUsers.size());
    }

    private void updateAllEnteredUserCount() {
        if (mRoomState.isSeatEnabled.get()) {
            updateOnSeatUserCount();
            updateOffSeatUserCount();
        } else {
            mAllEnteredUserCount.set(mUserState.allUsers.size());
        }
    }

    private void updateAllNotEnteredUserCount() {
        int number = mInvitationState.invitationList.getList().size();
        mAllNotEnteredUserCount.set(number);
    }
}
