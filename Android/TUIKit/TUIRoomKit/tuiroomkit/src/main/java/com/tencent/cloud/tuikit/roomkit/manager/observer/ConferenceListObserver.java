package com.tencent.cloud.tuikit.roomkit.manager.observer;

import static com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager.ConferenceModifyFlag.ROOM_NAME;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.state.RoomState;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ConferenceListObserver extends TUIConferenceListManager.Observer {
    private static final String TAG = "ConferenceListObserver";

    private final RoomState mRoomState;

    public ConferenceListObserver(ConferenceState conferenceState) {
        mRoomState = conferenceState.roomState;
    }

    @Override
    public void onConferenceInfoChanged(TUIConferenceListManager.ConferenceInfo conferenceInfo, List<TUIConferenceListManager.ConferenceModifyFlag> modifyFlagList) {
        Log.d(TAG, "onConferenceInfoChanged conferenceId=" + conferenceInfo.basicRoomInfo.roomId + " name=" + conferenceInfo.basicRoomInfo.name);
        if (!TextUtils.equals(mRoomState.roomId.get(), conferenceInfo.basicRoomInfo.roomId)) {
            return;
        }
        if (!isConferenceNameChanged(modifyFlagList)) {
            return;
        }

        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_ROOM_ID, conferenceInfo.basicRoomInfo.roomId);
        map.put(ConferenceEventConstant.KEY_ROOM_NAME, conferenceInfo.basicRoomInfo.name);
        mRoomState.roomName.set(conferenceInfo.basicRoomInfo.name);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.ROOM_NAME_CHANGED, map);
    }

    private boolean isConferenceNameChanged(List<TUIConferenceListManager.ConferenceModifyFlag> modifyFlagList) {
        for (TUIConferenceListManager.ConferenceModifyFlag flag : modifyFlagList) {
            if (flag == ROOM_NAME) {
                return true;
            }
        }
        return false;
    }
}
