package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.usermanager;

import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_ROLE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_SEND_MESSAGE_ABILITY_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_USER_POSITION;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.HashMap;
import java.util.Map;

public class UserManagementViewModel implements ConferenceEventCenter.RoomEngineEventResponder,
        ConferenceEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "UserManagementViewModel";

    public static final String ACTION_MEDIA_CONTROL   = "ACTION_MEDIA_CONTROL";
    public static final String ACTION_OWNER_TRANSFER  = "ACTION_OWNER_TRANSFER";
    public static final String ACTION_MANAGER_CONTROL = "ACTION_MANAGER_CONTROL";
    public static final String ACTION_MESSAGE_ENABLE  = "ACTION_MESSAGE_ENABLE";
    public static final String ACTION_SEAT_CONTROL    = "ACTION_SEAT_CONTROL";
    public static final String ACTION_KICK_OUT_ROOM   = "ACTION_KICK_OUT_ROOM";

    private static final int SEAT_INDEX      = -1;
    private static final int INVITE_TIME_OUT = 0;
    private static final int REQ_TIME_OUT    = 15;

    private Context             mContext;
    private ConferenceState     mConferenceState;
    private UserEntity          mUser;
    private UserManagementPanel mUserManagementView;

    public UserManagementViewModel(Context context, UserEntity user, UserManagementPanel view) {
        mContext = context;
        mUser = user;
        mUserManagementView = view;
        mConferenceState = ConferenceController.sharedInstance().getConferenceState();
        subscribeEvent();
        Log.d(TAG, "UserManagementViewModel new : " + this);
    }

    private void subscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.subscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.subscribeEngine(USER_SEND_MESSAGE_ABILITY_CHANGED, this);
        eventCenter.subscribeEngine(REMOTE_USER_TAKE_SEAT, this);
        eventCenter.subscribeEngine(REMOTE_USER_LEAVE_SEAT, this);
        eventCenter.subscribeEngine(USER_ROLE_CHANGED, this);

        eventCenter.subscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        unSubscribeEvent();
        Log.d(TAG, "UserManagementViewModel destroy : " + this);
    }

    private void unSubscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(ConferenceEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(USER_SEND_MESSAGE_ABILITY_CHANGED, this);
        eventCenter.unsubscribeEngine(REMOTE_USER_TAKE_SEAT, this);
        eventCenter.unsubscribeEngine(REMOTE_USER_LEAVE_SEAT, this);
        eventCenter.unsubscribeEngine(USER_ROLE_CHANGED, this);

        eventCenter.unsubscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public boolean checkPermission(String action) {
        UserState.UserInfo localUser = ConferenceController.sharedInstance().getUserState().selfInfo.get();
        if (TextUtils.equals(localUser.userId, mUser.getUserId())) {
            return false;
        }
        if (TextUtils.equals(ACTION_MEDIA_CONTROL, action)) {
            return !mConferenceState.roomInfo.isSeatEnabled || mUser.isOnSeat();
        }
        if (TextUtils.equals(ACTION_KICK_OUT_ROOM, action)) {
            return mConferenceState.userModel.getRole() == TUIRoomDefine.Role.ROOM_OWNER;
        }
        TUIRoomDefine.Role localUserRole = localUser.role.get();
        TUIRoomDefine.Role userRole = mUser.getRole();
        if (localUserRole == TUIRoomDefine.Role.ROOM_OWNER) {
            return true;
        }
        if (localUserRole == TUIRoomDefine.Role.GENERAL_USER) {
            return false;
        }

        if (userRole == TUIRoomDefine.Role.ROOM_OWNER) {
            return false;
        }
        if (userRole == TUIRoomDefine.Role.GENERAL_USER) {
            return action != ACTION_OWNER_TRANSFER && action != ACTION_MANAGER_CONTROL;
        }
        return action == ACTION_MESSAGE_ENABLE || action == ACTION_SEAT_CONTROL;
    }

    public boolean isEnableSeatControl() {
        return isSeatEnable();
    }

    public boolean isSelf() {
        return TextUtils.equals(TUILogin.getUserId(), mUser.getUserId());
    }

    public void muteUserAudio() {
        if (mUser.isHasAudioStream()) {
            onMuteUserAudio(mUser.getUserId());
        } else {
            onUnMuteUserAudio(mUser.getUserId());
        }
    }

    private void onMuteUserAudio(String userId) {
        if (TextUtils.equals(userId, TUILogin.getUserId())) {
            ConferenceController.sharedInstance().disableLocalAudio();
            return;
        }
        ConferenceController.sharedInstance().closeRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.MICROPHONE, null);
    }

    private void onUnMuteUserAudio(String userId) {
        if (TextUtils.equals(userId, TUILogin.getUserId())) {
            ConferenceController.sharedInstance().enableLocalAudio();
            return;
        }
        ConferenceController.sharedInstance()
                .openRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.MICROPHONE, REQ_TIME_OUT, null);
    }


    public void muteUserVideo() {
        if (mUser.isHasVideoStream()) {
            onMuteUserVideo(mUser.getUserId());
        } else {
            onUnMuteUserVideo(mUser.getUserId());
        }
    }

    private void onMuteUserVideo(String userId) {
        if (TextUtils.equals(userId, TUILogin.getUserId())) {
            ConferenceController.sharedInstance().closeLocalCamera();
        }
        ConferenceController.sharedInstance().closeRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.CAMERA, null);
    }

    private void onUnMuteUserVideo(String userId) {
        if (TextUtils.equals(userId, TUILogin.getUserId())) {
            ConferenceController.sharedInstance().openLocalCamera(null);
            return;
        }
        ConferenceController.sharedInstance()
                .openRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.CAMERA, REQ_TIME_OUT, null);
    }

    public void forwardMaster(TUIRoomDefine.ActionCallback callback) {
        if (mUser == null) {
            return;
        }
        ConferenceController.sharedInstance().changeUserRole(mUser.getUserId(), TUIRoomDefine.Role.ROOM_OWNER, callback);
    }

    public void switchManagerRole(TUIRoomDefine.ActionCallback callback) {
        if (mUser == null) {
            return;
        }
        TUIRoomDefine.Role role = mUser.getRole() == TUIRoomDefine.Role.MANAGER ? TUIRoomDefine.Role.GENERAL_USER :
                TUIRoomDefine.Role.MANAGER;

        ConferenceController.sharedInstance().changeUserRole(mUser.getUserId(), role, callback);
    }

    public void stopScreenShareAfterManagerRemove() {
        String sharingUserId = mConferenceState.userState.screenStreamUser.get();
        if (TextUtils.isEmpty(sharingUserId)) {
            return;
        }
        if (TextUtils.equals(sharingUserId, mUser.getUserId())) {
            ConferenceController.sharedInstance().closeRemoteDeviceByAdmin(sharingUserId, TUIRoomDefine.MediaDevice.SCREEN_SHARING, null);
        }
    }

    public void stopScreenShareAfterTransferOwner() {
        String sharingUserId = mConferenceState.userState.screenStreamUser.get();
        if (TextUtils.isEmpty(sharingUserId)) {
            return;
        }
        if (TextUtils.equals(sharingUserId, mConferenceState.userModel.userId)) {
            ConferenceController.sharedInstance().stopScreenCapture();
        }
    }

    public boolean isDisableScreenShare() {
        return mConferenceState.roomState.isDisableScreen.get();
    }

    public void switchSendingMessageAbility() {
        if (mUser == null) {
            return;
        }
        ConferenceController.sharedInstance()
                .disableSendingMessageByAdmin(mUser.getUserId(), mUser.isEnableSendingMessage(), null);
    }

    public void kickUser(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        ConferenceController.sharedInstance().kickRemoteUserOutOfRoom(userId, null);
    }

    public void kickOffStage() {
        if (mUser == null) {
            return;
        }
        if (!isSeatEnable() || !mUser.isOnSeat()) {
            return;
        }
        ConferenceController.sharedInstance().kickUserOffSeatByAdmin(SEAT_INDEX, mUser.getUserId(), null);
    }

    public void inviteToStage() {
        if (mUser == null) {
            return;
        }
        if (!isSeatEnable() || mUser.isOnSeat()) {
            return;
        }
        Map<String, Object> params = new HashMap<>();
        params.put("userId", mUser.getUserId());
        ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT, params);
    }


    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case USER_ROLE_CHANGED:
                onUserRoleChanged(params);
                break;

            case USER_CAMERA_STATE_CHANGED:
                onUserCameraStateChanged(params);
                break;
            case USER_MIC_STATE_CHANGED:
                onUserMicStateChanged(params);
                break;
            case USER_SEND_MESSAGE_ABILITY_CHANGED:
                onUserMuteStateChanged(params);
                break;

            case REMOTE_USER_TAKE_SEAT:
                onRemoteUserSeatStateChanged(params, true);
                break;

            case REMOTE_USER_LEAVE_SEAT:
                onRemoteUserSeatStateChanged(params, false);
                break;
            default:
                break;
        }
    }

    private void onUserRoleChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        UserEntity changeUser = mConferenceState.allUserList.get(position);
        if (!TextUtils.equals(mUser.getUserId(), changeUser.getUserId()) && !TextUtils.equals(
                mConferenceState.userModel.userId, changeUser.getUserId())) {
            return;
        }
        if (!hasAbilityToManageUser(mUser)) {
            mUserManagementView.dismiss();
            return;
        }
        mUserManagementView.changeConfiguration(null);
    }

    private void onUserCameraStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        if (!TextUtils.equals(mUser.getUserId(), mConferenceState.allUserList.get(position).getUserId())) {
            return;
        }
        mUserManagementView.updateCameraState(mConferenceState.allUserList.get(position).isHasVideoStream());
    }

    private void onUserMicStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        if (!TextUtils.equals(mUser.getUserId(), mConferenceState.allUserList.get(position).getUserId())) {
            return;
        }
        mUserManagementView.updateMicState(mConferenceState.allUserList.get(position).isHasAudioStream());
    }

    private void onUserMuteStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        if (!TextUtils.equals(mUser.getUserId(), mConferenceState.allUserList.get(position).getUserId())) {
            return;
        }
        mUserManagementView.updateMessageEnableState(mConferenceState.allUserList.get(position).isEnableSendingMessage());
    }

    private void onRemoteUserSeatStateChanged(Map<String, Object> params, boolean isOnSeat) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        if (TextUtils.equals(mConferenceState.allUserList.get(position).getUserId(), mUser.getUserId())) {
            mUserManagementView.changeConfiguration(null);
        }
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE.equals(key)
                && params != null && mUserManagementView.isShowing()) {
            Configuration configuration = (Configuration) params.get(ConferenceEventConstant.KEY_CONFIGURATION);
            mUserManagementView.changeConfiguration(configuration);
        }
    }

    private boolean isSeatEnable() {
        return mConferenceState.roomInfo.isSeatEnabled;
    }

    private boolean hasAbilityToManageUser(UserEntity user) {
        if (mConferenceState.userModel.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
            return true;
        }
        if (mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            return TextUtils.equals(mConferenceState.userModel.userId, user.getUserId());
        }
        if (TextUtils.equals(mConferenceState.userModel.userId, user.getUserId())) {
            return true;
        }
        return user.getRole() == TUIRoomDefine.Role.GENERAL_USER;
    }
}
