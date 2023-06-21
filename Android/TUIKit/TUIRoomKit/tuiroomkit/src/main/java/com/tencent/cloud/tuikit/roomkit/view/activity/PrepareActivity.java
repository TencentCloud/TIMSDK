package com.tencent.cloud.tuikit.roomkit.view.activity;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.view.ViewGroup;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.view.component.PrepareView;

import java.util.Map;

public class PrepareActivity extends AppCompatActivity implements RoomEventCenter.RoomKitUIEventResponder {
    public static final String INTENT_ENABLE_PREVIEW = "enablePreview";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_prepare);
        ViewGroup root = findViewById(R.id.ll_root);
        boolean enablePreview = getIntent().getBooleanExtra(INTENT_ENABLE_PREVIEW, true);
        PrepareView prepareView = new PrepareView(this, enablePreview);
        root.addView(prepareView);
        RoomEventCenter.getInstance().subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_PREPARE_ACTIVITY, this);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (RoomEventCenter.RoomKitUIEvent.EXIT_PREPARE_ACTIVITY.equals(key)) {
            finish();
        }
    }

    @Override
    protected void onDestroy() {
        RoomEventCenter.getInstance().unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_PREPARE_ACTIVITY, this);
        super.onDestroy();
    }
}