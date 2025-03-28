package com.tencent.cloud.tuikit.roomkit;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.ROOM_ID_NOT_EXIST;
import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.KEY_ERROR;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.UPDATE_CONFERENCE_LIST;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.ScheduleController;
import com.tencent.cloud.tuikit.roomkit.view.schedule.conferencelist.ScheduledConferenceListView;

import java.util.Map;

public class ConferenceListFragment extends Fragment implements ConferenceEventCenter.RoomEngineEventResponder {
    private static final String TAG = "ConferenceListFragment";

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate");
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_USER_ENTER_ROOM, this);
        ConferenceEventCenter.getInstance().subscribeEngine(UPDATE_CONFERENCE_LIST, this);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return new ScheduledConferenceListView(requireContext());
    }

    @Override
    public void onStart() {
        super.onStart();
        Log.d(TAG, "onStart");
        ScheduleController.sharedInstance().loginEngine(new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                ScheduleController.sharedInstance().refreshRequiredConferences(null);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
            }
        });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy");
        ScheduleController.sharedInstance().clearRequiredConferences();
        ConferenceEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_ENTER_ROOM, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(UPDATE_CONFERENCE_LIST, this);
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        handleLocalUserEnterRoom(event, params);
        handleUpdateConferenceList(event);
    }

    private void handleLocalUserEnterRoom(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        if (LOCAL_USER_ENTER_ROOM == event) {
            TUICommonDefine.Error error = (TUICommonDefine.Error) params.get(KEY_ERROR);
            Log.i(TAG, "onEngineEvent error=" + error);
            if (error != ROOM_ID_NOT_EXIST) {
                return;
            }
            ScheduleController.sharedInstance().refreshRequiredConferences(null);
        }
    }

    private void handleUpdateConferenceList(ConferenceEventCenter.RoomEngineEvent event) {
        if (UPDATE_CONFERENCE_LIST == event) {
            ScheduleController.sharedInstance().refreshRequiredConferences(null);
        }
    }
}
