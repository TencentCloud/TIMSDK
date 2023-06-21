package com.tencent.qcloud.tim.tuiofflinepush;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.Nullable;

public class OpenActivity extends Activity {
    private static final String TAG = OpenActivity.class.getSimpleName();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.e(TAG, "onCreate" + getIntent());
        TUIOfflinePushManager.getInstance().clickNotification(getIntent());
        finish();
    }
}
