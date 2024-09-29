package com.tencent.cloud.tuikit.roomkit.model.manager;

import static com.tencent.cloud.tuikit.roomkit.ConferenceDefine.ConferenceFinishedReason.FINISHED_BY_SERVER;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_CONFERENCE;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_CONFERENCE_FINISHED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_REASON;

import android.util.Log;

import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceState;
import com.tencent.qcloud.tuicore.TUICore;
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

        Map<String, Object> param = new HashMap<>(2);
        param.put(KEY_CONFERENCE, store.roomState.roomInfo);
        param.put(KEY_REASON, FINISHED_BY_SERVER);
        TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_FINISHED, param);
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
