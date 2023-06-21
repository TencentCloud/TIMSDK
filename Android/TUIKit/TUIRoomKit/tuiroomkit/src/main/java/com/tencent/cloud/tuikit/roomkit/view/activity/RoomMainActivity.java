package com.tencent.cloud.tuikit.roomkit.view.activity;

import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.view.component.RoomMainView;

import java.util.Map;

public class RoomMainActivity extends AppCompatActivity implements RoomEventCenter.RoomKitUIEventResponder {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_meeting);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        initStatusBar();
        RoomMainView meetingView = new RoomMainView(this);
        ViewGroup rootView = findViewById(R.id.root_view);
        rootView.addView(meetingView);
        RoomEventCenter.getInstance().subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_MEETING, this);
    }

    @Override
    public void onBackPressed() {
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW, null);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        RoomEventCenter.getInstance().unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_MEETING, this);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (RoomEventCenter.RoomKitUIEvent.EXIT_MEETING.equals(key)) {
            finish();
        }
    }

    private void initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }
}
