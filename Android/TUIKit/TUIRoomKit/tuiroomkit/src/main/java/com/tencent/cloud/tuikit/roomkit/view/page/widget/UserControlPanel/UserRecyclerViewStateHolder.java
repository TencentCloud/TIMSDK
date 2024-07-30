package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListData;
import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListObserver;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.LinkedList;
import java.util.List;

public class UserRecyclerViewStateHolder extends StateHolder {
    private LiveListData<UserState.UserInfo> mUserListData        = new LiveListData<>();
    private boolean                          mIsSeatEnabled       = mRoomState.isSeatEnabled.get();
    private String                           mSearchWord          = mViewState.searchUserKeyWord.get();
    private boolean                          mIsOnSeatTabSelected = mViewState.isSeatedTabSelected.get();
    private List<UserState.UserInfo>         mAllUserList         = mUserState.allUsers.getList();
    private List<String>                     mSeatUserList        = mSeatState.seatedUsers.getList();

    private Observer<Boolean>                    mSeatEnableObserver = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isSeatEnable) {
            mIsSeatEnabled = isSeatEnable;
        }
    };
    private Observer<String>                     mSearchWordObserver = new Observer<String>() {
        @Override
        public void onChanged(String searchWord) {
            mSearchWord = searchWord;
            notifyDataChanged();
        }
    };
    private Observer<Boolean>                    mSeatedTabObserver  = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isOnSeatTabSelected) {
            mIsOnSeatTabSelected = isOnSeatTabSelected;
            notifyDataChanged();
        }
    };
    private LiveListObserver<UserState.UserInfo> mAllUserObserver    = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onDataChanged(List<UserState.UserInfo> list) {
            notifyDataChanged();
        }

        @Override
        public void onItemChanged(int position, UserState.UserInfo item) {
            notifyUserChanged(item);
        }

        @Override
        public void onItemInserted(int position, UserState.UserInfo item) {
            notifyUserInserted(item);
        }

        @Override
        public void onItemRemoved(int position, UserState.UserInfo item) {
            notifyUserRemoved(item);
        }
    };
    private LiveListObserver<String>             mSeatedUserObserver = new LiveListObserver<String>() {
        @Override
        public void onDataChanged(List<String> list) {
            notifyDataChanged();
        }

        @Override
        public void onItemInserted(int position, String item) {
            notifySeatInserted(item);
        }

        @Override
        public void onItemRemoved(int position, String item) {
            notifySeatRemoved(item);
        }
    };

    public void observe(LiveListObserver<UserState.UserInfo> observer) {
        mUserListData.observe(observer);
        mRoomState.isSeatEnabled.observe(mSeatEnableObserver);
        mViewState.searchUserKeyWord.observe(mSearchWordObserver);
        mViewState.isSeatedTabSelected.observe(mSeatedTabObserver);
        mUserState.allUsers.observe(mAllUserObserver);
        mSeatState.seatedUsers.observe(mSeatedUserObserver);
    }

    public void removeObserver(LiveListObserver<UserState.UserInfo> observer) {
        mUserListData.removeObserver(observer);
        mRoomState.isSeatEnabled.removeObserver(mSeatEnableObserver);
        mViewState.searchUserKeyWord.removeObserver(mSearchWordObserver);
        mViewState.isSeatedTabSelected.removeObserver(mSeatedTabObserver);
        mUserState.allUsers.removeObserver(mAllUserObserver);
        mSeatState.seatedUsers.removeObserver(mSeatedUserObserver);
    }

    private void notifyDataChanged() {
        List<UserState.UserInfo> users = new LinkedList<>();
        for (UserState.UserInfo item : mAllUserList) {
            if (isTargetUser(item)) {
                users.add(item);
            }
        }
        mUserListData.redirect(users);
    }

    private void notifyUserChanged(UserState.UserInfo userInfo) {
        if (isTargetUser(userInfo)) {
            mUserListData.change(userInfo);
        }
    }

    private void notifyUserInserted(UserState.UserInfo userInfo) {
        if (isTargetUser(userInfo)) {
            mUserListData.add(userInfo);
        }
    }

    private void notifyUserRemoved(UserState.UserInfo userInfo) {
        if (isTargetUser(userInfo)) {
            mUserListData.remove(userInfo);
        }
    }

    private void notifySeatInserted(String userId) {
        UserState.UserInfo seatedUser = mUserState.allUsers.find(new UserState.UserInfo(userId));
        if (seatedUser == null) {
            return;
        }
        if (!seatedUser.userName.contains(mSearchWord)) {
            return;
        }
        if (mIsOnSeatTabSelected) {
            mUserListData.add(seatedUser);
            return;
        }
        mUserListData.remove(seatedUser);
    }

    private void notifySeatRemoved(String userId) {
        UserState.UserInfo leftUser = mUserState.allUsers.find(new UserState.UserInfo(userId));
        if (leftUser == null) {
            return;
        }
        if (!leftUser.userName.contains(mSearchWord)) {
            return;
        }
        if (mIsOnSeatTabSelected) {
            mUserListData.remove(leftUser);
            return;
        }
        mUserListData.add(leftUser);
    }

    private boolean isTargetUser(UserState.UserInfo userInfo) {
        if (!userInfo.userName.contains(mSearchWord)) {
            return false;
        }
        if (!mIsSeatEnabled) {
            return true;
        }
        boolean isSeated = mSeatUserList.contains(userInfo.userId);
        if (mIsOnSeatTabSelected && isSeated) {
            return true;
        }
        if (!(mIsOnSeatTabSelected || isSeated)) {
            return true;
        }
        return false;
    }
}
