package com.tencent.cloud.tuikit.roomkit.view.activity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.tencent.cloud.tuikit.roomkit.ConferenceError;
import com.tencent.cloud.tuikit.roomkit.ConferenceMainFragment;
import com.tencent.cloud.tuikit.roomkit.ConferenceObserver;
import com.tencent.cloud.tuikit.roomkit.ConferenceParams;
import com.tencent.cloud.tuikit.roomkit.R;

public class ConferenceMainActivity extends AppCompatActivity {
    private static final String TAG = "ConferenceMainAy";

    private ConferenceObserver mConferenceObserver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate : " + this);
        setContentView(R.layout.tuiroomkit_activity_conference_main);

        Intent intent = getIntent();
        ConferenceParams params = parseArguments(intent);
        String conferenceId = intent.getStringExtra("id");
        boolean isCreate = intent.getBooleanExtra("isCreate", false);

        ConferenceMainFragment fragment = new ConferenceMainFragment();
        fragment.setConferenceParams(params);
        setConferenceObserver(fragment);

        if (isCreate) {
            fragment.quickStartConference(conferenceId);
        } else {
            fragment.joinConference(conferenceId);
        }
    }

    private ConferenceParams parseArguments(Intent intent) {
        ConferenceParams params = new ConferenceParams();
        params.setName(intent.getStringExtra("name"));
        params.setEnableSeatControl(intent.getBooleanExtra("enableSeatControl", false));
        params.setMuteMicrophone(intent.getBooleanExtra("muteMicrophone", false));
        params.setOpenCamera(intent.getBooleanExtra("openCamera", false));
        params.setSoundOnSpeaker(intent.getBooleanExtra("soundOnSpeaker", true));
        return params;
    }

    private void setConferenceObserver(ConferenceMainFragment fragment) {
        mConferenceObserver = new ConferenceObserver() {
            @Override
            public void onConferenceStarted(String conferenceId, ConferenceError error) {
                super.onConferenceStarted(conferenceId, error);
                showFragment(fragment, error);
            }

            @Override
            public void onConferenceJoined(String conferenceId, ConferenceError error) {
                super.onConferenceJoined(conferenceId, error);
                showFragment(fragment, error);
            }
        };
        fragment.setConferenceObserver(mConferenceObserver);
    }

    private void showFragment(Fragment fragment, ConferenceError error) {
        if (error != ConferenceError.SUCCESS) {
            finish();
            return;
        }
        FragmentManager manager = getSupportFragmentManager();
        FragmentTransaction transaction = manager.beginTransaction();
        transaction.add(R.id.app_fl_conference_main, fragment);
        transaction.commitAllowingStateLoss();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy : " + this);
        mConferenceObserver = null;
    }
}
