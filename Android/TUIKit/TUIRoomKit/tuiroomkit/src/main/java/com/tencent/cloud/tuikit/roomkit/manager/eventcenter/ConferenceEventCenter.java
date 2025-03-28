package com.tencent.cloud.tuikit.roomkit.manager.eventcenter;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

public class ConferenceEventCenter {
    private static final String TAG = "ConferenceEventCenter";

    private Map<RoomEngineEvent, List<RoomEngineEventResponder>> mEngineResponderMap;
    private Map<String, List<TUINotificationAdapter>>            mUIEventResponderMap;

    public enum RoomEngineEvent {
        ERROR,
        KICKED_OFF_LINE,
        USER_SIG_EXPIRED,
        ROOM_NAME_CHANGED,
        LOCAL_CAMERA_STATE_CHANGED,
        LOCAL_SCREEN_STATE_CHANGED,
        LOCAL_AUDIO_STATE_CHANGED,
        ALL_USER_MICROPHONE_DISABLE_CHANGED,
        ALL_USER_CAMERA_DISABLE_CHANGED,
        SEND_MESSAGE_FOR_ALL_USER_DISABLE_CHANGED,
        ROOM_DISMISSED,
        KICKED_OUT_OF_ROOM,
        GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM,
        REMOTE_USER_ENTER_ROOM,
        REMOTE_USER_LEAVE_ROOM,
        LOCAL_USER_CREATE_ROOM,
        LOCAL_USER_ENTER_ROOM,
        LOCAL_USER_EXIT_ROOM,
        LOCAL_USER_DESTROY_ROOM,
        USER_ROLE_CHANGED,
        USER_SCREEN_STATE_CHANGED,
        USER_CAMERA_STATE_CHANGED,
        USER_MIC_STATE_CHANGED,
        USER_VOICE_VOLUME_CHANGED,
        USER_SEND_MESSAGE_ABILITY_CHANGED,
        USER_NETWORK_QUALITY_CHANGED,
        USER_SCREEN_CAPTURE_STOPPED,
        REMOTE_USER_TAKE_SEAT,
        REMOTE_USER_LEAVE_SEAT,
        REQUEST_RECEIVED,
        KICKED_OFF_SEAT,
        USER_TAKE_SEAT_REQUEST_ADD,
        USER_TAKE_SEAT_REQUEST_REMOVE,
        LOCAL_VIDEO_FPS_CHANGED,
        LOCAL_VIDEO_BITRATE_CHANGED,
        LOCAL_VIDEO_RESOLUTION_CHANGED,
        LOCAL_AUDIO_CAPTURE_VOLUME_CHANGED,
        LOCAL_AUDIO_PLAY_VOLUME_CHANGED,
        LOCAL_AUDIO_VOLUME_EVALUATION_CHANGED,
        LOCAL_USER_GENERAL_TO_MANAGER,
        LOCAL_USER_MANAGER_TO_GENERAL,
        LOCAL_USER_TO_OWNER,
        ON_STATISTICS,
        LOCAL_SHARE_STOPPED_BY_ADMIN,
        UPDATE_CONFERENCE_LIST,
    }

    public static class RoomKitUIEvent {
        public static final String ROOM_KIT_EVENT       = "ROOM_KIT_EVENT";
        public static final String CONFIGURATION_CHANGE = "CONFIGURATION_CHANGE";
        public static final String START_LOGIN          = "START_LOGIN";
        public static final String AGREE_TAKE_SEAT      = "AGREE_TAKE_SEAT";
        public static final String DISAGREE_TAKE_SEAT   = "DISAGREE_TAKE_SEAT";
        public static final String INVITE_TAKE_SEAT     = "INVITE_TAKE_SEAT";

        public static final String SHOW_USER_MANAGEMENT          = "SHOW_USER_MANAGEMENT";
        public static final String DISMISS_USER_MANAGEMENT       = "DISMISS_USER_MANAGEMENT";
        public static final String SHOW_EXIT_ROOM_VIEW           = "SHOW_EXIT_ROOM_VIEW";
        public static final String DISMISS_EXIT_ROOM_VIEW        = "DISMISS_EXIT_ROOM_VIEW";
        public static final String DISMISS_MEETING_INFO          = "DISMISS_MEETING_INFO";
        public static final String SHOW_USER_LIST                = "SHOW_USER_LIST";
        public static final String DISMISS_USER_LIST             = "DISMISS_USER_LIST";
        public static final String SHOW_APPLY_LIST               = "SHOW_APPLY_LIST";
        public static final String DISMISS_APPLY_LIST            = "DISMISS_APPLY_LIST";
        public static final String SHOW_QRCODE_VIEW              = "SHOW_QRCODE_VIEW";
        public static final String DISMISS_QRCODE_VIEW           = "DISMISS_QRCODE_VIEW";
        public static final String SHOW_MEDIA_SETTING_PANEL      = "SHOW_MEDIA_SETTING_PANEL";
        public static final String DISMISS_MEDIA_SETTING_PANEL   = "DISMISS_MEDIA_SETTING_PANEL";
        public static final String SHOW_INVITE_PANEL             = "SHOW_INVITE_PANEL";
        public static final String DISMISS_INVITE_PANEL          = "DISMISS_INVITE_PANEL";
        public static final String SHOW_MORE_FUNCTION_PANEL      = "SHOW_MORE_FUNCTION_PANEL";
        public static final String DISMISS_MORE_FUNCTION_PANEL   = "DISMISS_INVITE_PANEL_SECOND";
        public static final String SHOW_SHARE_ROOM_PANEL         = "SHOW_SHARE_ROOM_PANEL";
        public static final String DISMISS_SHARE_ROOM_PANEL      = "DISMISS_SHARE_ROOM_PANEL";
        public static final String SHOW_SELECT_USER_TO_CALL_VIEW = "SHOW_SELECT_USER_TO_CALL_VIEW";
        public static final String SHOW_OWNER_EXIT_ROOM_PANEL    = "SHOW_OWNER_EXIT_ROOM_PANEL";
        public static final String DISMISS_OWNER_EXIT_ROOM_PANEL = "DISMISS_OWNER_EXIT_ROOM_PANEL";

