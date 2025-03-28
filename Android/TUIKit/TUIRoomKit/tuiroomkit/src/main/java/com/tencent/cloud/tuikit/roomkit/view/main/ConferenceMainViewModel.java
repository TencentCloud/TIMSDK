package com.tencent.cloud.tuikit.roomkit.view.main;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_DESTROY_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_EXIT_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_MAIN_ACTIVITY;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.ENTER_FLOAT_WINDOW;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;

import java.util.Map;

public class ConferenceMainViewModel implements ConferenceEventCenter.RoomEngineEventResponder, ConferenceEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "ConferenceMainViewModel";

    private final ConferenceMainFragment mFragment;

    public interface GetConferenceInfoCallback {
        public void onSuccess(TUIRoomDefine.RoomInfo roomInfo);

        public void onError(TUIRoomDefine.RoomInfo roomInfo, TUICommonDefine.Error error, String message);
    }

    public ConferenceMainViewModel(ConferenceMainFragment fragment) {
        Log.d(TAG, "new : " + this);
        mFragment = fragment;
    }

    public void init() {
        Log.d(TAG, "init : " + this);
        subscribeEvent();
    }

    public void release() {
        Log.d(TAG, "release : " + this);
        unSubscribeEvent();
    }

    public void startConference(ConferenceDefine.StartConferenceParams params, @NonNull GetConferenceInfoCallback callback) {
        TUIRoomDefine.RoomInfo roomInfo = new TUIRoomDefine.RoomInfo();
        roomInfo.roomId = params.roomId;
        roomInfo.isMicrophoneDisableForAllUser = params.isMicrophoneDisableForAllUser;
        roomInfo.isCameraDisableForAllUser = params.isCameraDisableForAllUser;
        roomInfo.isSeatEnabled = params.isSeatEnabled;
        roomInfo.seatMode = TUIRoomDefine.SeatMode.APPLY_TO_TAKE;
        roomInfo.password = params.password;
        roomInfo.name = params.name;

        ConferenceController controller = ConferenceController.sharedInstance();
        controller.createRoom(roomInfo, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                controller.enterRoom(roomInfo.roomId, params.isOpenMicrophone, params.isOpenCamera, params.isOpenSpeaker, new TUIRoomDefine.GetRoomInfoCallback() {
                    @Override
                    public void onSuccess(TUIRoomDefine.RoomInfo engineRoomInfo) {
                        callback.onSuccess(engineRoomInfo);
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        callback.onError(roomInfo, error, message);
                    }
                });
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                callback.onError(roomInfo, error, message);
            }
        });
    }

    public void joinConference(ConferenceDefine.JoinConferenceParams params, @NonNull GetConferenceInfoCallback callback) {
        ConferenceController.sharedInstance().enterRoom(params.roomId, params.isOpenMicrophone, params.isOpenCamera, params.isOpenSpeaker, new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo engineRoomInfo) {
                callback.onSuccess(engineRoomInfo);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                TUIRoomDefine.RoomInfo roomInfo = new TUIRoomDefine.RoomInfo();
                roomInfo.roomId = params.roomId;
                callback.onError(roomInfo, error, message);
            }
        });
    }

    public void joinEncryptRoom(ConferenceDefine.JoinConferenceParams params, String password, @NonNull GetConferenceInfoCallback callback) {
        ConferenceController.sharedInstance().enterEncryptRoom(params.roomId, params.isOpenMicrophone, params.isOpenCamera, params.isOpenSpeaker, password, new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo engineRoomInfo) {
                callback.onSuccess(engineRoomInfo);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                TUIRoomDefine.RoomInfo roomInfo = new TUIRoomDefine.RoomInfo();
                roomInfo.roomId = params.roomId;
                callback.onError(roomInfo, error, message);
            }
        });
    }

    public void cacheCurrentActivity(Activity activity) {
        ConferenceState store = ConferenceController.sharedInstance().getConferenceState();
        store.setMainActivityClass(activity.getClass());
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        Log.d(TAG, "onNotifyUIEvent key=" + key);
        if (ENTER_FLOAT_WINDOW.equals(key) || DISMISS_MAIN_ACTIVITY.equals(key)) {
            mFragment.onDismiss();
        }
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        Log.d(TAG, "onEngineEvent event=" + event);
        if (event != LOCAL_USER_EXIT_ROOM && event != LOCAL_USER_DESTROY_ROOM) {
            return;
        }
        mFragment.onDismiss();
    }

    private void subscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.subscribeEngine(LOCAL_USER_DESTROY_ROOM, this);
        eventCenter.subscribeEngine(LOCAL_USER_EXIT_ROOM, this);

        eventCenter.subscribeUIEvent(ENTER_FLOAT_WINDOW, this);
        eventCenter.subscribeUIEvent(DISMISS_MAIN_ACTIVITY, this);
    }

    private void unSubscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.unsubscribeEngine(LOCAL_USER_DESTROY_ROOM, this);
        eventCenter.unsubscribeEngine(LOCAL_USER_EXIT_ROOM, this);

        eventCenter.unsubscribeUIEvent(ENTER_FLOAT_WINDOW, this);
        eventCenter.unsubscribeUIEvent(DISMISS_MAIN_ACTIVITY, this);
    }
}
