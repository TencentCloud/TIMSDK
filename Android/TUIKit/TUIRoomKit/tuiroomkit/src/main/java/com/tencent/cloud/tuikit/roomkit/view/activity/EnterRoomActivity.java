package com.tencent.cloud.tuikit.roomkit.view.activity;

import android.os.Bundle;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.view.component.EnterRoomView;

import java.util.Map;

public class EnterRoomActivity extends AppCompatActivity implements RoomEventCenter.RoomKitUIEventResponder {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_enter_room);
        EnterRoomView enterRoomView = new EnterRoomView(this);
        ViewGroup root = findViewById(R.id.ll_root_enter_room);
        root.addView(enterRoomView);
        RoomEventCenter.getInstance().subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_ENTER_ROOM, this);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (RoomEventCenter.RoomKitUIEvent.EXIT_ENTER_ROOM.equals(key)) {
            finish();
        }
    }

    @Override
    protected void onDestroy() {
        RoomEventCenter.getInstance().unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_ENTER_ROOM, this);
        super.onDestroy();
    }
}
