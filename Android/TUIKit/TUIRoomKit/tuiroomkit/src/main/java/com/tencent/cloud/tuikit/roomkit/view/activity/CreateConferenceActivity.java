package com.tencent.cloud.tuikit.roomkit.view.activity;

import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;

import android.os.Bundle;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.view.component.CreateConferenceView;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;

import java.util.Map;

public class CreateConferenceActivity extends AppCompatActivity implements ConferenceEventCenter.RoomEngineEventResponder {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_create_room);
        CreateConferenceView createRoomView = new CreateConferenceView(this);
        ViewGroup root = findViewById(R.id.ll_root_create_room);
        root.addView(createRoomView);
        createRoomView.setFinishCallback(new TUICallback() {
            @Override
            public void onSuccess() {
                finish();
            }

            @Override
            public void onError(int errorCode, String errorMessage) {

            }
        });
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
            return;
        }
    }
}
