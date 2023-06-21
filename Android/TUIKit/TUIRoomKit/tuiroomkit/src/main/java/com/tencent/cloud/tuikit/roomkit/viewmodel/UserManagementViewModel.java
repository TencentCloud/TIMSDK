package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.UserManagementView;

import java.util.List;
import java.util.Map;

public class UserManagementViewModel implements RoomEventCenter.RoomEngineEventResponder,
        RoomEventCenter.RoomKitUIEventResponder {
    private static final int SEAT_INDEX      = -1;
    private static final int INVITE_TIME_OUT = 0;
    private static final int REQ_TIME_OUT    = 15;

    private RoomStore          mRoomStore;
    private UserModel          mUserModel;
    private TUIRoomEngine      mRoomEngine;
    private UserManagementView mUserManagementView;

    public UserManagementViewModel(Context context, UserModel userModel, UserManagementView view) {
        mUserModel = userModel;
        mUserManagementView = view;
        RoomEngineManager engineManager = RoomEngineManager.sharedInstance(context);
        mRoomEngine = engineManager.getRoomEngine();
        mRoomStore = engineManager.getRoomStore();
        subscribeEvent();
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_AUDIO_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_USER_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.SEAT_LIST_CHANGED, this);

        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void unSubscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_AUDIO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_USER_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.SEAT_LIST_CHANGED, this);

        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public boolean isEnableSeatControl() {
        return isTakeSeatSpeechMode();
    }

    public boolean isSelf() {
        return mRoomStore.userModel.userId.equals(mUserModel.userId);
    }

    public void muteUserAudio() {
        if (mUserModel.isAudioAvailable) {
            onMuteUserAudio(mUserModel.userId);
        } else {
            onUnMuteUserAudio(mUserModel.userId);
        }
    }

    private boolean isOwner() {
        return TUIRoomDefine.Role.ROOM_OWNER.equals(mRoomStore.userModel.role);
    }

    private void onMuteUserAudio(String userId) {
        if (userId.equals(mRoomStore.userModel.userId)) {
            mRoomEngine.stopPushLocalAudio();
            mRoomEngine.closeLocalMicrophone();
            return;
        }
        if (!isOwner()) {
            return;
        }
        mRoomEngine.closeRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.MICROPHONE, null);
    }

    private void onUnMuteUserAudio(String userId) {
        if (userId.equals(mRoomStore.userModel.userId)) {
            mRoomEngine.openLocalMicrophone(TUIRoomDefine.AudioQuality.DEFAULT, null);
            mRoomEngine.startPushLocalAudio();
            return;
        }
        if (!isOwner()) {
            return;
        }
        mRoomEngine.openRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.MICROPHONE, REQ_TIME_OUT, null);
    }


    public void muteUserVideo() {
        if (mUserModel.isVideoAvailable) {
            onMuteUserVideo(mUserModel.userId);
        } else {
            onUnMuteUserVideo(mUserModel.userId);
        }
    }

    private void onMuteUserVideo(String userId) {
        if (userId.equals(mRoomStore.userModel.userId)) {
            mRoomEngine.stopPushLocalVideo();
            mRoomEngine.closeLocalCamera();
            return;
        }
        if (!isOwner()) {
            return;
        }
        mRoomEngine.closeRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.CAMERA, null);
        ;
    }

    private void onUnMuteUserVideo(String userId) {
        if (userId.equals(mRoomStore.userModel.userId)) {
            mRoomEngine.openLocalCamera(true, TUIRoomDefine.VideoQuality.Q_1080P, null);
            mRoomEngine.startPushLocalVideo();
            return;
        }
        if (!isOwner()) {
            return;
        }
        mRoomEngine.openRemoteDeviceByAdmin(userId, TUIRoomDefine.MediaDevice.CAMERA, REQ_TIME_OUT, null);
    }


    public void forwardMaster() {
        if (mUserModel == null) {
            return;
        }
        mRoomEngine.changeUserRole(mUserModel.userId, TUIRoomDefine.Role.ROOM_OWNER, null);
    }

    public void muteUser() {
        if (mUserModel == null) {
            return;
        }
        if (!mUserModel.isMute) {
            mRoomEngine.disableSendingMessageByAdmin(mUserModel.userId, true, null);
        } else {
            mRoomEngine.disableSendingMessageByAdmin(mUserModel.userId, false, null);
        }
        mUserModel.isMute = !mUserModel.isMute;
    }

    public void kickUser(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        mRoomEngine.kickRemoteUserOutOfRoom(userId, null);
    }

    public void kickOffStage() {
        if (mUserModel == null) {
            return;
        }
        if (!isTakeSeatSpeechMode() || !mUserModel.isOnSeat) {
            return;
        }
        mRoomEngine.kickUserOffSeatByAdmin(SEAT_INDEX, mUserModel.userId, null);
    }

    public void inviteToStage() {
        if (mUserModel == null) {
            return;
        }
        if (!isTakeSeatSpeechMode() || mUserModel.isOnSeat) {
            return;
        }
        mRoomEngine.takeUserOnSeatByAdmin(SEAT_INDEX, mUserModel.userId, INVITE_TIME_OUT, null);
    }


    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case USER_VIDEO_STATE_CHANGED:
                onUserVideoStateChanged(params);
                break;
            case USER_AUDIO_STATE_CHANGED:
                onUserAudioStateChanged(params);
                break;
            case SEND_MESSAGE_FOR_USER_DISABLE_CHANGED:
                onUserMuteStateChanged(params);
                break;
            case SEAT_LIST_CHANGED:
                onSeatListChanged(params);
                break;
            default:
                break;
        }
    }

    private void onUserVideoStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        String userId = (String) params.get("userId");
        if (TextUtils.isEmpty(userId) || !userId.equals(mUserModel.userId)) {
            return;
        }
        mUserModel.isVideoAvailable = (boolean) params.get("hasVideo");
        mUserManagementView.updateCameraState(mUserModel.isVideoAvailable);
    }

    private void onUserAudioStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        String userId = (String) params.get("userId");
        if (TextUtils.isEmpty(userId) || !userId.equals(mUserModel.userId)) {
            return;
        }
        mUserModel.isAudioAvailable = (boolean) params.get("hasAudio");
        mUserManagementView.updateMicState(mUserModel.isAudioAvailable);
    }

    private void onUserMuteStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        String userId = (String) params.get("userId");
        if (TextUtils.isEmpty(userId) || !userId.equals(mUserModel.userId)) {
            return;
        }
        mUserModel.isMute = (boolean) params.get("muted");
        mUserManagementView.updateMuteState(!mUserModel.isMute);
    }

    private void onSeatListChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        if (!isTakeSeatSpeechMode()) {
            return;
        }
        List<TUIRoomDefine.SeatInfo> userSeatedList = (List<TUIRoomDefine.SeatInfo>) params.get("seatedList");

        if (userSeatedList != null && !userSeatedList.isEmpty()) {
            for (TUIRoomDefine.SeatInfo info :
                    userSeatedList) {
                if (info.userId.equals(mUserModel.userId)) {
                    mUserManagementView.updateLayout(true);
                }
            }
        }

        List<TUIRoomDefine.SeatInfo> userLeftList = (List<TUIRoomDefine.SeatInfo>) params.get("leftList");
        if (userLeftList != null && !userLeftList.isEmpty()) {
            for (TUIRoomDefine.SeatInfo info :
                    userLeftList) {
                if (info.userId.equals(mUserModel.userId)) {
                    mUserManagementView.updateLayout(false);
                }
            }
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
