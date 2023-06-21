package com.tencent.cloud.tuikit.roomkit.model;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class RoomEventCenter {
    private Map<RoomEngineEvent, Set<WeakReference<RoomEngineEventResponder>>> mEngineResponderMap;
    private Map<String, Set<WeakReference<TUINotificationAdapter>>>            mUIEventResponderMap;

    /**
     * 事件列表
     */
    public enum RoomEngineEvent {
        ERROR,
        KICKED_OFF_LINE,
        USER_SIG_EXPIRED,
        ROOM_NAME_CHANGED,
        ALL_USER_MICROPHONE_DISABLE_CHANGED,
        ALL_USER_CAMERA_DISABLE_CHANGED,
        SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED,
        ROOM_DISMISSED,
        KICKED_OUT_OF_ROOM,
        ROOM_SPEECH_MODE_CHANGED,
        REMOTE_USER_ENTER_ROOM,
        REMOTE_USER_LEAVE_ROOM,
        USER_ROLE_CHANGED,
        USER_VIDEO_STATE_CHANGED,
        USER_AUDIO_STATE_CHANGED,
        USER_VOICE_VOLUME_CHANGED,
        SEND_MESSAGE_FOR_USER_DISABLE_CHANGED,
        USER_NETWORK_QUALITY_CHANGED,
        USER_SCREEN_CAPTURE_STOPPED,
        ROOM_MAX_SEAT_COUNT_CHANGED,
        SEAT_LIST_CHANGED,
        REQUEST_RECEIVED,
        REQUEST_CANCELLED,
        RECEIVE_TEXT_MESSAGE,
        RECEIVE_CUSTOM_MESSAGE,
        KICKED_OFF_SEAT
    }

    public static class RoomKitUIEvent {
        public static final String ROOM_KIT_EVENT        = "RoomKitEvent";
        public static final String CONFIGURATION_CHANGE  = "appConfigurationChange";
        public static final String EXIT_MEETING          = "exitMeeting";
        public static final String LEAVE_MEETING         = "leaveMeeting";
        public static final String EXIT_PREPARE_ACTIVITY = "exitPrepareActivity";
        public static final String EXIT_CREATE_ROOM      = "exitCreateRoom";
        public static final String EXIT_ENTER_ROOM       = "exitEnterRoom";
        public static final String ROOM_TYPE_CHANGE      = "roomTypeChange";
        public static final String AGREE_TAKE_SEAT       = "agreeTakeSeat";
        public static final String DISAGREE_TAKE_SEAT    = "disagreeTakeSeat";
        public static final String INVITE_TAKE_SEAT      = "inviteTakeSeat";
        public static final String SHOW_USER_MANAGEMENT  = "showUserManagement";
        public static final String SHOW_EXIT_ROOM_VIEW   = "showLeaveRoomView";
        public static final String SHOW_MEETING_INFO     = "showMeetingInfo";
        public static final String SHOW_USER_LIST        = "showUserList";
        public static final String SHOW_APPLY_LIST       = "showApplyList";
        public static final String SHOW_EXTENSION_VIEW   = "showExtensionView";
        public static final String SHOW_QRCODE_VIEW      = "showQRCodeView";
        public static final String START_SCREEN_SHARE    = "startScreenShare";
    }

    /**
     * engine事件统一回调
     */
    public interface RoomEngineEventResponder {
        void onEngineEvent(RoomEngineEvent event, Map<String, Object> params);
    }

    /**
     * UI事件统一回调
     */
    public interface RoomKitUIEventResponder {
        void onNotifyUIEvent(String key, Map<String, Object> params);
    }

    public static RoomEventCenter getInstance() {
        return RoomEventCenter.LazyHolder.INSTANCE;
    }

    private static class LazyHolder {
        private static final RoomEventCenter INSTANCE = new RoomEventCenter();
    }

    private RoomEventCenter() {
        mEngineResponderMap = new ConcurrentHashMap<>();
        mUIEventResponderMap = new ConcurrentHashMap<>();
    }

    /**
     * 订阅engine事件
     */
    public void subscribeEngine(RoomEngineEvent event, RoomEngineEventResponder observer) {
        if (event == null) {
            return;
        }
        if (mEngineResponderMap.containsKey(event)) {
            mEngineResponderMap.get(event).add(new WeakReference<>(observer));
        } else {
            Set<WeakReference<RoomEngineEventResponder>> responderSet = new HashSet<>();
            responderSet.add(new WeakReference<>(observer));
            mEngineResponderMap.put(event, responderSet);
        }
    }

    /**
     * 取消订阅engine事件
     */
    public void unsubscribeEngine(RoomEngineEvent event, RoomEngineEventResponder observer) {
        if (observer == null || !mEngineResponderMap.containsKey(event)) {
            return;
        }
        Set<WeakReference<RoomEngineEventResponder>> responderSet = mEngineResponderMap.get(event);
        if (responderSet == null || responderSet.isEmpty()) {
            return;
        }
        Iterator<WeakReference<RoomEngineEventResponder>> iterator = responderSet.iterator();
        while (iterator.hasNext()) {
            WeakReference<RoomEngineEventResponder> responderWeakReference = iterator.next();
            if (responderWeakReference != null && observer.equals(responderWeakReference.get())) {
                iterator.remove();
                break;
            }
        }
    }

    /**
     * 订阅UI事件
     */
    public void subscribeUIEvent(String event, RoomKitUIEventResponder responder) {
        if (TextUtils.isEmpty(event)) {
            return;
        }
        TUINotificationAdapter adapter = new TUINotificationAdapter(responder);
        if (mUIEventResponderMap.containsKey(event)) {
            mUIEventResponderMap.get(event).add(new WeakReference<>(adapter));
        } else {
            Set<WeakReference<TUINotificationAdapter>> responderSet = new HashSet<>();
            responderSet.add(new WeakReference<>(adapter));
            mUIEventResponderMap.put(event, responderSet);
        }
        TUICore.registerEvent(RoomKitUIEvent.ROOM_KIT_EVENT, event, adapter);
    }

    /**
     * 发送UI事件
     */
    public void notifyUIEvent(String event, Map<String, Object> params) {
        TUICore.notifyEvent(RoomKitUIEvent.ROOM_KIT_EVENT, event, params);
    }

    /**
     * 取消订阅UI事件
     */
    public void unsubscribeUIEvent(String event, RoomKitUIEventResponder responder) {
        if (TextUtils.isEmpty(event) || responder == null || !mUIEventResponderMap.containsKey(event)) {
            return;
        }
        Set<WeakReference<TUINotificationAdapter>> responderSet = mUIEventResponderMap.get(event);
        if (responderSet == null || responderSet.isEmpty()) {
            return;
        }
        Iterator<WeakReference<TUINotificationAdapter>> iterator = responderSet.iterator();
        while (iterator.hasNext()) {
            WeakReference<TUINotificationAdapter> responderWeakReference = iterator.next();
            if (responderWeakReference != null && responder.equals(responderWeakReference.get().mResponder.get())) {
                TUICore.unRegisterEvent(RoomKitUIEvent.ROOM_KIT_EVENT, event, responderWeakReference.get());
                iterator.remove();
            }
        }
    }

    public EngineEventCenter getEngineEventCent() {
        return new EngineEventCenter();
    }

    private void notifyEngineEvent(RoomEngineEvent event, Map<String, Object> params) {
        if (!mEngineResponderMap.containsKey(event)) {
            return;
        }
        Set<WeakReference<RoomEngineEventResponder>> responderSet = mEngineResponderMap.get(event);
        if (responderSet == null || responderSet.isEmpty()) {
            return;
        }
        for (WeakReference<RoomEngineEventResponder> roomEngineEventResponder : responderSet) {
            RoomEngineEventResponder responder = roomEngineEventResponder.get();
            if (responder != null) {
                responder.onEngineEvent(event, params);
            }
        }
    }

    static class TUINotificationAdapter implements ITUINotification {
        private final WeakReference<RoomKitUIEventResponder> mResponder;

        public TUINotificationAdapter(RoomKitUIEventResponder responder) {
            this.mResponder = new WeakReference<>(responder);
        }

        @Override
        public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
            if (mResponder.get() != null) {
                mResponder.get().onNotifyUIEvent(subKey, param);
            }
        }
    }

    private class EngineEventCenter extends TUIRoomObserver {

        @Override
        public void onError(TUICommonDefine.Error errorCode, String message) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ERROR_CODE, errorCode);
            map.put(RoomEventConstant.KEY_MESSAGE, message);
            notifyEngineEvent(RoomEngineEvent.ERROR, map);
        }

        @Override
        public void onKickedOffLine(String message) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_MESSAGE, message);
            notifyEngineEvent(RoomEngineEvent.KICKED_OFF_LINE, map);
        }

        @Override
        public void onUserSigExpired() {
            notifyEngineEvent(RoomEngineEvent.USER_SIG_EXPIRED, null);
        }

        @Override
        public void onRoomNameChanged(String roomId, String roomName) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_ROOM_NAME, roomName);
            notifyEngineEvent(RoomEngineEvent.ROOM_NAME_CHANGED, map);
        }

        @Override
        public void onAllUserMicrophoneDisableChanged(String roomId, boolean isDisable) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_IS_DISABLE, isDisable);
            notifyEngineEvent(RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, map);
        }

        @Override
        public void onAllUserCameraDisableChanged(String roomId, boolean isDisable) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_IS_DISABLE, isDisable);
            notifyEngineEvent(RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, map);
        }

        @Override
        public void onSendMessageForAllUserDisableChanged(String roomId, boolean isDisable) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_IS_DISABLE, isDisable);
            notifyEngineEvent(RoomEngineEvent.SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED, map);
        }

        @Override
        public void onRoomDismissed(String roomId) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            notifyEngineEvent(RoomEngineEvent.ROOM_DISMISSED, map);
        }

        @Override
        public void onKickedOutOfRoom(String roomId, String message) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_MESSAGE, message);
            notifyEngineEvent(RoomEngineEvent.KICKED_OUT_OF_ROOM, map);
        }

        @Override
        public void onRoomSpeechModeChanged(String roomId, TUIRoomDefine.SpeechMode speechMode) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_SPEECH_MODE, speechMode);
            notifyEngineEvent(RoomEngineEvent.ROOM_SPEECH_MODE_CHANGED, map);
        }

        @Override
        public void onRemoteUserEnterRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_USER_INFO, userInfo);
            notifyEngineEvent(RoomEngineEvent.REMOTE_USER_ENTER_ROOM, map);
        }

        @Override
        public void onRemoteUserLeaveRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_USER_INFO, userInfo);
            notifyEngineEvent(RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, map);
        }

        @Override
        public void onUserRoleChanged(String userId, TUIRoomDefine.Role role) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_USER_ID, userId);
            map.put(RoomEventConstant.KEY_ROLE, role);
            notifyEngineEvent(RoomEngineEvent.USER_ROLE_CHANGED, map);
        }

        @Override
        public void onUserVideoStateChanged(String userId, TUIRoomDefine.VideoStreamType streamType, boolean hasVideo,
                                            TUIRoomDefine.ChangeReason reason) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_USER_ID, userId);
            map.put(RoomEventConstant.KEY_STREAM_TYPE, streamType);
            map.put(RoomEventConstant.KEY_HAS_VIDEO, hasVideo);
            map.put(RoomEventConstant.KEY_REASON, reason);
            notifyEngineEvent(RoomEngineEvent.USER_VIDEO_STATE_CHANGED, map);
        }

        @Override
        public void onUserAudioStateChanged(String userId, boolean hasAudio, TUIRoomDefine.ChangeReason reason) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_USER_ID, userId);
            map.put(RoomEventConstant.KEY_HAS_AUDIO, hasAudio);
            map.put(RoomEventConstant.KEY_REASON, reason);
            notifyEngineEvent(RoomEngineEvent.USER_AUDIO_STATE_CHANGED, map);
        }

        @Override
        public void onUserVoiceVolumeChanged(Map<String, Integer> volumeMap) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_VOLUME_MAP, volumeMap);
            notifyEngineEvent(RoomEngineEvent.USER_VOICE_VOLUME_CHANGED, map);
        }

        @Override
        public void onSendMessageForUserDisableChanged(String roomId, String userId, boolean isDisable) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_USER_ID, userId);
            map.put(RoomEventConstant.KEY_IS_DISABLE, isDisable);
            notifyEngineEvent(RoomEngineEvent.SEND_MESSAGE_FOR_USER_DISABLE_CHANGED, map);
        }

        @Override
        public void onUserNetworkQualityChanged(Map<String, TUICommonDefine.NetworkInfo> networkMap) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_NETWORK_MAP, networkMap);
            notifyEngineEvent(RoomEngineEvent.USER_NETWORK_QUALITY_CHANGED, map);
        }

        @Override
        public void onUserScreenCaptureStopped(int reason) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_REASON, reason);
            notifyEngineEvent(RoomEngineEvent.USER_SCREEN_CAPTURE_STOPPED, map);
        }

        @Override
        public void onRoomMaxSeatCountChanged(String roomId, int maxSeatCount) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_MAX_SEAT_COUNT, maxSeatCount);
            notifyEngineEvent(RoomEngineEvent.ROOM_MAX_SEAT_COUNT_CHANGED, map);
        }

        @Override
        public void onSeatListChanged(List<TUIRoomDefine.SeatInfo> seatList, List<TUIRoomDefine.SeatInfo> seatedList,
                                      List<TUIRoomDefine.SeatInfo> leftList) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_SEAT_LIST, seatList);
            map.put(RoomEventConstant.KEY_SEATED_LIST, seatedList);
            map.put(RoomEventConstant.KEY_LEFT_LIST, leftList);
            notifyEngineEvent(RoomEngineEvent.SEAT_LIST_CHANGED, map);
        }

        @Override
        public void onRequestReceived(TUIRoomDefine.Request request) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_REQUEST, request);
            notifyEngineEvent(RoomEngineEvent.REQUEST_RECEIVED, map);
        }

        @Override
        public void onRequestCancelled(String requestId, String userId) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_REQUEST_ID, requestId);
            map.put(RoomEventConstant.KEY_USER_ID, userId);
            notifyEngineEvent(RoomEngineEvent.REQUEST_CANCELLED, map);
        }

        @Override
        public void onReceiveTextMessage(String roomId, TUICommonDefine.Message message) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_MESSAGE, message);
            notifyEngineEvent(RoomEngineEvent.RECEIVE_TEXT_MESSAGE, map);
        }

        @Override
        public void onReceiveCustomMessage(String roomId, TUICommonDefine.Message message) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_ROOM_ID, roomId);
            map.put(RoomEventConstant.KEY_MESSAGE, message);
            notifyEngineEvent(RoomEngineEvent.RECEIVE_CUSTOM_MESSAGE, map);
        }

        @Override
        public void onKickedOffSeat(String userId) {
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_USER_ID, userId);
            notifyEngineEvent(RoomEngineEvent.KICKED_OFF_SEAT, map);
        }
    }
}