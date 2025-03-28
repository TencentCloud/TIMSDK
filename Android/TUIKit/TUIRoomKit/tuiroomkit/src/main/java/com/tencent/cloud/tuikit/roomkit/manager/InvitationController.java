package com.tencent.cloud.tuikit.roomkit.manager;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.ExtensionType.CONFERENCE_INVITATION_MANAGER;
import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.ExtensionType.CONFERENCE_LIST_MANAGER;

import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.extension.TUIConferenceInvitationManager;
import com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.state.InvitationState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class InvitationController extends Controller {
    private static final String TAG = "InvitationController";

    private String getAttendeeListCursor   = "";
    private String getInvitationListCursor = "";

    private static final int INVITE_TIME_OUT_SECONDS = 60;
    private static final int SINGLE_FETCH_COUNT      = 20;

    private final TUIConferenceInvitationManager mConferenceInvitationManager;
    private final InvitationObserver             mObserver;

    public InvitationController(ConferenceState conferenceState, TUIRoomEngine roomEngine) {
        super(conferenceState, roomEngine);
        mConferenceInvitationManager = (TUIConferenceInvitationManager) roomEngine.getExtension(CONFERENCE_INVITATION_MANAGER);
        mObserver = new InvitationObserver();
        mConferenceInvitationManager.addObserver(mObserver);
    }

    public void destroy() {
        mConferenceInvitationManager.removeObserver(mObserver);
    }

    public List<UserState.UserInfo> getInviteeListFormInvitationList(List<InvitationState.Invitation> invitationList) {
        List<UserState.UserInfo> userInfoList = new ArrayList<>();
        for (InvitationState.Invitation invitation : invitationList) {
            userInfoList.add(invitation.invitee);
        }
        return userInfoList;
    }

    public void inviteUsers(List<UserState.UserInfo> userInfoList, TUIConferenceInvitationManager.InviteUsersCallback callback) {
        Log.d(TAG, "inviteUsers");
        if (userInfoList.isEmpty()) {
            return;
        }
        RoomToast.toastShortMessageCenter(TUILogin.getAppContext().getString(R.string.tuiroomkit_invitation_has_been_sent));
        mConferenceInvitationManager.inviteUsers(mRoomState.roomId.get(), getUserIdListFromUserList(userInfoList), INVITE_TIME_OUT_SECONDS, "", new TUIConferenceInvitationManager.InviteUsersCallback() {
            @Override
            public void onSuccess(Map<String, TUIConferenceInvitationManager.InvitationCode> invitationResultMap) {
                Log.d(TAG, "inviteUsers success");
                if (callback != null) {
                    callback.onSuccess(invitationResultMap);
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "inviteUsers error=" + error + " message=" + message);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    private List<String> getUserIdListFromUserList(List<UserState.UserInfo> userInfoList) {
        List<String> userIdList = new ArrayList<>();
        for (UserState.UserInfo userInfo : userInfoList) {
            userIdList.add(userInfo.userId);
        }
        return userIdList;
    }

    public void accept(String roomId, TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "accept");
        mConferenceInvitationManager.accept(roomId, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "accept success");
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "accept error=" + error + " message=" + message);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    public void reject(String roomId, TUIConferenceInvitationManager.RejectedReason reason, TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "reject roomId= " + roomId + " reason=" + reason);
        mConferenceInvitationManager.reject(roomId, reason, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "reject success");
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "reject error=" + error + " message=" + message);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    private void getInvitationList() {
        Log.d(TAG, "getInvitationList");
        mConferenceInvitationManager.getInvitationList(mRoomState.roomId.get(), getAttendeeListCursor, SINGLE_FETCH_COUNT, new TUIConferenceInvitationManager.GetInvitationListCallback() {
            @Override
            public void onSuccess(TUIConferenceInvitationManager.InvitationListResult invitationListResult) {
                Log.d(TAG, "getInvitationList");
                for (TUIConferenceInvitationManager.Invitation invitation : invitationListResult.invitationList) {
                    InvitationState.Invitation invitationState = new InvitationState.Invitation();
                    invitationState.invitee = new UserState.UserInfo(invitation.invitee);
                    invitationState.inviter = new UserState.UserInfo(invitation.inviter);
                    invitationState.invitationStatus = invitation.status;
                    mInvitationState.invitationList.add(invitationState);
                }
                getInvitationListCursor = invitationListResult.cursor;
                if (!"".equals(getInvitationListCursor)) {
                    getInvitationList();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "getInvitationList onError error=" + error + " message=" + message);
            }
        });
    }

    public void initInvitationList() {
        ((TUIConferenceListManager) TUIRoomEngine.sharedInstance().getExtension(CONFERENCE_LIST_MANAGER))
                .fetchAttendeeList(mRoomState.roomId.get(), getAttendeeListCursor, SINGLE_FETCH_COUNT, new TUIConferenceListManager.FetchScheduledAttendeesCallback() {
                    @Override
                    public void onSuccess(TUIConferenceListManager.ScheduledAttendeesResult scheduledAttendeesResult) {
                        Log.d(TAG, "fetchAttendeeList onSuccess");
                        for (TUIRoomDefine.UserInfo attendee : scheduledAttendeesResult.scheduleAttendees) {
                            if (mConferenceState.userState.allUsers.contains(new UserState.UserInfo(attendee))) {
                                continue;
                            }
                            InvitationState.Invitation invitation = new InvitationState.Invitation();
                            invitation.invitee = new UserState.UserInfo(attendee);
                            mInvitationState.invitationList.add(invitation);
                        }
                        getAttendeeListCursor = scheduledAttendeesResult.cursor;
                        if ("".equals(getAttendeeListCursor)) {
                            getInvitationList();
                        } else {
                            initInvitationList();
                        }
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String s) {
                        Log.d(TAG, "fetchAttendeeList onError, error=" + error + "  s=" + s);
                    }
                });
    }

    private class InvitationObserver extends TUIConferenceInvitationManager.Observer {
        @Override
        public void onInvitationHandledByOtherDevice(TUIRoomDefine.RoomInfo roomInfo, boolean accepted) {
            Log.d(TAG, "onInvitationHandledByOtherDevice roomId=" + roomInfo.roomId + " accepted=" + accepted);
            if (mViewState.isInvitationPending.get()) {
                mViewState.isInvitationPending.set(false);
            }
        }

        @Override
        public void onInvitationRevokedByAdmin(TUIRoomDefine.RoomInfo roomInfo, TUIConferenceInvitationManager.Invitation invitation, TUIRoomDefine.UserInfo admin) {
            Log.d(TAG, "onInvitationRevokedByAdmin roomId=" + roomInfo.roomId + " admin=" + admin.userId);
            if (mViewState.isInvitationPending.get()) {
                mViewState.isInvitationPending.set(false);
            }
        }

        @Override
        public void onInvitationTimeout(TUIRoomDefine.RoomInfo roomInfo, TUIConferenceInvitationManager.Invitation invitation) {
            Log.d(TAG, "onInvitationTimeout roomId=" + roomInfo.roomId + " inviterId="
                    + invitation.inviter.userId + " inviteeId=" + invitation.invitee.userId);
            if (mViewState.isInvitationPending.get()) {
                mViewState.isInvitationPending.set(false);
            }
        }

        @Override
        public void onInvitationAdded(String roomId, TUIConferenceInvitationManager.Invitation invitation) {
            Log.d(TAG, "onInvitationAdded roomId=" + roomId + " inviterId=" + invitation.inviter.userId + " inviteeId=" + invitation.invitee.userId);
            InvitationState.Invitation newInvitation = new InvitationState.Invitation(invitation);
            if (mInvitationState.invitationList.contains(newInvitation)) {
                mInvitationState.invitationList.change(newInvitation);
            } else {
                mInvitationState.invitationList.insert(0, newInvitation);
            }
        }

        @Override
        public void onInvitationRemoved(String roomId, TUIConferenceInvitationManager.Invitation invitation) {
            Log.d(TAG, "onInvitationRemoved roomId=" + roomId + " inviterId= " + invitation.inviter.userId + " inviteeId=" + invitation.invitee.userId);
            mInvitationState.invitationList.remove(new InvitationState.Invitation(invitation));
        }

        @Override
        public void onInvitationStatusChanged(String roomId, TUIConferenceInvitationManager.Invitation invitation) {
            Log.d(TAG, "onInvitationStatusChanged roomId=" + roomId + " inviterId=" + invitation.inviter.userId + " inviteeId=" + invitation.invitee.userId);
            InvitationState.Invitation newInvitation = new InvitationState.Invitation(invitation);
            if (mInvitationState.invitationList.contains(newInvitation)) {
                mInvitationState.invitationList.change(newInvitation);
            } else if ((!mUserState.allUsers.contains(newInvitation.invitee))) {
                mInvitationState.invitationList.insert(0, newInvitation);
            }
            if (invitation.invitee.userId.equals(mUserState.selfInfo.get().userId)) {
                mViewState.isInvitationPending.set(invitation.status == TUIConferenceInvitationManager.InvitationStatus.PENDING);
            }
        }
    }

}
