package com.tencent.qcloud.tim.demo;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.WindowManager;

import com.tencent.qcloud.tim.demo.login.LoginForDevActivity;
import com.tencent.qcloud.tim.demo.login.UserInfo;
import com.tencent.qcloud.tim.demo.main.MainActivity;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.Utils;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

public class SplashActivity extends Activity {

    private static final String TAG = SplashActivity.class.getSimpleName();
    private static final int SPLASH_TIME = 1500;
    private View mFlashView;
    private UserInfo mUserInfo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        // 离线推送测试代码
        Utils.printBundle(getIntent());
        // 离线推送测试代码结束

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);

        mFlashView = findViewById(R.id.flash_view);
        mUserInfo = UserInfo.getInstance();
        handleData();
    }

    private void handleData() {
        if (TextUtils.isEmpty(mUserInfo.getPhone())) {
            mFlashView.postDelayed(new Runnable() {
                @Override
                public void run() {
                    startLogin();
                }
            }, SPLASH_TIME);

        } else {
            if (mUserInfo.isAutoLogin()) {
                login();
            } else {
                mFlashView.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        startLogin();
                    }
                }, SPLASH_TIME);
            }
        }
    }

    private void login() {
        TUIKit.login(mUserInfo.getUserId(), mUserInfo.getUserSig(), new IUIKitCallBack() {
            @Override
            public void onError(String module, final int code, final String desc) {
                runOnUiThread(new Runnable() {
                    public void run() {
                        ToastUtil.toastLongMessage("登录失败, errCode = " + code + ", errInfo = " + desc);
                        startLogin();
                    }
                });
                DemoLog.i(TAG, "imLogin errorCode = " + code + ", errorInfo = " + desc);
            }

            @Override
            public void onSuccess(Object data) {
                startMain();
            }
        });
    }

    private void startLogin() {
        Intent intent = new Intent(SplashActivity.this, LoginForDevActivity.class);
        startActivity(intent);
        finish();
    }

    private void startMain() {
        Intent intent = new Intent(SplashActivity.this, MainActivity.class);
        startActivity(intent);
        finish();
    }
}
