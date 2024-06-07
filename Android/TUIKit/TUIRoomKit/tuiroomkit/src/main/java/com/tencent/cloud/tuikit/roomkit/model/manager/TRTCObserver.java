package com.tencent.cloud.tuikit.roomkit.model.manager;

import android.util.Log;

import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.ConferenceObserver;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceState;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.TRTCStatistics;

import java.util.HashMap;
import java.util.Map;

public class TRTCObserver extends TRTCCloudListener {
    private static final String TAG = "TRTCObserver";

    @Override
    public void onExitRoom(int reason) {
        Log.d(TAG, "onExitRoom reason=" + reason);
        if (reason != 2) {
            return;
        }
        ConferenceState store = ConferenceController.sharedInstance().getConferenceState();
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, store.roomInfo.roomId);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.ROOM_DISMISSED, map);

        ConferenceObserver observer = store.getConferenceObserver();
        if (observer != null) {
            Log.i(TAG, "onConferenceFinished : " + store.roomInfo.roomId);
            observer.onConferenceFinished(store.roomInfo.roomId);
        }
        TUIRoomEngine.destroySharedInstance();
    }

    @Override
    public void onConnectionLost() {
        Log.d(TAG, "onConnectionLost");
    }

    @Override
    public void onTryToReconnect() {
        Log.d(TAG, "onTryToReconnect");
    }

    @Override
    public void onConnectionRecovery() {
        Log.d(TAG, "onConnectionRecovery");
    }

    @Override
    public void onStatistics(TRTCStatistics statistics) {
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ON_STATISTICS, statistics);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.ON_STATISTICS, map);
    }

}
