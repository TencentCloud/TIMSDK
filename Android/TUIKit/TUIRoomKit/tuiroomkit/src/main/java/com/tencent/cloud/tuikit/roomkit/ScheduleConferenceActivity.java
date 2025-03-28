package com.tencent.cloud.tuikit.roomkit;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.ScheduleConferenceView;


public class ScheduleConferenceActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(new ScheduleConferenceView(this));
    }
}
