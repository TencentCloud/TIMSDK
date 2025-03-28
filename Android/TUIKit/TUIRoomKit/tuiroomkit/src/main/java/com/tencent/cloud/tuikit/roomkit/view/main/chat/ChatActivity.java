package com.tencent.cloud.tuikit.roomkit.view.main.chat;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM;

import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;

import java.util.HashMap;
import java.util.Map;

public class ChatActivity extends AppCompatActivity {
    private static final String TAG = "ChatActivity";
    private ConferenceEventCenter.RoomEngineEventResponder mEngineEventObserver = new ConferenceEventCenter.RoomEngineEventResponder() {
        @Override
        public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
            if (event == KICKED_OUT_OF_ROOM) {
                ChatActivity.this.finish();
            }
        }
    };

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate : " + this);
        initStatusBar();
        initView();
        ConferenceEventCenter.getInstance().subscribeEngine(KICKED_OUT_OF_ROOM, mEngineEventObserver);
    }

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        initStatusBar();
        initView();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        ConferenceEventCenter.getInstance().unsubscribeEngine(KICKED_OUT_OF_ROOM, mEngineEventObserver);
        Log.d(TAG, "onDestroy : " + this);
    }

    private void initView() {
        setContentView(R.layout.tuiroomkit_activity_chat);
        findViewById(R.id.tuiroomKit_btn_dismiss).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ChatActivity.this.finish();
            }
        });

        Map map = new HashMap();
        map.put(TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_ROOM, false);
        map.put(TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_AUDIO_CALL, false);
        map.put(TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_VIDEO_CALL, false);
        map.put(TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_TAKE_PHOTO, false);
        map.put(TUIConstants.TUIChat.ObjectFactory.ChatFragment.ENABLE_RECORD_VIDEO, false);
        map.put(TUIConstants.TUIChat.ObjectFactory.ChatFragment.CHAT_ID,
                ConferenceController.sharedInstance().getConferenceState().roomInfo.roomId);
        map.put(TUIConstants.TUIChat.ObjectFactory.ChatFragment.CHAT_TYPE,
                TUIConstants.TUIChat.ObjectFactory.ChatFragment.CHAT_TYPE_GROUP);
        map.put(TUIConstants.TUIChat.ObjectFactory.ChatFragment.CHAT_TITLE, getString(R.string.tuiroomkit_item_chat));
        Object object = TUICore.createObject(TUIConstants.TUIChat.ObjectFactory.OBJECT_FACTORY_NAME,
                TUIConstants.TUIChat.ObjectFactory.ChatFragment.OBJECT_NAME, map);
        if (object == null || !(object instanceof Fragment)) {
            finish();
            return;
        }
        getSupportFragmentManager().beginTransaction()
                .add(R.id.tuiroomkit_fl_chat_fragment_container, (Fragment) object).commitAllowingStateLoss();
    }

    private void initStatusBar() {
        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                    WindowManager.LayoutParams.FLAG_FULLSCREEN);
            return;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            getWindow().setStatusBarColor(getResources().getColor(
                    TUIThemeManager.getAttrResId(this, com.tencent.qcloud.tuicore.R.attr.core_header_start_color)));
            getWindow().setNavigationBarColor(getResources().getColor(
                    com.tencent.cloud.tuikit.roomkit.R.color.tuiroomkit_chat_navigation_bar_color));
            int vis = getWindow().getDecorView().getSystemUiVisibility();
            vis |= View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
            vis |= View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
            getWindow().getDecorView().setSystemUiVisibility(vis);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }
}
