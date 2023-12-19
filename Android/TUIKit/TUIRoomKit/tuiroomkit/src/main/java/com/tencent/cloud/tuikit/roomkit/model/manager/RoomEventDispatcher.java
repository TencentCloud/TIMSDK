package com.tencent.cloud.tuikit.roomkit.model.manager;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;
import static com.tencent.cloud.tuikit.roomkit.videoseat.Constants.VOLUME_CAN_HEARD_MIN_LIMIT;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RoomEventDispatcher extends TUIRoomObserver {
    private static final String TAG = "RoomEventDispatcher";

    private RoomStore mRoomStore;

    public RoomEventDispatcher(RoomStore roomStore) {
        mRoomStore = roomStore;
    }

    @Override
    public void onError(TUICommonDefine.Error errorCode, String message) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ERROR_CODE, errorCode);
        map.put(RoomEventConstant.KEY_MESSAGE, message);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.ERROR, map);
    }

    @Override
    public void onKickedOffLine(String message) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_MESSAGE, message);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.KICKED_OFF_LINE, map);
    }

    @Override
    public void onUserSigExpired() {
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_SIG_EXPIRED, null);
    }

    @Override
    public void onRoomNameChanged(String roomId, String roomName) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_ROOM_NAME, roomName);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.ROOM_NAME_CHANGED, map);
    }

    @Override
    public void onAllUserMicrophoneDisableChanged(String roomId, boolean isDisable) {
        mRoomStore.roomInfo.isMicrophoneDisableForAllUser = isDisable;
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_IS_DISABLE, isDisable);
        RoomEventCenter.getInstance()
                .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, map);
    }

    @Override
    public void onAllUserCameraDisableChanged(String roomId, boolean isDisable) {
        mRoomStore.roomInfo.isCameraDisableForAllUser = isDisable;
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_IS_DISABLE, isDisable);
        RoomEventCenter.getInstance()
                .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, map);
    }

    @Override
    public void onSendMessageForAllUserDisableChanged(String roomId, boolean isDisable) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_IS_DISABLE, isDisable);
        RoomEventCenter.getInstance()
                .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED, map);
    }

    @Override
    public void onRoomDismissed(String roomId) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.ROOM_DISMISSED, map);
    }

    @Override
    public void onKickedOutOfRoom(String roomId, TUIRoomDefine.KickedOutOfRoomReason reason, String message) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_MESSAGE, message);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM, map);
    }

    @Override
    public void onRoomSpeechModeChanged(String roomId, TUIRoomDefine.SpeechMode speechMode) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_SPEECH_MODE, speechMode);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.ROOM_SPEECH_MODE_CHANGED, map);
    }

    @Override
    public void onRemoteUserEnterRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
        mRoomStore.remoteUserEnterRoom(userInfo);
    }

    @Override
    public void onRemoteUserLeaveRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
        mRoomStore.remoteUserLeaveRoom(userInfo.userId);
    }

    @Override
    public void onUserRoleChanged(String userId, TUIRoomDefine.Role role) {
        if (TextUtils.equals(userId, mRoomStore.userModel.userId)) {
            mRoomStore.userModel.role = role;
            RoomEngineManager.sharedInstance().autoTakeSeatForOwner(null);
        }
        if (role == TUIRoomDefine.Role.ROOM_OWNER) {
            mRoomStore.roomInfo.ownerId = userId;
        }
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_USER_ID, userId);
        map.put(RoomEventConstant.KEY_ROLE, role);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, map);
    }

    @Override
    public void onUserVideoStateChanged(String userId, TUIRoomDefine.VideoStreamType streamType, boolean hasVideo,
                                        TUIRoomDefine.ChangeReason reason) {
        if (streamType == SCREEN_STREAM) {
            mRoomStore.handleUserScreenStateChanged(userId, hasVideo);
        } else {
            mRoomStore.updateUserCameraState(userId, streamType, hasVideo, reason);
        }
    }

    @Override
    public void onUserAudioStateChanged(String userId, boolean hasAudio, TUIRoomDefine.ChangeReason reason) {
        mRoomStore.updateUserAudioState(userId, hasAudio, reason);
    }

    @Override
    public void onUserVoiceVolumeChanged(Map<String, Integer> volumeMap) {
        for (Map.Entry<String, Integer> entry : volumeMap.entrySet()) {
            String userId = entry.getKey();
            if (TextUtils.isEmpty(userId)) {
                continue;
            }
            if (entry.getValue() < VOLUME_CAN_HEARD_MIN_LIMIT) {
                continue;
            }
            if (TextUtils.equals(userId, mRoomStore.userModel.userId) && !mRoomStore.audioModel.isHasAudioStream()) {
                continue;
            }
            mRoomStore.updateUserAudioVolume(userId, entry.getValue());
        }
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_VOLUME_MAP, volumeMap);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_VOICE_VOLUME_CHANGED, map);
    }

    @Override
    public void onSendMessageForUserDisableChanged(String roomId, String userId, boolean isDisable) {
        mRoomStore.disableUserSendingMsg(userId, isDisable);
    }

    @Override
    public void onUserNetworkQualityChanged(Map<String, TUICommonDefine.NetworkInfo> networkMap) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_NETWORK_MAP, networkMap);
        RoomEventCenter.getInstance().
                notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_NETWORK_QUALITY_CHANGED, map);
    }

    @Override
    public void onUserScreenCaptureStopped(int reason) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_REASON, reason);
        RoomEventCenter.getInstance().
                notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_SCREEN_CAPTURE_STOPPED, map);
    }

    @Override
    public void onRoomMaxSeatCountChanged(String roomId, int maxSeatCount) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_MAX_SEAT_COUNT, maxSeatCount);
        RoomEventCenter.getInstance()
                .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.ROOM_MAX_SEAT_COUNT_CHANGED, map);
    }

    @Override
    public void onSeatListChanged(List<TUIRoomDefine.SeatInfo> seatList, List<TUIRoomDefine.SeatInfo> seatedList,
                                  List<TUIRoomDefine.SeatInfo> leftList) {
        Log.d(TAG, "onSeatListChanged");
        RoomEngineManager manager = RoomEngineManager.sharedInstance();
        for (TUIRoomDefine.SeatInfo item : seatedList) {
            mRoomStore.setUserOnSeat(item.userId, true);
            manager.getUserInfo(item.userId, new TUIRoomDefine.GetUserInfoCallback() {
                @Override
                public void onSuccess(TUIRoomDefine.UserInfo userInfo) {
                    Log.d(TAG, "onSeatListChanged remoteUserTakeSeat userId=" + userInfo.userId);
                    mRoomStore.remoteUserTakeSeat(userInfo);
                }

                @Override
                public void onError(TUICommonDefine.Error error, String s) {
                    Log.e(TAG, "onSeatListChanged getUserInfo onError, error=" + error + " s=" + s);
                }
            });
        }

        for (TUIRoomDefine.SeatInfo item : leftList) {
            mRoomStore.setUserOnSeat(item.userId, false);
            Log.d(TAG, "onSeatListChanged remoteUserLeaveSeat userId=" + item.userId);
            mRoomStore.remoteUserLeaveSeat(item.userId);
        }
    }

    @Override
    public void onRequestReceived(TUIRoomDefine.Request request) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_REQUEST, request);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REQUEST_RECEIVED, map);

        if (TUIRoomDefine.RequestAction.REQUEST_TO_TAKE_SEAT == request.requestAction) {
            if (mRoomStore.userModel.role == TUIRoomDefine.Role.ROOM_OWNER && TextUtils.equals(request.userId,
                    mRoomStore.userModel.userId)) {
                RoomEngineManager.sharedInstance()
                        .responseRemoteRequest(request.requestAction, request.requestId, true, null);
            } else {
                mRoomStore.addTakeSeatRequest(request);
            }
        }
    }

    @Override
    public void onRequestCancelled(String requestId, String userId) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_REQUEST_ID, requestId);
        map.put(RoomEventConstant.KEY_USER_ID, userId);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REQUEST_CANCELLED, map);

        mRoomStore.removeTakeSeatRequest(requestId);
    }

    @Override
    public void onReceiveTextMessage(String roomId, TUICommonDefine.Message message) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_MESSAGE, message);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.RECEIVE_TEXT_MESSAGE, map);
    }

    @Override
    public void onReceiveCustomMessage(String roomId, TUICommonDefine.Message message) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_MESSAGE, message);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.RECEIVE_CUSTOM_MESSAGE, map);
    }

    @Override
    public void onKickedOffSeat(String userId) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_USER_ID, userId);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.KICKED_OFF_SEAT, map);
        mRoomStore.audioModel.setMicOpen(false);
    }
}