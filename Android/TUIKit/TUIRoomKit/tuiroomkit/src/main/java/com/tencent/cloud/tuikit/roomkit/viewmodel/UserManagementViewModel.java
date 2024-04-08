package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_SEND_MESSAGE_ABILITY_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant.KEY_USER_POSITION;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel.UserManagementPanel;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.HashMap;
import java.util.Map;

public class UserManagementViewModel implements RoomEventCenter.RoomEngineEventResponder,
        RoomEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "UserManagementViewModel";

    public static final String ACTION_MEDIA_CONTROL = "ACTION_MEDIA_CONTROL";
    public static final String ACTION_OWNER_TRANSFER = "ACTION_OWNER_TRANSFER";
    public static final String ACTION_MANAGER_CONTROL = "ACTION_MANAGER_CONTROL";
    public static final String ACTION_MESSAGE_ENABLE = "ACTION_MESSAGE_ENABLE";
    public static final String ACTION_SEAT_CONTROL = "ACTION_SEAT_CONTROL";
    public static final String ACTION_KICK_OUT_ROOM = "ACTION_KICK_OUT_ROOM";

    private static final int SEAT_INDEX      = -1;
    private static final int INVITE_TIME_OUT = 0;
    private static final int REQ_TIME_OUT    = 15;

    private Context            mContext;
    private RoomStore          mRoomStore;
    private UserEntity          mUser;
    private UserManagementPanel mUserManagementView;

    public UserManagementViewModel(Context context, UserEntity user, UserManagementPanel view) {
        mContext = context;
        mUser = user;
        mUserManagementView = view;
        mRoomStore = RoomEngineManager.sharedInstance().getRoomStore();
        subscribeEvent();
        Log.d(TAG, "UserManagementViewModel new : " + this);
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.subscribeEngine(USER_SEND_MESSAGE_ABILITY_CHANGED, this);
        eventCenter.subscribeEngine(REMOTE_USER_TAKE_SEAT, this);
        eventCenter.subscribeEngine(REMOTE_USER_LEAVE_SEAT, this);
        eventCenter.subscribeEngine(USER_ROLE_CHANGED, this);

        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        unSubscribeEvent();
        Log.d(TAG, "UserManagementViewModel destroy : " + this);
    }

    private void unSubscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(USER_SEND_MESSAGE_ABILITY_CHANGED, this);
        eventCenter.unsubscribeEngine(REMOTE_USER_TAKE_SEAT, this);
        eventCenter.unsubscribeEngine(REMOTE_USER_LEAVE_SEAT, this);
        eventCenter.unsubscribeEngine(USER_ROLE_CHANGED, this);

        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public boolean checkPermission(String action) {
        if (TextUtils.equals(ACTION_MEDIA_CONTROL, action)) {
            return !mRoomStore.roomInfo.isSeatEnabled || mUser.isOnSeat();
        }
        if (TextUtils.equals(ACTION_KICK_OUT_ROOM, action)) {
            return mRoomStore.userModel.getRole() == TUIRoomDefine.Role.ROOM_OWNER;
        }
        TUIRoomDefine.Role localUserRole = RoomEngineManager.sharedInstance().getRoomStore().userModel.getRole();
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
            RoomEngineManager.sharedInstance().disableLocalAudio();
            return;
        }
        RoomEngineManager.sharedInstance().closeRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.MICROPHONE, null);
    }

    private void onUnMuteUserAudio(String userId) {
        if (TextUtils.equals(userId, TUILogin.getUserId())) {
            RoomEngineManager.sharedInstance().enableLocalAudio();
            return;
        }
        RoomEngineManager.sharedInstance()
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
            RoomEngineManager.sharedInstance().closeLocalCamera();
        }
        RoomEngineManager.sharedInstance().closeRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.CAMERA, null);
    }

    private void onUnMuteUserVideo(String userId) {
        if (TextUtils.equals(userId, TUILogin.getUserId())) {
            RoomEngineManager.sharedInstance().openLocalCamera(null);
            return;
        }
        RoomEngineManager.sharedInstance()
                .openRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.CAMERA, REQ_TIME_OUT, null);
    }

    public void forwardMaster(TUIRoomDefine.ActionCallback callback) {
        if (mUser == null) {
            return;
        }
        RoomEngineManager.sharedInstance().changeUserRole(mUser.getUserId(), TUIRoomDefine.Role.ROOM_OWNER, callback);
    }

    public void switchManagerRole(TUIRoomDefine.ActionCallback callback) {
        if (mUser == null) {
            return;
        }
        TUIRoomDefine.Role role = mUser.getRole() == TUIRoomDefine.Role.MANAGER ? TUIRoomDefine.Role.GENERAL_USER :
                TUIRoomDefine.Role.MANAGER;

        RoomEngineManager.sharedInstance().changeUserRole(mUser.getUserId(), role, callback);
    }

    public void switchSendingMessageAbility() {
        if (mUser == null) {
            return;
        }
        RoomEngineManager.sharedInstance()
                .disableSendingMessageByAdmin(mUser.getUserId(), mUser.isEnableSendingMessage(), null);
    }

    public void kickUser(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        RoomEngineManager.sharedInstance().kickRemoteUserOutOfRoom(userId, null);
    }

    public void kickOffStage() {
        if (mUser == null) {
            return;
        }
        if (!isSeatEnable() || !mUser.isOnSeat()) {
            return;
        }
        RoomEngineManager.sharedInstance().kickUserOffSeatByAdmin(SEAT_INDEX, mUser.getUserId(), null);
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
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT, params);
    }


    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
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
        UserEntity changeUser = mRoomStore.allUserList.get(position);
        if (!TextUtils.equals(mUser.getUserId(), changeUser.getUserId()) && !TextUtils.equals(
                mRoomStore.userModel.userId, changeUser.getUserId())) {
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
        if (!TextUtils.equals(mUser.getUserId(), mRoomStore.allUserList.get(position).getUserId())) {
            return;
        }
        mUserManagementView.updateCameraState(mRoomStore.allUserList.get(position).isHasVideoStream());
    }

    private void onUserMicStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        if (!TextUtils.equals(mUser.getUserId(), mRoomStore.allUserList.get(position).getUserId())) {
            return;
        }
        mUserManagementView.updateMicState(mRoomStore.allUserList.get(position).isHasAudioStream());
    }

    private void onUserMuteStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        if (!TextUtils.equals(mUser.getUserId(), mRoomStore.allUserList.get(position).getUserId())) {
            return;
        }
        mUserManagementView.updateMessageEnableState(mRoomStore.allUserList.get(position).isEnableSendingMessage());
    }

    private void onRemoteUserSeatStateChanged(Map<String, Object> params, boolean isOnSeat) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        if (TextUtils.equals(mRoomStore.allUserList.get(position).getUserId(), mUser.getUserId())) {
            mUserManagementView.changeConfiguration(null);
        }
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE.equals(key)
                && params != null && mUserManagementView.isShowing()) {
            Configuration configuration = (Configuration) params.get(RoomEventConstant.KEY_CONFIGURATION);
            mUserManagementView.changeConfiguration(configuration);
        }
    }

    private boolean isSeatEnable() {
        return mRoomStore.roomInfo.isSeatEnabled;
    }

    private boolean hasAbilityToManageUser(UserEntity user) {
        if (mRoomStore.userModel.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
            return true;
        }
        if (mRoomStore.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            return TextUtils.equals(mRoomStore.userModel.userId, user.getUserId());
        }
        if (TextUtils.equals(mRoomStore.userModel.userId, user.getUserId())) {
            return true;
        }
        return user.getRole() == TUIRoomDefine.Role.GENERAL_USER;
    }
}
