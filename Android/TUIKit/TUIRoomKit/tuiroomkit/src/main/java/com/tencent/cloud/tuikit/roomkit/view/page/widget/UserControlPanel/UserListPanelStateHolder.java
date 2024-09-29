package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListObserver;
import com.tencent.cloud.tuikit.roomkit.model.data.InvitationState;
import com.tencent.cloud.tuikit.roomkit.model.data.ViewState;
import com.tencent.cloud.tuikit.roomkit.view.StateHolder;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.List;

public class UserListPanelStateHolder extends StateHolder {
    private LiveData<Boolean> mIsNotEnteredType  = new LiveData<>();
    private LiveData<Boolean> mIsShowCallCallBtn = new LiveData<>(false);

    private Observer<ViewState.UserListType> mUserListType = new Observer<ViewState.UserListType>() {
        @Override
        public void onChanged(ViewState.UserListType type) {
            mIsNotEnteredType.set(ViewState.UserListType.ALL_USER_NOT_ENTERED_THE_ROOM == type);
            updateIsShowCallCallBtnState();
        }
    };

    private LiveListObserver<InvitationState.Invitation> mInvitationObserver = new LiveListObserver<InvitationState.Invitation>() {
        @Override
        public void onDataChanged(List<InvitationState.Invitation> list) {
            updateIsShowCallCallBtnState();
        }

        @Override
        public void onItemInserted(int position, InvitationState.Invitation item) {
            updateIsShowCallCallBtnState();
        }

        @Override
        public void onItemRemoved(int position, InvitationState.Invitation item) {
            updateIsShowCallCallBtnState();
        }
    };

    public void observeUserListType(Observer<Boolean> observer) {
        mIsNotEnteredType.observe(observer);
        mViewState.userListType.observe(mUserListType);
    }

    public void removeObserverListType(Observer<Boolean> observer) {
        mIsNotEnteredType.removeObserver(observer);
        mViewState.userListType.removeObserver(mUserListType);
    }

    public void observeCallAllButtonState(Observer<Boolean> observer) {
        mIsShowCallCallBtn.observe(observer);
        mViewState.userListType.observe(mUserListType);
        mInvitationState.invitationList.observe(mInvitationObserver);
    }

    public void removeObserverCallButtonState(Observer<Boolean> observer) {
        mIsShowCallCallBtn.removeObserver(observer);
        mInvitationState.invitationList.removeObserver(mInvitationObserver);
    }

    private void updateIsShowCallCallBtnState() {
        boolean isShow = !mInvitationState.invitationList.getList().isEmpty() && ViewState.UserListType.ALL_USER_NOT_ENTERED_THE_ROOM == mViewState.userListType.get();
        if (mIsShowCallCallBtn.get() == isShow) {
            return;
        }
        mIsShowCallCallBtn.set(isShow);
    }
}
