package com.tencent.cloud.tuikit.roomkit.view.activity;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentTransaction;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.ScheduleConferenceFragment;

public class ScheduleConferenceActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_activity_schedule_conference);
        ScheduleConferenceFragment fragment = new ScheduleConferenceFragment();
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.add(R.id.tuiroomkit_fl_schedule_conference, fragment);
        transaction.commitAllowingStateLoss();
    }
}
