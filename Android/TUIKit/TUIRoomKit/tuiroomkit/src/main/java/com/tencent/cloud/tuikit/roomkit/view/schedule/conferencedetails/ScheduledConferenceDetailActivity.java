package com.tencent.cloud.tuikit.roomkit.view.schedule.conferencedetails;

import android.os.Bundle;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant;

public class ScheduledConferenceDetailActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_scheduled_info);
        ViewGroup root = findViewById(R.id.ll_root_scheduled_info);
        String roomId = getIntent().getStringExtra(ConferenceConstant.KEY_CONFERENCE_ID);
        ScheduledConferenceDetailView conferenceInfoView = new ScheduledConferenceDetailView(this, roomId);
        root.addView(conferenceInfoView);
    }
}
