package com.tencent.cloud.tuikit.roomkit.view.activity;

import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;

import android.os.Bundle;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.view.component.EnterConferenceView;

import java.util.Map;

public class EnterConferenceActivity extends AppCompatActivity implements ConferenceEventCenter.RoomEngineEventResponder {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_enter_room);
        EnterConferenceView enterRoomView = new EnterConferenceView(this);
        ViewGroup root = findViewById(R.id.ll_root_enter_room);
        root.addView(enterRoomView);
        registerRoomEnteredEvent();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unRegisterRoomEnteredEvent();
    }

    private void registerRoomEnteredEvent() {
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_USER_ENTER_ROOM, this);
    }

    private void unRegisterRoomEnteredEvent() {
        ConferenceEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_ENTER_ROOM, this);
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        if (LOCAL_USER_ENTER_ROOM == event) {
            finish();
        }
    }
}
