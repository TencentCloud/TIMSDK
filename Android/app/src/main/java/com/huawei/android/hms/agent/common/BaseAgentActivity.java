package com.huawei.android.hms.agent.common;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;

/**
 * 基础activity，用来处理公共的透明参数
 */
public class BaseAgentActivity extends Activity {

    public static final String EXTRA_IS_FULLSCREEN = "should_be_fullscreen";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestActivityTransparent();
    }

    /**
     * 启用透明的跳板Activity
     */
    private void requestActivityTransparent() {
        try {
            Intent intent = getIntent();
            if (intent != null && intent.getBooleanExtra(EXTRA_IS_FULLSCREEN, false)) {
                getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
            }
            requestWindowFeature(Window.FEATURE_NO_TITLE);
            Window window = getWindow();
            if (window != null) {
                window.addFlags(0x04000000);
            }
        } catch (Exception e) {
            HMSAgentLog.w("requestActivityTransparent exception:" + e.getMessage());
        }
    }
}
