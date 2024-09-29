package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListData;
import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListObserver;
import com.tencent.cloud.tuikit.roomkit.model.data.InvitationState;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.cloud.tuikit.roomkit.model.data.ViewState;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.LinkedList;
import java.util.List;

public class UserRecyclerViewStateHolder extends StateHolder {
    private LiveListData<UserState.UserInfo> mUserListData  = new LiveListData<>();
    private boolean                          mIsSeatEnabled = mRoomState.isSeatEnabled.get();
    private String                           mSearchWord    = mViewState.searchUserKeyWord.get();
    private ViewState.UserListType           mUserListType  = mViewState.userListType.get();
    private List<UserState.UserInfo>         mAllUserList   = mUserState.allUsers.getList();
    private List<String>                     mSeatUserList  = mSeatState.seatedUsers.getList();

    private Observer<Boolean> mSeatEnableObserver = new Observer<Boolean>() {
        @Override
        public void onChanged(Boolean isSeatEnable) {
            mIsSeatEnabled = isSeatEnable;
        }
    };

    private Observer<String> mSearchWordObserver = new Observer<String>() {
        @Override
        public void onChanged(String searchWord) {
            mSearchWord = searchWord;
            if (ViewState.UserListType.ALL_USER_NOT_ENTERED_THE_ROOM == mUserListType) {
                notifyNotEnteredUserChanged(mInvitationState.invitationList.getList());
            } else {
                notifyEnteredUserChanged();
            }
        }
    };

    private Observer<ViewState.UserListType> mUserListTypeObserver = new Observer<ViewState.UserListType>() {
        @Override
        public void onChanged(ViewState.UserListType type) {
            mUserListType = type;
            if (ViewState.UserListType.ALL_USER_NOT_ENTERED_THE_ROOM == mUserListType) {
                notifyNotEnteredUserChanged(mInvitationState.invitationList.getList());
            } else {
                notifyEnteredUserChanged();
            }
        }
    };

    private LiveListObserver<UserState.UserInfo> mAllUserObserver = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onDataChanged(List<UserState.UserInfo> list) {
            notifyEnteredUserChanged();
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

    private LiveListObserver<String> mSeatedUserObserver = new LiveListObserver<String>() {
        @Override
        public void onDataChanged(List<String> list) {
            notifyEnteredUserChanged();
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

    private LiveListObserver<InvitationState.Invitation> mInvitationObserver = new LiveListObserver<InvitationState.Invitation>() {
        @Override
        public void onDataChanged(List<InvitationState.Invitation> list) {
            notifyNotEnteredUserChanged(list);
        }

        @Override
        public void onItemInserted(int position, InvitationState.Invitation item) {
            notifyNotEnteredUserInserted(item.invitee);
        }

        @Override
        public void onItemRemoved(int position, InvitationState.Invitation item) {
            notifyNotEnteredUserRemoved(item.invitee);
        }
    };

    public void observe(LiveListObserver<UserState.UserInfo> observer) {
        mUserListData.observe(observer);
        mRoomState.isSeatEnabled.observe(mSeatEnableObserver);
        mViewState.searchUserKeyWord.observe(mSearchWordObserver);
        mViewState.userListType.observe(mUserListTypeObserver);
        mUserState.allUsers.observe(mAllUserObserver);
        mSeatState.seatedUsers.observe(mSeatedUserObserver);
        mInvitationState.invitationList.observe(mInvitationObserver);
    }

    public void removeObserver(LiveListObserver<UserState.UserInfo> observer) {
        mUserListData.removeObserver(observer);
        mRoomState.isSeatEnabled.removeObserver(mSeatEnableObserver);
        mViewState.searchUserKeyWord.removeObserver(mSearchWordObserver);
        mViewState.userListType.removeObserver(mUserListTypeObserver);
        mUserState.allUsers.removeObserver(mAllUserObserver);
        mSeatState.seatedUsers.removeObserver(mSeatedUserObserver);
        mInvitationState.invitationList.removeObserver(mInvitationObserver);
    }

    private void notifyEnteredUserChanged() {
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
        if (ViewState.UserListType.ON_SEAT_INSIDE_THE_ROOM == mUserListType) {
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
        if (ViewState.UserListType.ON_SEAT_INSIDE_THE_ROOM == mUserListType) {
            mUserListData.remove(leftUser);
            return;
        }
        mUserListData.add(leftUser);
    }

    private void notifyNotEnteredUserChanged(List<InvitationState.Invitation> list) {
        if (ViewState.UserListType.ALL_USER_NOT_ENTERED_THE_ROOM != mUserListType) {
            return;
        }
        List<UserState.UserInfo> users = new LinkedList<>();
        for (UserState.UserInfo item : ConferenceController.sharedInstance().getInvitationController().getInviteeListFormInvitationList(list)) {
            if (!item.userName.contains(mSearchWord)) {
                continue;
            }
            users.add(item);
        }
        mUserListData.redirect(users);
    }

    private void notifyNotEnteredUserInserted(UserState.UserInfo userInfo) {
        if (ViewState.UserListType.ALL_USER_NOT_ENTERED_THE_ROOM != mUserListType) {
            return;
        }
        mUserListData.add(userInfo);
    }

    private void notifyNotEnteredUserRemoved(UserState.UserInfo userInfo) {
        if (ViewState.UserListType.ALL_USER_NOT_ENTERED_THE_ROOM != mUserListType) {
            return;
        }
        mUserListData.remove(userInfo);
    }

    private boolean isTargetUser(UserState.UserInfo userInfo) {
        if (!userInfo.userName.contains(mSearchWord)) {
            return false;
        }
        if (ViewState.UserListType.ALL_USER_NOT_ENTERED_THE_ROOM == mUserListType) {
            return false;
        }
        if (!mIsSeatEnabled) {
            return true;
        }
        boolean isSeated = mSeatUserList.contains(userInfo.userId);
        if (ViewState.UserListType.ON_SEAT_INSIDE_THE_ROOM == mUserListType && isSeated) {
            return true;
        }
        return !(ViewState.UserListType.ON_SEAT_INSIDE_THE_ROOM == mUserListType || isSeated);
    }
}
