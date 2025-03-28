package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel;

import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.IN_ROOM;
import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.OFF_SEAT;
import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.ON_SEAT;
import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.OUT_ROOM;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.roomkit.state.InvitationState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.state.ViewState;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem.UserListComparator;
import com.trtc.tuikit.common.livedata.LiveListData;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

public class UserRecyclerViewStateHolder extends StateHolder {
    private static final String TAG = "UserRVStateHolder";

    private final LiveListData<UserState.UserInfo> mSelectedUserList   = new LiveListData<>();
    private final UserListComparator               mUserListComparator = new UserListComparator();

    private       boolean                  mIsSeatEnabled        = mRoomState.isSeatEnabled.get();
    private       String                   mSearchWord           = mViewState.searchUserKeyWord.get();
    private       ViewState.UserListType   mSelectedUserListType = mViewState.userListType.get();
    private final List<UserState.UserInfo> mAllUserList          = mUserState.allUsers.getList();
    private final List<String>             mSeatUserList         = mSeatState.seatedUsers.getList();
    private       String                   mScreenShareUserId    = mUserState.screenStreamUser.get();

    private final Observer<Boolean>                            mSeatEnableObserver   = this::updateSeatEnableState;
    private final Observer<ViewState.UserListType>             mUserListTypeObserver = this::updateUserListType;
    private final Observer<String>                             mSearchWordObserver   = this::updateSearchList;
    private final LiveListObserver<UserState.UserInfo>         mAllUserObserver      = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onItemChanged(int position, UserState.UserInfo item) {
            mSelectedUserList.move(item, mUserListComparator);
        }

        @Override
        public void onItemInserted(int position, UserState.UserInfo item) {
            notifyInRoomUserInserted(item);
        }

