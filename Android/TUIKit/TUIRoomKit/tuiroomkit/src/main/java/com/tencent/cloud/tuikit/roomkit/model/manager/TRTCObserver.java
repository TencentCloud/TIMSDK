package com.tencent.cloud.tuikit.roomkit.model.manager;

import android.util.Log;

import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.ConferenceObserver;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.trtc.TRTCCloudListener;

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
        RoomStore store = RoomEngineManager.sharedInstance().getRoomStore();
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_ROOM_ID, store.roomInfo.roomId);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.ROOM_DISMISSED, map);

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
}
