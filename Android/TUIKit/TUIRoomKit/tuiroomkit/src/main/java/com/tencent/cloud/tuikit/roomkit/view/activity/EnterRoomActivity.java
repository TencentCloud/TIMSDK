package com.tencent.cloud.tuikit.roomkit.view.activity;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKitListener;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.view.component.EnterRoomView;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;

import java.util.Map;

public class EnterRoomActivity extends AppCompatActivity
        implements RoomEventCenter.RoomKitUIEventResponder, ITUINotification {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_enter_room);
        EnterRoomView enterRoomView = new EnterRoomView(this);
        ViewGroup root = findViewById(R.id.ll_root_enter_room);
        root.addView(enterRoomView);
        RoomEventCenter.getInstance().subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_ENTER_ROOM, this);
        registerRoomEnteredEvent();
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
        unRegisterRoomEnteredEvent();
    }

    private void registerRoomEnteredEvent() {
        TUICore.registerEvent(RoomEventCenter.RoomEngineMessage.ROOM_ENGINE_MSG,
                RoomEventCenter.RoomEngineMessage.ROOM_ENTERED, this);
    }

    private void unRegisterRoomEnteredEvent() {
        TUICore.unRegisterEvent(RoomEventCenter.RoomEngineMessage.ROOM_ENGINE_MSG,
                RoomEventCenter.RoomEngineMessage.ROOM_ENTERED, this);
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TextUtils.equals(key, RoomEventCenter.RoomEngineMessage.ROOM_ENGINE_MSG) && TextUtils.equals(subKey,
                RoomEventCenter.RoomEngineMessage.ROOM_ENTERED)) {
            finish();
            return;
        }
    }
}
