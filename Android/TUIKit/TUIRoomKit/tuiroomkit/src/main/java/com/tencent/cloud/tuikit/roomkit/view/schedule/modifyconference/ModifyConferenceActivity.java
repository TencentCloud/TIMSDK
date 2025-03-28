package com.tencent.cloud.tuikit.roomkit.view.schedule.modifyconference;

import android.os.Bundle;
import android.text.TextUtils;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant;

public class ModifyConferenceActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String conferenceId = getIntent().getStringExtra(ConferenceConstant.KEY_CONFERENCE_ID);
        if (TextUtils.isEmpty(conferenceId)) {
            finish();
            return;
        }
        ModifyConferenceView modifyConferenceView = new ModifyConferenceView(this);
        modifyConferenceView.setConferenceId(conferenceId);
        setContentView(modifyConferenceView);
    }
}
