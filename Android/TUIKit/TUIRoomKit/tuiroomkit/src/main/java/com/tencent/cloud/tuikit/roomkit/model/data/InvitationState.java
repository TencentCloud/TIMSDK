package com.tencent.cloud.tuikit.roomkit.model.data;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.extension.TUIConferenceInvitationManager;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListData;
import com.trtc.tuikit.common.livedata.LiveData;


public class InvitationState {
    public LiveListData<Invitation> invitationList = new LiveListData<>();

    public void remoteUserEnterRoom(TUIRoomDefine.UserInfo userInfo) {
        InvitationState.Invitation invitation = new InvitationState.Invitation();
        invitation.invitee = new UserState.UserInfo(userInfo);
        invitationList.remove(invitation);
    }

    public static class Invitation {
        public TUIConferenceInvitationManager.InvitationStatus invitationStatus;
        public UserState.UserInfo                              inviter;
        public UserState.UserInfo                              invitee;

        public Invitation() {
            this.invitationStatus = TUIConferenceInvitationManager.InvitationStatus.NONE;
        }

        public Invitation(TUIConferenceInvitationManager.Invitation invitation) {
            this.invitationStatus = invitation.status;
            this.inviter = new UserState.UserInfo(invitation.inviter);
            this.invitee = new UserState.UserInfo(invitation.invitee);
        }

        public void updateStatus(TUIConferenceInvitationManager.InvitationStatus status) {
            this.invitationStatus = status;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            Invitation that = (Invitation) o;
            return TextUtils.equals(invitee.userId, that.invitee.userId);
        }
    }
}
