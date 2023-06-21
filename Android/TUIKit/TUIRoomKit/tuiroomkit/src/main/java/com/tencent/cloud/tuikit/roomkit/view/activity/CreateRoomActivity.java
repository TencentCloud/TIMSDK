package com.tencent.cloud.tuikit.roomkit.view.activity;

import android.os.Bundle;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.view.component.CreateRoomView;

import java.util.Map;

public class CreateRoomActivity extends AppCompatActivity implements RoomEventCenter.RoomKitUIEventResponder {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_create_room);
        CreateRoomView createRoomView = new CreateRoomView(this);
        ViewGroup root = findViewById(R.id.ll_root_create_room);
        root.addView(createRoomView);
        RoomEventCenter.getInstance().subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_CREATE_ROOM, this);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (RoomEventCenter.RoomKitUIEvent.EXIT_CREATE_ROOM.equals(key)) {
            finish();
        }
    }

    @Override
    protected void onDestroy() {
        RoomEventCenter.getInstance().unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_CREATE_ROOM, this);
        super.onDestroy();
    }
}
