package com.tencent.cloud.tuikit.roomkit.manager.observer;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.RoomDismissedReason.BY_SERVER;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.UserInfoModifyFlag.NAME_CARD;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.UserInfoModifyFlag.USER_ROLE;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.CAMERA_STREAM_LOW;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;
import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.ConferenceExitedReason.EXITED_BY_ADMIN_KICK_OUT;
import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.ConferenceExitedReason.EXITED_BY_JOINED_ON_OTHER_DEVICE;
import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.ConferenceExitedReason.EXITED_BY_KICKED_OUT_OF_LINE;
import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.ConferenceExitedReason.EXITED_BY_SERVER_KICK_OUT;
import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.ConferenceExitedReason.EXITED_BY_USER_SIG_EXPIRED;
import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.ConferenceFinishedReason.FINISHED_BY_OWNER;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_EXITED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_FINISHED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_REASON;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.state.InvitationState;
import com.tencent.cloud.tuikit.roomkit.state.MediaState;
import com.tencent.cloud.tuikit.roomkit.state.RoomState;
import com.tencent.cloud.tuikit.roomkit.state.SeatState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.state.ViewState;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.qcloud.tuicore.TUICore;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RoomEngineObserver extends TUIRoomObserver {
    private static final String TAG = "RoomEngineObserver";

    private final ConferenceState mConferenceState;
    private final SeatState       mSeatState;
    private final ViewState       mViewState;
    private final UserState       mUserState;
    private final RoomState       mRoomState;
    private final MediaState      mMediaState;
    private final InvitationState mInvitationState;

    public RoomEngineObserver(ConferenceState conferenceState) {
        mConferenceState = conferenceState;
        mSeatState = conferenceState.seatState;
        mViewState = conferenceState.viewState;
        mUserState = conferenceState.userState;
        mRoomState = conferenceState.roomState;
        mMediaState = conferenceState.mediaState;
        mInvitationState = conferenceState.invitationState;
    }

    @Override
    public void onError(TUICommonDefine.Error errorCode, String message) {
        Log.d(TAG, "onError errorCode=" + errorCode + " message=" + message);
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ERROR_CODE, errorCode);
        map.put(ConferenceEventConstant.KEY_MESSAGE, message);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.ERROR, map);
    }

    @Override
    public void onKickedOffLine(String message) {
        Log.d(TAG, "onKickedOffLine message=" + message);
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_MESSAGE, message);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.KICKED_OFF_LINE, map);

        Map<String, Object> param = new HashMap<>(2);
        param.put(KEY_CONFERENCE, mConferenceState.roomState.roomInfo);
        param.put(KEY_REASON, EXITED_BY_KICKED_OUT_OF_LINE);
        TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_EXITED, param);
    }

    @Override
    public void onUserSigExpired() {
        Log.d(TAG, "onUserSigExpired");
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.USER_SIG_EXPIRED, null);

        Map<String, Object> param = new HashMap<>(2);
        param.put(KEY_CONFERENCE, mConferenceState.roomState.roomInfo);
        param.put(KEY_REASON, EXITED_BY_USER_SIG_EXPIRED);
        TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_EXITED, param);
    }

    @Override
    public void onRoomNameChanged(String roomId, String roomName) {
        Log.d(TAG, "onRoomNameChanged roomId=" + roomId + ",roomName=" + roomName);
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        map.put(ConferenceEventConstant.KEY_ROOM_NAME, roomName);
        mConferenceState.roomState.roomName.set(roomName);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.ROOM_NAME_CHANGED, map);
    }

    @Override
    public void onAllUserMicrophoneDisableChanged(String roomId, boolean isDisable) {
        mConferenceState.roomInfo.isMicrophoneDisableForAllUser = isDisable;
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        map.put(ConferenceEventConstant.KEY_IS_DISABLE, isDisable);
        ConferenceEventCenter.getInstance()
                .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, map);
    }

    @Override
    public void onAllUserCameraDisableChanged(String roomId, boolean isDisable) {
        mConferenceState.roomInfo.isCameraDisableForAllUser = isDisable;
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        map.put(ConferenceEventConstant.KEY_IS_DISABLE, isDisable);
        ConferenceEventCenter.getInstance()
                .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, map);
    }

    @Override
    public void onScreenShareForAllUserDisableChanged(String roomId, boolean isDisable) {
        Log.d(TAG, "onScreenShareForAllUserDisableChanged roomId=" + roomId + ",isDisable=" + isDisable);
        mConferenceState.roomState.isDisableScreen.set(isDisable);
    }

    @Override
    public void onSendMessageForAllUserDisableChanged(String roomId, boolean isDisable) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        map.put(ConferenceEventConstant.KEY_IS_DISABLE, isDisable);
        ConferenceEventCenter.getInstance()
                .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED, map);
    }

    @Override
    public void onRoomDismissed(String roomId, TUIRoomDefine.RoomDismissedReason reason) {
        Log.d(TAG, "onRoomDismissed roomId=" + roomId);
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.ROOM_DISMISSED, map);

        Map<String, Object> param = new HashMap<>(2);
        param.put(KEY_CONFERENCE, mRoomState.roomInfo);
        param.put(KEY_REASON, FINISHED_BY_OWNER);
        TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_FINISHED, param);
    }

    @Override
    public void onKickedOutOfRoom(String roomId, TUIRoomDefine.KickedOutOfRoomReason reason, String message) {
        Log.d(TAG, "onKickedOutOfRoom roomId=" + roomId + " reason=" + reason + " message=" + message);
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        map.put(ConferenceEventConstant.KEY_MESSAGE, message);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM, map);

        Map<String, Object> param = new HashMap<>(2);
        param.put(KEY_CONFERENCE, mRoomState.roomInfo);
        ConferenceDefine.ConferenceExitedReason exitedReason = reason == TUIRoomDefine.KickedOutOfRoomReason.BY_ADMIN
                ? EXITED_BY_ADMIN_KICK_OUT : reason == TUIRoomDefine.KickedOutOfRoomReason.BY_SERVER
                ? EXITED_BY_SERVER_KICK_OUT : EXITED_BY_JOINED_ON_OTHER_DEVICE;
        param.put(KEY_REASON, exitedReason);
        TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_EXITED, param);
    }

    @Override
    public void onRemoteUserEnterRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
        Log.d(TAG, "onRemoteUserEnterRoom userId=" + userInfo.userId);
        mConferenceState.remoteUserEnterRoom(userInfo);
        mUserState.remoteUserEnterRoom(userInfo);
        mInvitationState.remoteUserEnterRoom(userInfo);
    }

    @Override
    public void onRemoteUserLeaveRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
        Log.d(TAG, "onRemoteUserLeaveRoom userId=" + userInfo.userId);
        mConferenceState.remoteUserLeaveRoom(userInfo.userId);
        mUserState.remoteUserLeaveRoom(userInfo);
        mConferenceState.removeTakeSeatRequestByUserId(userInfo.userId);
        mSeatState.removeTakeSeatRequestByUserId(userInfo.userId);
        mViewState.removePendingTakeSeatRequestByUserId(userInfo.userId);
    }

    @Override
    public void onUserInfoChanged(TUIRoomDefine.UserInfo userInfo, List<TUIRoomDefine.UserInfoModifyFlag> modifyFlag) {
        Log.d(TAG, "onUserInfoChanged userId=" + userInfo.userId + " role=" + userInfo.userRole);
        handleUserRoleChangedIfNeeded(userInfo, modifyFlag);
        handleNameCardChangedIfNeeded(userInfo, modifyFlag);
    }

    private void handleUserRoleChangedIfNeeded(TUIRoomDefine.UserInfo userInfo, List<TUIRoomDefine.UserInfoModifyFlag> modifyFlag) {
        if (!modifyFlag.contains(USER_ROLE)) {
            return;
        }
        if (userInfo.userRole == TUIRoomDefine.Role.ROOM_OWNER) {
            mConferenceState.roomState.ownerName.set(TextUtils.isEmpty(userInfo.nameCard) ? userInfo.userName : userInfo.nameCard);
        }
        if (TextUtils.equals(userInfo.userId, mConferenceState.userModel.userId)) {
            if (mConferenceState.userModel.getRole() == TUIRoomDefine.Role.GENERAL_USER
                    && userInfo.userRole != TUIRoomDefine.Role.GENERAL_USER) {
                ConferenceController.sharedInstance().getSeatApplicationList();
            }
            mConferenceState.userModel.changeRole(userInfo.userRole);
            ConferenceController.sharedInstance().autoTakeSeatForOwner(null);
            ConferenceController.sharedInstance().enableSendingMessageForOwner();
        }
        mConferenceState.handleUserRoleChanged(userInfo.userId, userInfo.userRole);
        mUserState.handleUserRoleChanged(userInfo);
    }

    private void handleNameCardChangedIfNeeded(TUIRoomDefine.UserInfo userInfo, List<TUIRoomDefine.UserInfoModifyFlag> modifyFlag) {
        if (!modifyFlag.contains(NAME_CARD)) {
            return;
        }
        mSeatState.updateTakeSeatRequestUserName(userInfo.userId, userInfo.nameCard);
        mConferenceState.setUserNameCard(userInfo.userId, userInfo.nameCard);
        mConferenceState.updateTakeSeatRequestUserName(userInfo.userId, userInfo.nameCard);
        mUserState.userNameCardChanged(userInfo);
        if (userInfo.userRole == TUIRoomDefine.Role.ROOM_OWNER) {
            mRoomState.ownerName.set(userInfo.nameCard);
        }
    }

    @Override
    public void onUserVideoStateChanged(String userId, TUIRoomDefine.VideoStreamType streamType, boolean hasVideo,
                                        TUIRoomDefine.ChangeReason reason) {
        Log.d(TAG, "onUserVideoStateChanged userId=" + userId + " hasVideo=" + hasVideo + " type=" + streamType);
        if (TextUtils.equals(userId, mConferenceState.userModel.userId) && streamType == CAMERA_STREAM_LOW) {
            return;
        }
        if (TextUtils.equals(userId, mConferenceState.userModel.userId) && streamType == CAMERA_STREAM) {
            mMediaState.isCameraOpened.set(hasVideo);
        }
        if (streamType == SCREEN_STREAM) {
            mConferenceState.handleUserScreenStateChanged(userId, hasVideo);
            mUserState.updateUserScreenState(userId, hasVideo);
        } else {
            mConferenceState.updateUserCameraState(userId, streamType, hasVideo, reason);
            mUserState.updateUserCameraState(userId, hasVideo, streamType);
        }
        if (TextUtils.equals(userId, mConferenceState.userModel.userId) && streamType == SCREEN_STREAM && !hasVideo && reason == TUIRoomDefine.ChangeReason.BY_ADMIN) {
            ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.LOCAL_SHARE_STOPPED_BY_ADMIN, null);
        }
    }

    @Override
    public void onUserAudioStateChanged(String userId, boolean hasAudio, TUIRoomDefine.ChangeReason reason) {
        Log.d(TAG, "onUserAudioStateChanged userId=" + userId + " hasAudio=" + hasAudio);
        mConferenceState.updateUserAudioState(userId, hasAudio, reason);
        mUserState.updateUserAudioState(userId, hasAudio);
    }

    @Override
    public void onUserVoiceVolumeChanged(Map<String, Integer> volumeMap) {
        Map<String, Integer> volumes = mMediaState.volumeInfos.get();
        for (Map.Entry<String, Integer> entry : volumeMap.entrySet()) {
            String userId = entry.getKey();
            if (TextUtils.isEmpty(userId)) {
                continue;
            }
            if (TextUtils.equals(userId, mConferenceState.userModel.userId) && !mConferenceState.audioModel.isHasAudioStream()) {
                continue;
            }
            volumes.put(entry.getKey(), entry.getValue());
            int volume = entry.getValue();
            mConferenceState.updateUserAudioVolume(userId, volume);
            UserState.UserVolumeInfo userVolumeInfo = mUserState.userVolumeInfo.get();
            userVolumeInfo.update(userId, volume);
            mUserState.userVolumeInfo.set(userVolumeInfo);
        }
        mMediaState.volumeInfos.set(volumes);
        volumes.clear();
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_VOLUME_MAP, volumeMap);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.USER_VOICE_VOLUME_CHANGED, map);
    }

    @Override
    public void onSendMessageForUserDisableChanged(String roomId, String userId, boolean isDisable) {
        Log.d(TAG, "onSendMessageForUserDisableChanged userId=" + userId + " isDisable=" + isDisable);
        mConferenceState.enableUserSendingMsg(userId, !isDisable);
        mUserState.updateUserMessageState(userId, isDisable);
    }

    @Override
    public void onUserNetworkQualityChanged(Map<String, TUICommonDefine.NetworkInfo> networkMap) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_NETWORK_MAP, networkMap);
        ConferenceEventCenter.getInstance().
                notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.USER_NETWORK_QUALITY_CHANGED, map);
    }

    @Override
    public void onUserScreenCaptureStopped(int reason) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_REASON, reason);
        ConferenceEventCenter.getInstance().
                notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.USER_SCREEN_CAPTURE_STOPPED, map);
    }

    @Override
    public void onSeatListChanged(List<TUIRoomDefine.SeatInfo> seatList, List<TUIRoomDefine.SeatInfo> seatedList,
                                  List<TUIRoomDefine.SeatInfo> leftList) {
        Log.d(TAG, "onSeatListChanged");
        ConferenceController manager = ConferenceController.sharedInstance();
        for (TUIRoomDefine.SeatInfo item : seatedList) {
            mSeatState.seatedUsers.add(item.userId);
            manager.getUserInfo(item.userId, new TUIRoomDefine.GetUserInfoCallback() {
                @Override
                public void onSuccess(TUIRoomDefine.UserInfo userInfo) {
                    Log.d(TAG, "onSeatListChanged remoteUserTakeSeat userId=" + userInfo.userId);
                    mConferenceState.remoteUserTakeSeat(userInfo);
                }

                @Override
                public void onError(TUICommonDefine.Error error, String s) {
                    Log.e(TAG, "onSeatListChanged getUserInfo onError, error=" + error + " s=" + s);
                }
            });
        }

        for (TUIRoomDefine.SeatInfo item : leftList) {
            Log.d(TAG, "onSeatListChanged remoteUserLeaveSeat userId=" + item.userId);
            mConferenceState.remoteUserLeaveSeat(item.userId);
            mSeatState.seatedUsers.remove(item.userId);
        }
    }

    @Override
    public void onRequestReceived(TUIRoomDefine.Request request) {
        Log.d(TAG, "onRequestReceived userId=" + request.userId + " action=" + request.requestAction);
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_REQUEST, request);
        UserEntity user = mConferenceState.findUserWithCameraStream(mConferenceState.allUserList, request.userId);
        map.put(ConferenceEventConstant.KEY_ROLE, user == null ? TUIRoomDefine.Role.ROOM_OWNER : user.getRole());
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.REQUEST_RECEIVED, map);

        if (TUIRoomDefine.RequestAction.REQUEST_TO_TAKE_SEAT == request.requestAction) {
            if (mConferenceState.userModel.getRole() == TUIRoomDefine.Role.ROOM_OWNER && TextUtils.equals(request.userId,
                    mConferenceState.userModel.userId)) {
                ConferenceController.sharedInstance()
                        .responseRemoteRequest(request.requestAction, request.requestId, true, null);
            } else {
                mConferenceState.addTakeSeatRequest(request);
                mSeatState.addTakeSeatRequest(request);
                mViewState.addPendingTakeSeatRequest(request.requestId);
            }
        }
    }

    @Override
    public void onRequestCancelled(TUIRoomDefine.Request request, TUIRoomDefine.UserInfo operateUser) {
        Log.d(TAG, "onRequestCancelled userId=" + request.userId + " action=" + request.requestAction);
        mConferenceState.removeTakeSeatRequest(request.requestId);
        mSeatState.removeTakeSeatRequest(request.requestId);
        mViewState.removePendingTakeSeatRequest(request.requestId);
    }

    @Override
    public void onRequestProcessed(TUIRoomDefine.Request request, TUIRoomDefine.UserInfo operateUser) {
        Log.d(TAG, "onRequestProcessed userId=" + request.userId + " action=" + request.requestAction);
        mConferenceState.removeTakeSeatRequest(request.requestId);
        mSeatState.removeTakeSeatRequest(request.requestId);
        mViewState.removePendingTakeSeatRequest(request.requestId);
    }

    @Override
    public void onKickedOffSeat(int seatIndex, TUIRoomDefine.UserInfo operateUser) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_USER_ID, operateUser.userId);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.KICKED_OFF_SEAT, map);
        mConferenceState.audioModel.setMicOpen(false);
    }
}