        @Override
        public void onItemRemoved(int position, UserState.UserInfo item) {
            notifyInRoomUserRemoved(item);
        }
    };
    private final LiveListObserver<String>                     mSeatedUserObserver = new LiveListObserver<String>() {
        @Override
        public void onItemInserted(int position, String item) {
            notifySeatUserInserted(item);
        }

        @Override
        public void onItemRemoved(int position, String item) {
            notifySeatUserRemoved(item);
        }
    };
    private final LiveListObserver<InvitationState.Invitation> mInvitationObserver = new LiveListObserver<InvitationState.Invitation>() {
        @Override
        public void onItemInserted(int position, InvitationState.Invitation item) {
            notifyOutRoomUserInserted(item.invitee);
        }

        @Override
        public void onItemRemoved(int position, InvitationState.Invitation item) {
            notifyOutRoomUserRemoved(item.invitee);
        }
    };
    private final LiveListObserver<String>                     mAudiosObserver       = new LiveListObserver<String>() {
        @Override
        public void onItemInserted(int position, String item) {
            notifyUserMediaStateChanged(item);
        }

        @Override
        public void onItemRemoved(int position, String item) {
            notifyUserMediaStateChanged(item);
        }
    };
    private final LiveListObserver<String>                     mCamerasObserver      = new LiveListObserver<String>() {
        @Override
        public void onItemInserted(int position, String item) {
            notifyUserMediaStateChanged(item);
        }

        @Override
        public void onItemRemoved(int position, String item) {
            notifyUserMediaStateChanged(item);
        }
    };
    private final Observer<String>                             mScreenObserver       = new Observer<String>() {
        @Override
        public void onChanged(String screenShareId) {
            if (!TextUtils.isEmpty(screenShareId)) {
                mScreenShareUserId = screenShareId;
                notifyUserMediaStateChanged(screenShareId);
                return;
            }
            if (!TextUtils.isEmpty(mScreenShareUserId)) {
                notifyUserMediaStateChanged(mScreenShareUserId);
            }
            mScreenShareUserId = "";
        }
    };

    public void observe(LiveListObserver<UserState.UserInfo> observer) {
        mSelectedUserList.observe(observer);
        mRoomState.isSeatEnabled.observe(mSeatEnableObserver);
        mViewState.searchUserKeyWord.observe(mSearchWordObserver);
        mViewState.userListType.observe(mUserListTypeObserver);
        mUserState.allUsers.observe(mAllUserObserver);
        mSeatState.seatedUsers.observe(mSeatedUserObserver);
        mInvitationState.invitationList.observe(mInvitationObserver);
        mUserState.hasAudioStreamUsers.observe(mAudiosObserver);
        mUserState.hasCameraStreamUsers.observe(mCamerasObserver);
        mUserState.screenStreamUser.observe(mScreenObserver);
    }

    public void removeObserver(LiveListObserver<UserState.UserInfo> observer) {
        mSelectedUserList.removeObserver(observer);
        mRoomState.isSeatEnabled.removeObserver(mSeatEnableObserver);
        mViewState.searchUserKeyWord.removeObserver(mSearchWordObserver);
        mViewState.userListType.removeObserver(mUserListTypeObserver);
        mUserState.allUsers.removeObserver(mAllUserObserver);
        mSeatState.seatedUsers.removeObserver(mSeatedUserObserver);
        mInvitationState.invitationList.removeObserver(mInvitationObserver);
        mUserState.hasAudioStreamUsers.removeObserver(mAudiosObserver);
        mUserState.hasCameraStreamUsers.removeObserver(mCamerasObserver);
        mUserState.screenStreamUser.removeObserver(mScreenObserver);
    }

    private void updateSeatEnableState(boolean isEnable) {
        if (mIsSeatEnabled == isEnable) {
            return;
        }
        mIsSeatEnabled = isEnable;
        mViewState.userListType.set(isEnable ? ON_SEAT : IN_ROOM);
    }

    private void updateUserListType(ViewState.UserListType type) {
        mSelectedUserListType = type;
        notifyDataSourceChanged();
    }

    private void updateSearchList(String searchWord) {
        if (TextUtils.equals(mSearchWord, searchWord)) {
            return;
        }
        mSearchWord = searchWord;
        notifyDataSourceChanged();
    }

    private void notifyDataSourceChanged() {
        List<UserState.UserInfo> userList = filterUserSource();
        Collections.sort(userList, mUserListComparator);
        mSelectedUserList.redirect(userList);
    }

    private void notifyInRoomUserInserted(UserState.UserInfo user) {
        if (mSelectedUserListType != IN_ROOM && mSelectedUserListType != OFF_SEAT) {
            return;
        }
        mSelectedUserList.insert(user, mUserListComparator);
    }

    private void notifyInRoomUserRemoved(UserState.UserInfo user) {
        if (mSelectedUserListType != IN_ROOM && mSelectedUserListType != OFF_SEAT) {
            return;
        }
        mSelectedUserList.remove(user);
    }

    private void notifySeatUserInserted(String userId) {
        if (mSelectedUserListType == ON_SEAT) {
            mSelectedUserList.insert(mUserState.allUsers.find(new UserState.UserInfo(userId)), mUserListComparator);
            return;
        }
        if (mSelectedUserListType == OFF_SEAT) {
            mSelectedUserList.remove(new UserState.UserInfo(userId));
        }
    }

    private void notifySeatUserRemoved(String userId) {
        if (mSelectedUserListType == ON_SEAT) {
            mSelectedUserList.remove(new UserState.UserInfo(userId));
            return;
        }
        if (mSelectedUserListType == OFF_SEAT) {
            mSelectedUserList.insert(mUserState.allUsers.find(new UserState.UserInfo(userId)), mUserListComparator);
        }
    }

    private void notifyOutRoomUserInserted(UserState.UserInfo user) {
        if (mSelectedUserListType != OUT_ROOM) {
            return;
        }
        mSelectedUserList.insert(user, mUserListComparator);
    }

    private void notifyOutRoomUserRemoved(UserState.UserInfo user) {
        if (mSelectedUserListType != OUT_ROOM) {
            return;
        }
        mSelectedUserList.remove(user);
    }

    private void notifyUserMediaStateChanged(String userId) {
        if (mSelectedUserListType != IN_ROOM && mSelectedUserListType != ON_SEAT) {
            return;
        }
        UserState.UserInfo user = mUserState.allUsers.find(new UserState.UserInfo(userId));
        mSelectedUserList.move(user, mUserListComparator);
    }

    private List<UserState.UserInfo> filterUserSource() {
        List<UserState.UserInfo> userList = new LinkedList<>();
        switch (mSelectedUserListType) {
            case IN_ROOM:
                userList = filterUserInRoom();
                break;

            case ON_SEAT:
                userList = filterUserOnSeat();
                break;

            case OFF_SEAT:
                userList = filterUserOffSeat();
                break;

            case OUT_ROOM:
                userList = filterUserOutRoom();
                break;

            default:
                Log.w(TAG, "notifyDataSourceChanged un handle : " + mSelectedUserListType);
                break;
        }
        return userList;
    }

    private List<UserState.UserInfo> filterUserInRoom() {
        List<UserState.UserInfo> userList = new LinkedList<>();
        for (UserState.UserInfo user : mAllUserList) {
            if (isContainsSearchWord(user.userName)) {
                userList.add(user);
            }
        }
        return userList;
    }

    private List<UserState.UserInfo> filterUserOnSeat() {
        List<UserState.UserInfo> userList = new LinkedList<>();
        for (UserState.UserInfo user : mAllUserList) {
            if (!mSeatUserList.contains(user.userId)) {
                continue;
            }
            if (!isContainsSearchWord(user.userName)) {
                continue;
            }
            userList.add(user);
        }
        return userList;
    }

    private List<UserState.UserInfo> filterUserOffSeat() {
        List<UserState.UserInfo> userList = new LinkedList<>();
        for (UserState.UserInfo user : mAllUserList) {
            if (mSeatUserList.contains(user.userId)) {
                continue;
            }
            if (!isContainsSearchWord(user.userName)) {
                continue;
            }
            userList.add(user);
        }
        return userList;
    }

    private List<UserState.UserInfo> filterUserOutRoom() {
        List<UserState.UserInfo> userList = new LinkedList<>();
        List<InvitationState.Invitation> invitationList = mInvitationState.invitationList.getList();
        for (InvitationState.Invitation invitation : invitationList) {
            if (!isContainsSearchWord(invitation.invitee.userName)) {
                continue;
            }
            userList.add(invitation.invitee);
        }
        return userList;
    }

    private boolean isContainsSearchWord(String text) {
        return !TextUtils.isEmpty(text) && text.contains(mSearchWord);
    }
}
