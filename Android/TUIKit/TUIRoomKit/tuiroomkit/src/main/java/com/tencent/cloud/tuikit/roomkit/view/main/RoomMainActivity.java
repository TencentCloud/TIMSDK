package com.tencent.cloud.tuikit.roomkit.view.main;

import android.annotation.SuppressLint;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.qcloud.tuicore.util.TUIBuild;

public class RoomMainActivity extends AppCompatActivity {
    private static final String TAG = "RoomMainAy";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate : " + this);
        initStatusBar();
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

    @SuppressLint("NewApi")
    private void initStatusBar() {
        Window window = getWindow();
        int sdkVersion = TUIBuild.getVersionInt();
        if (sdkVersion >= Build.VERSION_CODES.LOLLIPOP) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView()
                    .setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (sdkVersion >= Build.VERSION_CODES.KITKAT) {
            window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }
}
