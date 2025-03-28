package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.view;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.Switch;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.RoomSpUtil;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;

public class Chat2RoomExtensionSettingsActivity extends BaseLightActivity {
    private static final String TAG = "C2RSettingsActivity";

    private TitleBarLayout mTitleBarLayout;
    private Switch         mMicrophoneSwitch;
    private Switch         mCameraSwitch;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate");
        setContentView(R.layout.tuiroomkit_room_setting_layout);
        initTitleBar();
        initSettingsView();
    }

    private void initTitleBar() {
        mTitleBarLayout = findViewById(R.id.tuiroomkit_chat_settings_top_bar);
        mTitleBarLayout.setTitle(getResources().getString(R.string.tuiroomkit_chat_access_room_extension_settings),
                ITitleBarLayout.Position.MIDDLE);
        mTitleBarLayout.getLeftGroup().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mTitleBarLayout.getRightIcon().setVisibility(View.GONE);
    }

    private void initSettingsView() {
        mMicrophoneSwitch = findViewById(R.id.tuiroomkit_chat_settings_microphone);
        mCameraSwitch = findViewById(R.id.tuiroomkit_chat_settings_camera);

        mMicrophoneSwitch.setChecked(RoomSpUtil.getAudioSwitchFromSp());
        mCameraSwitch.setChecked(RoomSpUtil.getVideoSwitchFromSp());

        mMicrophoneSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                RoomSpUtil.saveAudioSwitchToSp(isChecked);
            }
        });
        mCameraSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                RoomSpUtil.saveVideoSwitchToSp(isChecked);
            }
        });
    }
}
