package com.tencent.qcloud.tim.tuiofflinepush;

import android.app.Activity;
import android.util.Log;

public class OpenActivity extends Activity {
    private static final String TAG = OpenActivity.class.getSimpleName();

    @Override
    protected void onResume() {
        Log.i(TAG, "onResume" + getIntent());
        super.onResume();
        TUIOfflinePushManager.getInstance().clickNotification(getIntent());
        finish();
    }
}
