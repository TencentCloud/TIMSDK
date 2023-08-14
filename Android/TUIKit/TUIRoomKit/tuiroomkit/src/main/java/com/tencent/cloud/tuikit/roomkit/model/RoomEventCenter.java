package com.tencent.cloud.tuikit.roomkit.model;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
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
        GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM,
        REMOTE_USER_ENTER_ROOM,
        REMOTE_USER_LEAVE_ROOM,
        LOCAL_USER_EXIT_ROOM,
        LOCAL_USER_DESTROY_ROOM,
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

    public interface RoomEngineMessage {
        String ROOM_ENGINE_MSG = "ROOM_ENGINE_MSG";
        String ROOM_ENTERED    = "ROOM_ENTERED";
    }

    public static class RoomKitUIEvent {
        public static final String ROOM_KIT_EVENT        = "RoomKitEvent";
        public static final String CONFIGURATION_CHANGE  = "appConfigurationChange";
        public static final String EXIT_MEETING          = "exitMeeting";
        public static final String LEAVE_MEETING         = "leaveMeeting";
        public static final String KICKED_OFF_LINE       = "kickedOffLine";
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

        public static final String LOCAL_SCREEN_SHARE_STATE_CHANGED = "LOCAL_SCREEN_SHARE_STATE_CHANGED";

        public static final String ENTER_FLOAT_WINDOW = "ENTER_FLOAT_WINDOW";
        public static final String EXIT_FLOAT_WINDOW  = "EXIT_FLOAT_WINDOW";

        public static final String SEND_IM_MSG_COMPLETE = "SEND_IM_MSG_COMPLETE";
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

    public void notifyEngineEvent(RoomEngineEvent event, Map<String, Object> params) {
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
}