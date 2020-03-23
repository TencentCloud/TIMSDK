package com.tencent.qcloud.tim.demo;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.WindowManager;

import com.tencent.qcloud.tim.demo.login.LoginForDevActivity;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.Set;

public class SplashActivity extends Activity {

    private static final String TAG = SplashActivity.class.getSimpleName();
    private static final int SPLASH_TIME = 1500;
    private View mFlashView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        // 离线推送测试代码
        Bundle bundle = getIntent().getExtras();
        DemoLog.i(TAG, "bundle: " + bundle);
        if (bundle == null) {
            // oppo scheme url解析
            Uri uri = getIntent().getData();
            Set<String> set = null;
            if (uri != null) {
                set = uri.getQueryParameterNames();
            }
            if (set != null) {
                for (String key : set) {
                    String value = uri.getQueryParameter(key);
                    DemoLog.i(TAG, "oppo push scheme url key: " + key + " value: " + value);
                }
            }
        } else {
            String ext = bundle.getString("ext");
            DemoLog.i(TAG, "huawei push custom data ext: " + ext);

            Set<String> set = bundle.keySet();
            if (set != null) {
                for (String key : set) {
                    String value = bundle.getString(key);
                    DemoLog.i(TAG, "oppo push custom data key: " + key + " value: " + value);
                }
            }
        }
        // 离线推送测试代码结束

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);

        mFlashView = findViewById(R.id.flash_view);
        handleData();
    }

    private void handleData() {
        mFlashView.postDelayed(new Runnable() {
            @Override
            public void run() {
                startLogin();
            }
        }, SPLASH_TIME);
    }

    private void startLogin() {
        Intent intent = new Intent(SplashActivity.this, LoginForDevActivity.class);
        startActivity(intent);
        finish();
    }

}
