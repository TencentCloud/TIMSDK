package com.tencent.cloud.tuikit.roomkit.model.manager;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.CAMERA_STREAM_LOW;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.ConferenceObserver;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.model.data.SeatState;
import com.tencent.cloud.tuikit.roomkit.model.data.UserState;
import com.tencent.cloud.tuikit.roomkit.model.data.ViewState;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RoomEngineObserver extends TUIRoomObserver {
    private static final String TAG = "RoomEngineObserver";

    private final ConferenceState mConferenceState;
    private final SeatState       mSeatState;
    private final ViewState       mViewState;
    private final UserState       mUserState;

    public RoomEngineObserver(ConferenceState conferenceState) {
        mConferenceState = conferenceState;
        mSeatState = conferenceState.seatState;
        mViewState = conferenceState.viewState;
        mUserState = conferenceState.userState;
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
    }

    @Override
    public void onUserSigExpired() {
        Log.d(TAG, "onUserSigExpired");
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.USER_SIG_EXPIRED, null);
    }

    @Override
    public void onRoomNameChanged(String roomId, String roomName) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        map.put(ConferenceEventConstant.KEY_ROOM_NAME, roomName);
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
    public void onSendMessageForAllUserDisableChanged(String roomId, boolean isDisable) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        map.put(ConferenceEventConstant.KEY_IS_DISABLE, isDisable);
        ConferenceEventCenter.getInstance()
                .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED, map);
    }

    @Override
    public void onRoomDismissed(String roomId) {
        Log.d(TAG, "onRoomDismissed roomId=" + roomId);
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.ROOM_DISMISSED, map);

        ConferenceObserver observer = mConferenceState.getConferenceObserver();
        if (observer != null) {
            Log.i(TAG, "onConferenceFinished : " + roomId);
            observer.onConferenceFinished(roomId);
        }
    }

    @Override
    public void onKickedOutOfRoom(String roomId, TUIRoomDefine.KickedOutOfRoomReason reason, String message) {
        Log.d(TAG, "onKickedOutOfRoom roomId=" + roomId + " reason=" + reason + " message=" + message);
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        map.put(ConferenceEventConstant.KEY_MESSAGE, message);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM, map);

        ConferenceObserver observer = mConferenceState.getConferenceObserver();
        if (observer != null) {
            Log.i(TAG, "onConferenceExisted : " + roomId);
            observer.onConferenceExisted(roomId);
        }
    }

    @Override
    public void onRemoteUserEnterRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
        Log.d(TAG, "onRemoteUserEnterRoom userId=" + userInfo.userId);
        mConferenceState.remoteUserEnterRoom(userInfo);
        mUserState.remoteUserEnterRoom(userInfo);
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
    public void onUserRoleChanged(TUIRoomDefine.UserInfo userInfo) {
        Log.d(TAG, "onUserRoleChanged userId=" + userInfo.userId + " role=" + userInfo.userRole);
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

    @Override
    public void onUserVideoStateChanged(String userId, TUIRoomDefine.VideoStreamType streamType, boolean hasVideo,
                                        TUIRoomDefine.ChangeReason reason) {
        Log.d(TAG, "onUserVideoStateChanged userId=" + userId + " hasVideo=" + hasVideo + " type=" + streamType);
        if (TextUtils.equals(userId, mConferenceState.userModel.userId) && streamType == CAMERA_STREAM_LOW) {
            return;
        }
        if (streamType == SCREEN_STREAM) {
            mConferenceState.handleUserScreenStateChanged(userId, hasVideo);
            mUserState.updateUserScreenState(userId, hasVideo);
        } else {
            mConferenceState.updateUserCameraState(userId, streamType, hasVideo, reason);
            mUserState.updateUserCameraState(userId, hasVideo, streamType);
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
        for (Map.Entry<String, Integer> entry : volumeMap.entrySet()) {
            String userId = entry.getKey();
            if (TextUtils.isEmpty(userId)) {
                continue;
            }
            if (TextUtils.equals(userId, mConferenceState.userModel.userId) && !mConferenceState.audioModel.isHasAudioStream()) {
                continue;
            }
            int volume = entry.getValue();
            mConferenceState.updateUserAudioVolume(userId, volume);
            UserState.UserVolumeInfo userVolumeInfo = mUserState.userVolumeInfo.get();
            userVolumeInfo.update(userId, volume);
            mUserState.userVolumeInfo.set(userVolumeInfo);
        }
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
    public void onRoomMaxSeatCountChanged(String roomId, int maxSeatCount) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        map.put(ConferenceEventConstant.KEY_MAX_SEAT_COUNT, maxSeatCount);
        ConferenceEventCenter.getInstance()
                .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.ROOM_MAX_SEAT_COUNT_CHANGED, map);
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
    public void onReceiveTextMessage(String roomId, TUICommonDefine.Message message) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        map.put(ConferenceEventConstant.KEY_MESSAGE, message);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.RECEIVE_TEXT_MESSAGE, map);
    }

    @Override
    public void onReceiveCustomMessage(String roomId, TUICommonDefine.Message message) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, roomId);
        map.put(ConferenceEventConstant.KEY_MESSAGE, message);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.RECEIVE_CUSTOM_MESSAGE, map);
    }

    @Override
    public void onKickedOffSeat(String userId) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_USER_ID, userId);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.KICKED_OFF_SEAT, map);
        mConferenceState.audioModel.setMicOpen(false);
    }
}