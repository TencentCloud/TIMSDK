package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.view.WindowManager;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.base.Constants;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.TUILiveRoomAudienceLayout;

public class DefaultGroupLiveAudienceActivity extends AppCompatActivity {
    private static final String TAG = "DefaultGroupLiveAudienceActivity";

    private TUILiveRoomAudienceLayout mTUILiveRoomAudienceLayout;

    public static void start(Context context) {
        Intent starter = new Intent(context, DefaultGroupLiveAudienceActivity.class);
        context.startActivity(starter);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setTurnScreenOn(true);
        } else {
        }
        setContentView(R.layout.live_activity_default_gourp_live_audience);

        initLiveRoomAudienceLayout();
        initLiveRoomAudienceLayoutDelegate();
    }

    private void initLiveRoomAudienceLayout() {
        mTUILiveRoomAudienceLayout = findViewById(R.id.layout_room_audience);

        Intent intent = getIntent();
        int roomId = intent.getIntExtra(Constants.GROUP_ID, 0);
        String anchorId = intent.getStringExtra(Constants.ANCHOR_ID);

        mTUILiveRoomAudienceLayout.initWithRoomId(getSupportFragmentManager(), roomId, anchorId, false, "");
    }

    private void initLiveRoomAudienceLayoutDelegate() {
        mTUILiveRoomAudienceLayout.setLiveRoomAudienceDelegate(new TUILiveRoomAudienceLayout.TUILiveRoomAudienceDelegate() {
            @Override
            public void onClose() {
                finish();
            }

            @Override
            public void onError(int errorCode, String message) {

            }
        });
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        mTUILiveRoomAudienceLayout.onBackPressed();
    }
}