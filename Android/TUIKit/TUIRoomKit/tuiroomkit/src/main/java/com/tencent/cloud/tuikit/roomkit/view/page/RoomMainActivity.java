package com.tencent.cloud.tuikit.roomkit.view.page;

import android.os.Bundle;
import android.util.Log;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.tencent.cloud.tuikit.roomkit.ConferenceMainFragment;
import com.tencent.cloud.tuikit.roomkit.R;

public class RoomMainActivity extends AppCompatActivity {
    private static final String TAG = "RoomMainAy";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate : " + this);
        setContentView(R.layout.tuiroomkit_activity_room_main);

        ConferenceMainFragment fragment = new ConferenceMainFragment();
        FragmentManager manager = getSupportFragmentManager();
        FragmentTransaction transaction = manager.beginTransaction();
        transaction.add(R.id.tuiroomkit_fl_room_main, fragment);
        transaction.commitAllowingStateLoss();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy : " + this);
    }
}
