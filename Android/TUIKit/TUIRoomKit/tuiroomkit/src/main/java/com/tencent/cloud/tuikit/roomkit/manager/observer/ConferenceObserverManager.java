package com.tencent.cloud.tuikit.roomkit.manager.observer;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_ERROR;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_EXITED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_FINISHED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_INFO;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_JOINED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_MESSAGE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_STARTED;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

public class ConferenceObserverManager implements ITUINotification {
    private static final String TAG = "ConferenceObserverMg";

    private final List<ConferenceDefine.ConferenceObserver> mObserverList = new CopyOnWriteArrayList<>();

    public ConferenceObserverManager() {
        registerEvent();
    }

    public void destroy() {
        unRegisterEvent();
    }

    public void addObserver(ConferenceDefine.ConferenceObserver observer) {
        Log.i(TAG, "addObserver : " + observer);
        if (observer != null && !mObserverList.contains(observer)) {
            mObserverList.add(observer);
        }
    }

    public void removeObserver(ConferenceDefine.ConferenceObserver observer) {
        Log.i(TAG, "removeObserver : " + observer);
        if (observer != null) {
            mObserverList.remove(observer);
        }
    }

    private void registerEvent() {
        TUICore.registerEvent(KEY_CONFERENCE, KEY_CONFERENCE_STARTED, this);
        TUICore.registerEvent(KEY_CONFERENCE, KEY_CONFERENCE_JOINED, this);
        TUICore.registerEvent(KEY_CONFERENCE, KEY_CONFERENCE_EXITED, this);
        TUICore.registerEvent(KEY_CONFERENCE, KEY_CONFERENCE_FINISHED, this);
    }

    private void unRegisterEvent() {
        TUICore.unRegisterEvent(KEY_CONFERENCE, KEY_CONFERENCE_STARTED, this);
        TUICore.unRegisterEvent(KEY_CONFERENCE, KEY_CONFERENCE_JOINED, this);
        TUICore.unRegisterEvent(KEY_CONFERENCE, KEY_CONFERENCE_EXITED, this);
        TUICore.unRegisterEvent(KEY_CONFERENCE, KEY_CONFERENCE_FINISHED, this);
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        handleEventConferenceStarted(subKey, param);
        handleEventConferenceJoined(subKey, param);
        handleEventConferenceExited(subKey, param);
        handleEventConferenceFinished(subKey, param);
    }

    private void handleEventConferenceStarted(String subKey, Map<String, Object> param) {
        if (!TextUtils.equals(subKey, KEY_CONFERENCE_STARTED)) {
            return;
        }
        TUIRoomDefine.RoomInfo roomInfo = (TUIRoomDefine.RoomInfo) param.get(KEY_CONFERENCE_INFO);
        TUICommonDefine.Error error = (TUICommonDefine.Error) param.get(KEY_CONFERENCE_ERROR);
        String message = (String) param.get(KEY_CONFERENCE_MESSAGE);
        for (ConferenceDefine.ConferenceObserver observer : mObserverList) {
            observer.onConferenceStarted(roomInfo, error, message);
        }
    }

    private void handleEventConferenceJoined(String subKey, Map<String, Object> param) {
        if (!TextUtils.equals(subKey, KEY_CONFERENCE_JOINED)) {
            return;
        }
        TUIRoomDefine.RoomInfo roomInfo = (TUIRoomDefine.RoomInfo) param.get(KEY_CONFERENCE_INFO);
        TUICommonDefine.Error error = (TUICommonDefine.Error) param.get(KEY_CONFERENCE_ERROR);
        String message = (String) param.get(KEY_CONFERENCE_MESSAGE);
        for (ConferenceDefine.ConferenceObserver observer : mObserverList) {
            observer.onConferenceJoined(roomInfo, error, message);
        }
    }

    private void handleEventConferenceExited(String subKey, Map<String, Object> param) {
        if (!TextUtils.equals(subKey, KEY_CONFERENCE_EXITED)) {
            return;
        }
        TUIRoomDefine.RoomInfo roomInfo = (TUIRoomDefine.RoomInfo) param.get(ConferenceEventConstant.KEY_CONFERENCE);
        ConferenceDefine.ConferenceExitedReason reason = (ConferenceDefine.ConferenceExitedReason) param.get(ConferenceEventConstant.KEY_REASON);
        assert roomInfo != null;
        Log.i(TAG, "onConferenceExited roomId=" + roomInfo.roomId + " ownerId=" + roomInfo.ownerId + " roomName=" + roomInfo.name + " reason=" + reason);
        for (ConferenceDefine.ConferenceObserver observer : mObserverList) {
            observer.onConferenceExited(roomInfo, reason);
        }
    }

    private void handleEventConferenceFinished(String subKey, Map<String, Object> param) {
        if (!TextUtils.equals(subKey, KEY_CONFERENCE_FINISHED)) {
            return;
        }
        TUIRoomDefine.RoomInfo roomInfo = (TUIRoomDefine.RoomInfo) param.get(ConferenceEventConstant.KEY_CONFERENCE);
        ConferenceDefine.ConferenceFinishedReason reason = (ConferenceDefine.ConferenceFinishedReason) param.get(ConferenceEventConstant.KEY_REASON);
        assert roomInfo != null;
        Log.i(TAG, "onConferenceFinished roomId=" + roomInfo.roomId + " ownerId=" + roomInfo.ownerId + " roomName=" + roomInfo.name + " reason=" + reason);
        for (ConferenceDefine.ConferenceObserver observer : mObserverList) {
            observer.onConferenceFinished(roomInfo, reason);
        }
    }
}
