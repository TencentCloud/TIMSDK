package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_DESTROY_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_EXIT_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISMISS_MAIN_ACTIVITY;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.ENTER_FLOAT_WINDOW;

import android.app.Activity;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceError;
import com.tencent.cloud.tuikit.roomkit.ConferenceMainFragment;
import com.tencent.cloud.tuikit.roomkit.ConferenceObserver;
import com.tencent.cloud.tuikit.roomkit.ConferenceParams;
import com.tencent.cloud.tuikit.roomkit.ConferenceSession;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;

import java.util.Map;

public class ConferenceMainViewModel
        implements RoomEventCenter.RoomEngineEventResponder, RoomEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "ConferenceMainViewModel";

    private final ConferenceMainFragment mFragment;

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

    public void quickStartConference(String id, ConferenceParams params) {
        TUIRoomDefine.ActionCallback callback = new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                ConferenceObserver observer = RoomEngineManager.sharedInstance().getRoomStore().getConferenceObserver();
                if (observer != null) {
                    Log.i(TAG, "onConferenceStarted onSuccess conferenceId=" + id);
                    observer.onConferenceStarted(id, ConferenceError.SUCCESS);
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                ConferenceObserver observer = RoomEngineManager.sharedInstance().getRoomStore().getConferenceObserver();
                if (observer != null) {
                    ConferenceError err = transferError(error);
                    Log.i(TAG, "onConferenceStarted onError conferenceId=" + id + " error=" + err);
                    observer.onConferenceStarted(id, err);
                }
            }
        };
        if (TextUtils.isEmpty(id) && !TextUtils.isEmpty(
                RoomEngineManager.sharedInstance().getRoomStore().roomInfo.roomId)) {
            callback.onSuccess();
            return;
        }
        ConferenceSession.newInstance(id)
                .setMuteMicrophone(params.isMuteMicrophone())
                .setOpenCamera(params.isOpenCamera())
                .setSoundOnSpeaker(params.isSoundOnSpeaker())
                .setName(params.getName())
                .setEnableMicrophoneForAllUser(params.isEnableMicrophoneForAllUser())
                .setEnableCameraForAllUser(params.isEnableCameraForAllUser())
                .setEnableMessageForAllUser(params.isEnableMessageForAllUser())
                .setEnableSeatControl(params.isEnableSeatControl())
                .setActionCallback(callback)
                .quickStart();
    }

    public void joinConference(String id, ConferenceParams params) {
        TUIRoomDefine.ActionCallback callback = new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                ConferenceObserver observer = RoomEngineManager.sharedInstance().getRoomStore().getConferenceObserver();
                if (observer != null) {
                    Log.i(TAG, "onConferenceJoined onSuccess conferenceId=" + id);
                    observer.onConferenceJoined(id, ConferenceError.SUCCESS);
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                ConferenceObserver observer = RoomEngineManager.sharedInstance().getRoomStore().getConferenceObserver();
                if (observer != null) {
                    ConferenceError err = transferError(error);
                    Log.i(TAG, "onConferenceJoined onError conferenceId=" + id + " error=" + err);
                    observer.onConferenceJoined(id, err);
                }
            }
        };
        if (TextUtils.isEmpty(id) && !TextUtils.isEmpty(
                RoomEngineManager.sharedInstance().getRoomStore().roomInfo.roomId)) {
            callback.onSuccess();
            return;
        }
        ConferenceSession.newInstance(id)
                .setMuteMicrophone(params.isMuteMicrophone())
                .setOpenCamera(params.isOpenCamera())
                .setSoundOnSpeaker(params.isSoundOnSpeaker())
                .setActionCallback(callback)
                .join();
    }

    public void cacheCurrentActivity(Activity activity) {
        RoomStore store = RoomEngineManager.sharedInstance().getRoomStore();
        store.setMainActivityClass(activity.getClass());
    }

    public void cacheConferenceObserver(ConferenceObserver observer) {
        RoomStore store = RoomEngineManager.sharedInstance().getRoomStore();
        store.setConferenceObserver(observer);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        Log.d(TAG, "onNotifyUIEvent key=" + key);
        if (ENTER_FLOAT_WINDOW.equals(key) || DISMISS_MAIN_ACTIVITY.equals(key)) {
            mFragment.onDismiss();
        }
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        Log.d(TAG, "onEngineEvent event=" + event);
        if (event != LOCAL_USER_EXIT_ROOM && event != LOCAL_USER_DESTROY_ROOM) {
            return;
        }
        mFragment.onDismiss();
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(LOCAL_USER_DESTROY_ROOM, this);
        eventCenter.subscribeEngine(LOCAL_USER_EXIT_ROOM, this);

        eventCenter.subscribeUIEvent(ENTER_FLOAT_WINDOW, this);
        eventCenter.subscribeUIEvent(DISMISS_MAIN_ACTIVITY, this);
    }

    private void unSubscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(LOCAL_USER_DESTROY_ROOM, this);
        eventCenter.unsubscribeEngine(LOCAL_USER_EXIT_ROOM, this);

        eventCenter.unsubscribeUIEvent(ENTER_FLOAT_WINDOW, this);
        eventCenter.unsubscribeUIEvent(DISMISS_MAIN_ACTIVITY, this);
    }

    private ConferenceError transferError(TUICommonDefine.Error error) {
        if (error == TUICommonDefine.Error.SUCCESS) {
            return ConferenceError.SUCCESS;
        }
        if (error == TUICommonDefine.Error.ROOM_ID_NOT_EXIST) {
            return ConferenceError.CONFERENCE_ID_NOT_EXIST;
        }
        if (error == TUICommonDefine.Error.ROOM_ID_INVALID) {
            return ConferenceError.CONFERENCE_ID_INVALID;
        }
        if (error == TUICommonDefine.Error.ROOM_ID_OCCUPIED) {
            return ConferenceError.CONFERENCE_ID_OCCUPIED;
        }
        if (error == TUICommonDefine.Error.ROOM_NAME_INVALID) {
            return ConferenceError.CONFERENCE_NAME_INVALID;
        }
        return ConferenceError.FAILED;
    }
}
