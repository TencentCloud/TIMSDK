package com.tencent.cloud.tuikit.roomkit;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.SystemClock;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentTransaction;

import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseDialogFragment;
import com.tencent.cloud.tuikit.roomkit.view.main.ConferenceMainFragment;
import com.tencent.cloud.tuikit.roomkit.view.main.floatwindow.videoplaying.RoomFloatViewService;
import com.tencent.qcloud.tuicore.util.TUIBuild;

import java.io.Serializable;

public class ConferenceMainActivity extends AppCompatActivity {
    private static final String TAG              = "ConferenceMainAy";
    private static final int    DEBOUNCE_TIME_MS = 1000;

    private final long mFirstStartTime = SystemClock.elapsedRealtime();

    private Intent mNewIntent;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i(TAG, "onCreate : " + this);
        initStatusBar();
        setContentView(R.layout.tuiroomkit_activity_conference_main);
        dismissFloatWindowIfNeeded();
        ConferenceMainFragment fragment = new ConferenceMainFragment();
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.add(R.id.app_fl_conference_main, fragment);
        transaction.commitAllowingStateLoss();

        Intent intent = getIntent();
        if (isRepeatConference(intent)) {
            showRepeatConferenceDialog();
            return;
        }
        if (!startConferenceIfNeeded(intent, fragment)) {
            joinConferenceIfNeeded(intent, fragment);
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        if (SystemClock.elapsedRealtime() - mFirstStartTime < DEBOUNCE_TIME_MS) {
            return;
        }
        mNewIntent = intent;
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mNewIntent == null) {
            return;
        }
        if (ConferenceController.sharedInstance().getViewState().isInPictureInPictureMode.get()) {
            return;
        }
        if (!isRepeatConference(mNewIntent)) {
            return;
        }
        showRepeatConferenceDialog();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "onDestroy : " + this);
    }

    private boolean startConferenceIfNeeded(Intent intent, ConferenceMainFragment fragment) {
        Serializable startSerializable = intent.getSerializableExtra(ConferenceDefine.KEY_START_CONFERENCE_PARAMS);
        if (startSerializable == null) {
            return false;
        }
        if (!(startSerializable instanceof ConferenceDefine.StartConferenceParams)) {
            Log.e(TAG, "params is not instanceof ConferenceDefine.StartConferenceParams");
            return false;
        }
        ConferenceDefine.StartConferenceParams startConferenceParams = (ConferenceDefine.StartConferenceParams) startSerializable;
        Log.i(TAG, "startConference : " + startConferenceParams);
        fragment.startConference(startConferenceParams);
        return true;
    }

    private boolean joinConferenceIfNeeded(Intent intent, ConferenceMainFragment fragment) {
        Serializable joinSerializable = intent.getSerializableExtra(ConferenceDefine.KEY_JOIN_CONFERENCE_PARAMS);
        if (joinSerializable == null) {
            return false;
        }
        if (!(joinSerializable instanceof ConferenceDefine.JoinConferenceParams)) {
            Log.e(TAG, "params is not instanceof ConferenceDefine.JoinConferenceParams");
            return false;
        }
        ConferenceDefine.JoinConferenceParams joinConferenceParams = (ConferenceDefine.JoinConferenceParams) joinSerializable;
        Log.i(TAG, "joinConference : " + joinConferenceParams);
        fragment.joinConference(joinConferenceParams);
        return true;
    }

    private boolean isRepeatConference(Intent intent) {
        if (!isConferenceParams(intent)) {
            return false;
        }
        if (!ConferenceController.sharedInstance().getViewController().isProcessRoom()) {
            return false;
        }
        Serializable serializable = intent.getSerializableExtra(ConferenceDefine.KEY_START_CONFERENCE_PARAMS);
        if (serializable instanceof ConferenceDefine.StartConferenceParams) {
            return !((ConferenceDefine.StartConferenceParams) serializable).roomId.equals(ConferenceController.sharedInstance().getRoomState().roomId.get());
        }
        serializable = intent.getSerializableExtra(ConferenceDefine.KEY_JOIN_CONFERENCE_PARAMS);
        if (serializable instanceof ConferenceDefine.JoinConferenceParams) {
            return !((ConferenceDefine.JoinConferenceParams) serializable).roomId.equals(ConferenceController.sharedInstance().getRoomState().roomId.get());
        }

        return true;
    }

    private boolean isConferenceParams(Intent intent) {
        Serializable startSerializable = intent.getSerializableExtra(ConferenceDefine.KEY_START_CONFERENCE_PARAMS);
        if (startSerializable instanceof ConferenceDefine.StartConferenceParams) {
            return true;
        }
        Serializable joinSerializable = intent.getSerializableExtra(ConferenceDefine.KEY_JOIN_CONFERENCE_PARAMS);
        return joinSerializable instanceof ConferenceDefine.JoinConferenceParams;
    }

    private void showRepeatConferenceDialog() {
        BaseDialogFragment.build()
                .setTitle(getString(R.string.tuiroomkit_repeat_start_room_dialog_title))
                .setContent(getString(R.string.tuiroomkit_repeat_start_room_dialog_content))
                .hideNegativeView()
                .setPositiveName(getString(R.string.tuiroomkit_i_see))
                .showDialog(this, "showRepeatConferenceDialog");
    }

    private void dismissFloatWindowIfNeeded() {
        Intent intent = new Intent(this, RoomFloatViewService.class);
        stopService(intent);
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
