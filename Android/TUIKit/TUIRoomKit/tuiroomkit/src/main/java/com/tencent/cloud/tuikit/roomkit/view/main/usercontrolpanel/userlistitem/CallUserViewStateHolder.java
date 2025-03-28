package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem;

import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.OUT_ROOM;

import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.extension.TUIConferenceInvitationManager;
import com.tencent.cloud.tuikit.roomkit.state.InvitationState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.state.ViewState;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class CallUserViewStateHolder extends StateHolder {
    private static final int NOT_ENTERED_DISMISS_DELAY_MS = 3000;

    private String            mUserId             = "";
    private LiveData<Boolean> mIsShow             = new LiveData<>();
    private LiveData<Boolean> mIsCalling          = new LiveData<>();
    private LiveData<Boolean> mIsNotEnteredForNow = new LiveData<>();
    private Handler           mMainHandler;

    private Observer<ViewState.UserListType> mUserListType = new Observer<ViewState.UserListType>() {
        @Override
        public void onChanged(ViewState.UserListType type) {
            mIsShow.set(OUT_ROOM == type);
        }
    };

    private LiveListObserver<InvitationState.Invitation> mInvitationObserver = new LiveListObserver<InvitationState.Invitation>() {
        @Override
        public void onDataChanged(List<InvitationState.Invitation> list) {
            for (InvitationState.Invitation invitation : list) {
                updateIsCallingState(invitation);
                updateNotEnteredForNowState(invitation);
            }
        }

        @Override
        public void onItemChanged(int position, InvitationState.Invitation item) {
            updateIsCallingState(item);
            updateNotEnteredForNowState(item);
        }

        @Override
        public void onItemInserted(int position, InvitationState.Invitation item) {
            updateIsCallingState(item);
            updateNotEnteredForNowState(item);
        }

        @Override
        public void onItemRemoved(int position, InvitationState.Invitation item) {
            updateIsCallingState(item);
            updateNotEnteredForNowState(item);
        }

        @Override
        public void onItemMoved(int fromPosition, int toPosition, InvitationState.Invitation item) {
            updateIsCallingState(item);
            updateNotEnteredForNowState(item);
        }
    };

    public CallUserViewStateHolder() {
        mMainHandler = new Handler(Looper.getMainLooper());
        mViewState.userListType.observe(mUserListType);
        mInvitationState.invitationList.observe(mInvitationObserver);
    }

    public void setUserId(String userId) {
        mUserId = userId;
    }

    public String getUserId() {
        return mUserId;
    }

    public boolean getDefaultCallingState() {
        if (TextUtils.isEmpty(mUserId)) {
            return false;
        }
        InvitationState.Invitation invitation = new InvitationState.Invitation();
        invitation.invitee = new UserState.UserInfo(mUserId);
        InvitationState.Invitation resultInvitation = mInvitationState.invitationList.find(invitation);
        if (resultInvitation == null) {
            return false;
        }
        return resultInvitation.invitationStatus == TUIConferenceInvitationManager.InvitationStatus.PENDING;
    }

    public void destroy() {
        mViewState.userListType.removeObserver(mUserListType);
        mInvitationState.invitationList.removeObserver(mInvitationObserver);
    }

    public void observeIsCalling(Observer<Boolean> observer) {
        mIsCalling.observe(observer);
    }

    public void removeIsCallingObserver(Observer<Boolean> observer) {
        mIsCalling.removeObserver(observer);
    }

    public void observeIsShow(Observer<Boolean> observer) {
        mIsShow.observe(observer);
    }

    public void removeIsShowObserver(Observer<Boolean> observer) {
        mIsShow.removeObserver(observer);
    }

    public void observeIsNotEnteredForNowShow(Observer<Boolean> observer) {
        mIsNotEnteredForNow.observe(observer);
    }

    public void removeIsNotEnteredForNowShowObserver(Observer<Boolean> observer) {
        mIsNotEnteredForNow.removeObserver(observer);
    }

    private void updateIsCallingState(InvitationState.Invitation invitation) {
        if (!invitation.invitee.userId.equals(mUserId)) {
            return;
        }

        mIsCalling.set(invitation.invitationStatus == TUIConferenceInvitationManager.InvitationStatus.PENDING);
    }

    private void updateNotEnteredForNowState(InvitationState.Invitation invitation) {
        if (!invitation.invitee.userId.equals(mUserId)) {
            return;
        }
        mMainHandler.removeCallbacksAndMessages(null);
        boolean isShow = invitation.invitationStatus == TUIConferenceInvitationManager.InvitationStatus.REJECTED;
        mIsNotEnteredForNow.set(isShow);
        if (isShow) {
            mMainHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    mIsNotEnteredForNow.set(false);
                    mMainHandler.removeCallbacksAndMessages(null);
                }
            }, NOT_ENTERED_DISMISS_DELAY_MS);
        }
    }
}
