package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT;
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
import com.tencent.cloud.tuikit.roomkit.view.component.UserManagementView;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.Map;

public class UserManagementViewModel implements RoomEventCenter.RoomEngineEventResponder,
        RoomEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "UserManagementViewModel";

    private static final int SEAT_INDEX      = -1;
    private static final int INVITE_TIME_OUT = 0;
    private static final int REQ_TIME_OUT    = 15;

    private Context            mContext;
    private RoomStore          mRoomStore;
    private UserEntity         mUser;
    private UserManagementView mUserManagementView;

    public UserManagementViewModel(Context context, UserEntity user, UserManagementView view) {
        mContext = context;
        mUser = user;
        mUserManagementView = view;
        mRoomStore = RoomEngineManager.sharedInstance().getRoomStore();
        subscribeEvent();
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.subscribeEngine(USER_SEND_MESSAGE_ABILITY_CHANGED, this);
        eventCenter.subscribeEngine(REMOTE_USER_TAKE_SEAT, this);
        eventCenter.subscribeEngine(REMOTE_USER_LEAVE_SEAT, this);

        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void unSubscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(USER_SEND_MESSAGE_ABILITY_CHANGED, this);
        eventCenter.unsubscribeEngine(REMOTE_USER_TAKE_SEAT, this);
        eventCenter.unsubscribeEngine(REMOTE_USER_LEAVE_SEAT, this);

        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public boolean isEnableSeatControl() {
        return isTakeSeatSpeechMode();
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

    private boolean isOwner() {
        return TUIRoomDefine.Role.ROOM_OWNER.equals(mRoomStore.userModel.role);
    }

    private void onMuteUserAudio(String userId) {
        if (TextUtils.equals(userId, TUILogin.getUserId())) {
            RoomEngineManager.sharedInstance().closeLocalMicrophone();
            return;
        }
        if (!isOwner()) {
            return;
        }
        RoomEngineManager.sharedInstance().closeRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.MICROPHONE, null);
    }

    private void onUnMuteUserAudio(String userId) {
        if (TextUtils.equals(userId, TUILogin.getUserId())) {
            RoomEngineManager.sharedInstance().openLocalMicrophone(null);
            return;
        }
        if (!isOwner()) {
            return;
        }
        RoomEngineManager.sharedInstance()
                .openRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.MICROPHONE, REQ_TIME_OUT,
                        new TUIRoomDefine.RequestCallback() {
                            @Override
                            public void onAccepted(String s, String s1) {
                                ToastUtil.toastShortMessageCenter(mContext.getString(
                                        R.string.tuiroomkit_open_mic_agree, mUser.getUserName()));
                            }

                            @Override
                            public void onRejected(String s, String s1, String s2) {
                                ToastUtil.toastShortMessageCenter(mContext.getString(
                                        R.string.tuiroomkit_open_mic_reject, mUser.getUserName()));
                            }

                            @Override
                            public void onCancelled(String s, String s1) {

                            }

                            @Override
                            public void onTimeout(String s, String s1) {

                            }

                            @Override
                            public void onError(String s, String s1, TUICommonDefine.Error error, String s2) {

                            }
                        });
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
        if (!isOwner()) {
            return;
        }
        RoomEngineManager.sharedInstance().closeRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.CAMERA, null);
    }

    private void onUnMuteUserVideo(String userId) {
        if (TextUtils.equals(userId, TUILogin.getUserId())) {
            RoomEngineManager.sharedInstance().openLocalCamera(null);
            return;
        }
        if (!isOwner()) {
            return;
        }
        RoomEngineManager.sharedInstance()
                .openRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.CAMERA, REQ_TIME_OUT,
                        new TUIRoomDefine.RequestCallback() {
                            @Override
                            public void onAccepted(String s, String s1) {
                                ToastUtil.toastShortMessageCenter(mContext.getString(
                                        R.string.tuiroomkit_open_camera_agree, mUser.getUserName()));
                            }

                            @Override
                            public void onRejected(String s, String s1, String s2) {
                                ToastUtil.toastShortMessageCenter(mContext.getString(
                                        R.string.tuiroomkit_open_camera_reject, mUser.getUserName()));
                            }

                            @Override
                            public void onCancelled(String s, String s1) {

                            }

                            @Override
                            public void onTimeout(String s, String s1) {

                            }

                            @Override
                            public void onError(String s, String s1, TUICommonDefine.Error error, String s2) {

                            }
                        });
    }


    public void forwardMaster() {
        if (mUser == null) {
            return;
        }
        RoomEngineManager.sharedInstance()
                .changeUserRole(mUser.getUserId(), TUIRoomDefine.Role.ROOM_OWNER, new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        mUserManagementView.showTransferRoomSuccessDialog();
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String s) {
                        Log.e(TAG, "changeUserRole onError error=" + error + " s=" + s);
                    }
                });
    }

    public void muteUser() {
        if (mUser == null) {
            return;
        }
        RoomEngineManager.sharedInstance()
                .disableSendingMessageByAdmin(mUser.getUserId(), !mUser.isDisableSendingMessage(), null);
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
        if (!isTakeSeatSpeechMode() || !mUser.isOnSeat()) {
            return;
        }
        RoomEngineManager.sharedInstance().kickUserOffSeatByAdmin(SEAT_INDEX, mUser.getUserId(), null);
    }

    public void inviteToStage() {
        if (mUser == null) {
            return;
        }
        if (!isTakeSeatSpeechMode() || mUser.isOnSeat()) {
            return;
        }
        RoomEngineManager.sharedInstance().takeUserOnSeatByAdmin(SEAT_INDEX, mUser.getUserId(), INVITE_TIME_OUT, null);
    }


    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
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
        mUserManagementView.updateMuteState(mRoomStore.allUserList.get(position).isDisableSendingMessage());
    }

    private void onRemoteUserSeatStateChanged(Map<String, Object> params, boolean isOnSeat) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        if (TextUtils.equals(mRoomStore.seatUserList.get(position).getUserId(), TUILogin.getUserId())) {
            mUserManagementView.updateLayout(isOnSeat);
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

    private boolean isTakeSeatSpeechMode() {
        return TUIRoomDefine.SpeechMode.SPEAK_AFTER_TAKING_SEAT.equals(mRoomStore.roomInfo.speechMode);
    }
}
