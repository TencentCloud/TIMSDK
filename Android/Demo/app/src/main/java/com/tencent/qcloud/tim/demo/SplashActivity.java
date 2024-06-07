package com.tencent.qcloud.tim.demo;

import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.WindowManager;
import com.tencent.imsdk.BaseConstants;
import com.tencent.qcloud.tim.demo.bean.UserInfo;
import com.tencent.qcloud.tim.demo.config.AppConfig;
import com.tencent.qcloud.tim.demo.login.LoginForDevActivity;
import com.tencent.qcloud.tim.demo.login.LoginWrapper;
import com.tencent.qcloud.tim.demo.main.MainActivity;
import com.tencent.qcloud.tim.demo.main.MainMinimalistActivity;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;

public class SplashActivity extends BaseLightActivity {
    private static final String TAG = SplashActivity.class.getSimpleName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);

        if (Build.VERSION.SDK_INT >= 21) {
            View decorView = getWindow().getDecorView();
            decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            getWindow().setStatusBarColor(Color.TRANSPARENT);
            getWindow().setNavigationBarColor(Color.TRANSPARENT);
        }

        handleData();
    }

    private void handleData() {
        UserInfo userInfo = UserInfo.getInstance();
        if (userInfo != null && !TextUtils.isEmpty(userInfo.getUserId()) && userInfo.isAutoLogin()) {
            AppConfig.DEMO_SDK_APPID = GenerateTestUserSig.SDKAPPID;
            // Set network error codes for automatic login later in debug mode
            userInfo.setLastLoginCode(BaseConstants.ERR_SDK_NET_CONN_TIMEOUT);
            initUserLocalData();
        } else {
            startLogin();
        }
    }

    private void initUserLocalData() {
        UserInfo userInfo = UserInfo.getInstance();
        LoginWrapper.getInstance().initUserLocalData(this, AppConfig.DEMO_SDK_APPID, userInfo.getUserId(), new TUICallback() {
            @Override
            public void onSuccess() {
                TIMAppService.getInstance().registerPushManually();
                startMainActivity();
            }

            @Override
            public void onError(final int errorCode, final String errorMessage) {
                runOnUiThread(new Runnable() {
                    public void run() {
                        ToastUtil.toastLongMessage(getString(R.string.failed_login_tip) + ", errCode = " + errorCode + ", errInfo = " + errorMessage);
                        startLogin();
                    }
                });
                DemoLog.i(TAG, "imLogin errorCode = " + errorCode + ", errorInfo = " + errorMessage);
            }
        });
    }

    private void startLogin() {
        Intent intent = new Intent(SplashActivity.this, LoginForDevActivity.class);
        intent.putExtras(getIntent());
        startActivity(intent);
        finish();
    }

    private void startMainActivity() {
        DemoLog.i(TAG, "start MainActivity");

        Intent intent;
        if (AppConfig.DEMO_UI_STYLE == 0) {
            intent = new Intent(SplashActivity.this, MainActivity.class);
        } else {
            intent = new Intent(SplashActivity.this, MainMinimalistActivity.class);
        }
        Intent dataIntent = getIntent();
        intent.putExtras(dataIntent);
        if (dataIntent != null) {
            String ext = dataIntent.getStringExtra(TUIConstants.TIMPush.NOTIFICATION_EXT_KEY);
            intent.putExtra(TUIConstants.TIMPush.NOTIFICATION_EXT_KEY, ext);
        }
        startActivity(intent);
        finish();
    }
}