        public static final String ENTER_FLOAT_WINDOW = "ENTER_FLOAT_WINDOW";
        public static final String EXIT_FLOAT_WINDOW  = "EXIT_FLOAT_WINDOW";

        public static final String SEND_IM_MSG_COMPLETE = "SEND_IM_MSG_COMPLETE";

        public static final String BAR_SHOW_TIME_RECOUNT        = "BAR_SHOW_TIME_RECOUNT";
        public static final String DISMISS_MAIN_ACTIVITY        = "DISMISS_MAIN_ACTIVITY";
        public static final String ENABLE_FLOAT_CHAT            = "ENABLE_FLOAT_CHAT";
        public static final String SCHEDULED_CONFERENCE_SUCCESS = "SCHEDULED_CONFERENCE_SUCCESS";

        public static final String DESTROY_INVITATION_RECEIVED_ACTIVITY = "DESTROY_INVITATION_RECEIVED_ACTIVITY";
        public static final String ENTER_PIP_MODE                       = "ENTER_PIP_MODE";
        public static final String EXIT_PIP_MODE                        = "EXIT_PIP_MODE";
    }

    public interface RoomEngineEventResponder {
        void onEngineEvent(RoomEngineEvent event, Map<String, Object> params);
    }

    public interface RoomKitUIEventResponder {
        void onNotifyUIEvent(String key, Map<String, Object> params);
    }

    public static ConferenceEventCenter getInstance() {
        return ConferenceEventCenter.LazyHolder.INSTANCE;
    }

    private static class LazyHolder {
        private static final ConferenceEventCenter INSTANCE = new ConferenceEventCenter();
    }

    private ConferenceEventCenter() {
        mEngineResponderMap = new ConcurrentHashMap<>();
        mUIEventResponderMap = new ConcurrentHashMap<>();
    }

    public void subscribeEngine(RoomEngineEvent event, RoomEngineEventResponder observer) {
        if (event == null || observer == null) {
            return;
        }
        if (mEngineResponderMap.containsKey(event)) {
            mEngineResponderMap.get(event).add(observer);
        } else {
            List<RoomEngineEventResponder> list = new CopyOnWriteArrayList<>();
            list.add(observer);
            mEngineResponderMap.put(event, list);
        }
    }

    public void unsubscribeEngine(RoomEngineEvent event, RoomEngineEventResponder observer) {
        if (observer == null) {
            return;
        }
        List<RoomEngineEventResponder> list = mEngineResponderMap.get(event);
        if (list == null) {
            return;
        }
        list.remove(observer);
    }

    public void subscribeUIEvent(String event, RoomKitUIEventResponder responder) {
        if (TextUtils.isEmpty(event) || responder == null) {
            return;
        }
        TUINotificationAdapter adapter = new TUINotificationAdapter(responder);
        if (mUIEventResponderMap.containsKey(event)) {
            mUIEventResponderMap.get(event).add(adapter);
        } else {
            List<TUINotificationAdapter> list = new CopyOnWriteArrayList<>();
            list.add(adapter);
            mUIEventResponderMap.put(event, list);
        }
        TUICore.registerEvent(RoomKitUIEvent.ROOM_KIT_EVENT, event, adapter);
    }

    public void notifyUIEvent(String event, Map<String, Object> params) {
        TUICore.notifyEvent(RoomKitUIEvent.ROOM_KIT_EVENT, event, params);
    }

    public void unsubscribeUIEvent(String event, RoomKitUIEventResponder responder) {
        if (TextUtils.isEmpty(event) || responder == null) {
            return;
        }
        List<TUINotificationAdapter> list = mUIEventResponderMap.get(event);
        if (list == null) {
            return;
        }
        TUINotificationAdapter notificationAdapter = null;
        Iterator<TUINotificationAdapter> iterator = list.iterator();
        while (iterator.hasNext()) {
            TUINotificationAdapter adapter = iterator.next();
            if (adapter != null && responder.equals(adapter.mResponder)) {
                notificationAdapter = adapter;
                break;
            }
        }
        list.remove(notificationAdapter);
        TUICore.unRegisterEvent(RoomKitUIEvent.ROOM_KIT_EVENT, event, notificationAdapter);
    }

    public void notifyEngineEvent(RoomEngineEvent event, Map<String, Object> params) {
        List<RoomEngineEventResponder> list = mEngineResponderMap.get(event);
        if (list == null) {
            return;
        }
        for (RoomEngineEventResponder roomEngineEventResponder : list) {
            roomEngineEventResponder.onEngineEvent(event, params);
            Log.d(TAG, "onEngineEvent : " + event);
        }
    }

    static class TUINotificationAdapter implements ITUINotification {
        private final RoomKitUIEventResponder mResponder;

        public TUINotificationAdapter(RoomKitUIEventResponder responder) {
            mResponder = responder;
        }

        @Override
        public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
            mResponder.onNotifyUIEvent(subKey, param);
        }
    }
}