package com.tencent.cloud.tuikit.roomkit.model.manager;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RoomEventDispatcher extends TUIRoomObserver {
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
        mRoomStore.allUserList.add(userInfo);
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_USER_INFO, userInfo);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, map);
    }

    @Override
    public void onRemoteUserLeaveRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
        TUIRoomDefine.UserInfo user = findUserInfo(userInfo.userId);
        if (user != null) {
            mRoomStore.allUserList.remove(user);
        }
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_USER_INFO, userInfo);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, map);
    }

    @Override
    public void onUserRoleChanged(String userId, TUIRoomDefine.Role role) {
        TUIRoomDefine.UserInfo userInfo = findUserInfo(userId);
        if (userInfo != null) {
            userInfo.userRole = role;
        }
        if (TextUtils.equals(userId, mRoomStore.userModel.userId)) {
            mRoomStore.userModel.role = role;
        }
        if (role == TUIRoomDefine.Role.ROOM_OWNER) {
            mRoomStore.roomInfo.owner = userId;
        }
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_USER_ID, userId);
        map.put(RoomEventConstant.KEY_ROLE, role);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, map);
    }

    @Override
    public void onUserVideoStateChanged(String userId, TUIRoomDefine.VideoStreamType streamType, boolean hasVideo,
                                        TUIRoomDefine.ChangeReason reason) {
        TUIRoomDefine.UserInfo userInfo = findUserInfo(userId);
        if (userInfo != null) {
            if (SCREEN_STREAM == streamType) {
                userInfo.hasScreenStream = hasVideo;
            } else {
                userInfo.hasVideoStream = hasVideo;
            }
        }
        if (TextUtils.equals(mRoomStore.userModel.userId, userId) && streamType == CAMERA_STREAM) {
            mRoomStore.roomInfo.isOpenCamera = hasVideo;
        }

        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_USER_ID, userId);
        map.put(RoomEventConstant.KEY_STREAM_TYPE, streamType);
        map.put(RoomEventConstant.KEY_HAS_VIDEO, hasVideo);
        map.put(RoomEventConstant.KEY_REASON, reason);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED, map);
    }

    @Override
    public void onUserAudioStateChanged(String userId, boolean hasAudio, TUIRoomDefine.ChangeReason reason) {
        TUIRoomDefine.UserInfo userInfo = findUserInfo(userId);
        if (userInfo != null) {
            userInfo.hasAudioStream = hasAudio;
        }
        if (TextUtils.equals(mRoomStore.userModel.userId, userId)) {
            mRoomStore.roomInfo.isOpenMicrophone = hasAudio;
        }

        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_USER_ID, userId);
        map.put(RoomEventConstant.KEY_HAS_AUDIO, hasAudio);
        map.put(RoomEventConstant.KEY_REASON, reason);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_AUDIO_STATE_CHANGED, map);
    }

    @Override
    public void onUserVoiceVolumeChanged(Map<String, Integer> volumeMap) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_VOLUME_MAP, volumeMap);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_VOICE_VOLUME_CHANGED, map);
    }

    @Override
    public void onSendMessageForUserDisableChanged(String roomId, String userId, boolean isDisable) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
        map.put(RoomEventConstant.KEY_USER_ID, userId);
        map.put(RoomEventConstant.KEY_IS_DISABLE, isDisable);
        RoomEventCenter.getInstance().
                notifyEngineEvent(RoomEventCenter.RoomEngineEvent.SEND_MESSAGE_FOR_USER_DISABLE_CHANGED, map);
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

        for (TUIRoomDefine.SeatInfo info : seatedList) {
            if (info.userId.equals(mRoomStore.userModel.userId)) {
                mRoomStore.userModel.isOnSeat = true;
                break;
            }
        }

        for (TUIRoomDefine.SeatInfo info : leftList) {
            if (info.userId.equals(mRoomStore.userModel.userId)) {
                mRoomStore.userModel.isOnSeat = false;
                break;
            }
        }

        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_SEAT_LIST, seatList);
        map.put(RoomEventConstant.KEY_SEATED_LIST, seatedList);
        map.put(RoomEventConstant.KEY_LEFT_LIST, leftList);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.SEAT_LIST_CHANGED, map);
    }

    @Override
    public void onRequestReceived(TUIRoomDefine.Request request) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_REQUEST, request);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REQUEST_RECEIVED, map);
    }

    @Override
    public void onRequestCancelled(String requestId, String userId) {
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_REQUEST_ID, requestId);
        map.put(RoomEventConstant.KEY_USER_ID, userId);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REQUEST_CANCELLED, map);
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
    }

    private TUIRoomDefine.UserInfo findUserInfo(String userId) {
        List<TUIRoomDefine.UserInfo> list =
                RoomEngineManager.sharedInstance(TUILogin.getAppContext()).getRoomStore().allUserList;
        for (TUIRoomDefine.UserInfo item : list) {
            if (TextUtils.equals(item.userId, userId)) {
                return item;
            }
        }
        return null;
    }
}