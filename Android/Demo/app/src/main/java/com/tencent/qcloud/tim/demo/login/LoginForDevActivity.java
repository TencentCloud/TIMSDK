package com.tencent.qcloud.tim.demo.login;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.TIMAppService;
import com.tencent.qcloud.tim.demo.bean.UserInfo;
import com.tencent.qcloud.tim.demo.config.AppConfig;
import com.tencent.qcloud.tim.demo.main.MainActivity;
import com.tencent.qcloud.tim.demo.main.MainMinimalistActivity;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;

/**
 * Demo的登录Activity
 * 用户名可以是任意非空字符，但是前提需要按照下面文档修改代码里的 SDKAPPID 与 PRIVATEKEY
 * https://github.com/tencentyun/TIMSDK/tree/master/Android
 * 
 * 
 * Login Activity
 * The username can be any non-blank character, but the premise is to modify the SDKAPPID and PRIVATEKEY in the code according to the following documents:
 * https://github.com/tencentyun/TIMSDK/tree/master/Android
 */

public class LoginForDevActivity extends BaseLightActivity {

    private static final String TAG = LoginForDevActivity.class.getSimpleName();
    private TextView mLoginView;
    private EditText mUserAccount;
    private TextView languageTv, styleTv;
    private View languageArea, styleArea;
    private View modifyTheme;
    private ImageView logo;

    private BroadcastReceiver languageChangedReceiver;
    private BroadcastReceiver themeChangedReceiver;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        languageChangedReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                initActivity();
            }
        };

        themeChangedReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                setCurrentTheme();
            }
        };

        IntentFilter languageFilter = new IntentFilter();
        IntentFilter themeFilter = new IntentFilter();
        languageFilter.addAction(Constants.DEMO_LANGUAGE_CHANGED_ACTION);
        themeFilter.addAction(Constants.DEMO_THEME_CHANGED_ACTION);
        LocalBroadcastManager.getInstance(this).registerReceiver(languageChangedReceiver, languageFilter);
        LocalBroadcastManager.getInstance(this).registerReceiver(themeChangedReceiver, themeFilter);

        initActivity();
    }

    private void initActivity() {
        setContentView(R.layout.login_for_dev_activity);

        styleArea = findViewById(R.id.modify_style);
        styleTv = findViewById(R.id.demo_login_style_tv);

        languageArea = findViewById(R.id.language_area);
        languageTv = findViewById(R.id.demo_login_language);
        modifyTheme = findViewById(R.id.modify_theme);
        logo = findViewById(R.id.logo);
        if (Build.VERSION.SDK_INT >= 21) {
            View decorView = getWindow().getDecorView();
            decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            getWindow().setStatusBarColor(Color.TRANSPARENT);
            getWindow().setNavigationBarColor(Color.TRANSPARENT);
        }

        mLoginView = findViewById(R.id.login_btn);
        // 用户名可以是任意非空字符，但是前提需要按照下面文档修改代码里的 SDKAPPID 与 PRIVATEKEY
        // https://github.com/tencentyun/TIMSDK/tree/master/Android
        mUserAccount = findViewById(R.id.login_user);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
        mLoginView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                TIMAppService.getInstance().initBeforeLogin(0);
                mLoginView.setEnabled(false);
                UserInfo.getInstance().setUserId(mUserAccount.getText().toString());
                String userSig = GenerateTestUserSig.genTestUserSig(mUserAccount.getText().toString());
                UserInfo.getInstance().setUserSig(userSig);
                TUILogin.login(DemoApplication.instance(), AppConfig.DEMO_SDK_APPID, mUserAccount.getText().toString(), userSig, TUIUtils.getLoginConfig(), new TUICallback() {
                    @Override
                    public void onError(final int code, final String desc) {
                        runOnUiThread(new Runnable() {
                            public void run() {
                                mLoginView.setEnabled(true);
                                ToastUtil.toastLongMessage(getString(R.string.failed_login_tip) + ", errCode = " + code + ", errInfo = " + desc);
                            }
                        });
                        DemoLog.i(TAG, "imLogin errorCode = " + code + ", errorInfo = " + desc);
                    }

                    @Override
                    public void onSuccess() {
                        UserInfo.getInstance().setAutoLogin(true);
                        UserInfo.getInstance().setDebugLogin(true);
                        Intent intent;
                        if (AppConfig.DEMO_UI_STYLE == 0) {
                            intent = new Intent(LoginForDevActivity.this, MainActivity.class);
                        } else {
                            intent = new Intent(LoginForDevActivity.this, MainMinimalistActivity.class);
                        }
                        startActivity(intent);

                        TIMAppService.getInstance().registerPushManually();

                        finish();
                    }
                });
            }
        });

        mUserAccount.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (TextUtils.isEmpty(mUserAccount.getText())) {
                    mLoginView.setEnabled(false);
                } else {
                    mLoginView.setEnabled(true);
                }
            }
        });
        mUserAccount.setText(UserInfo.getInstance().getUserId());

        languageArea.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                LanguageSelectActivity.startSelectLanguage(LoginForDevActivity.this);
            }
        });

        styleArea.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                StyleSelectActivity.startStyleSelectActivity(LoginForDevActivity.this);
            }
        });

        modifyTheme.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ThemeSelectActivity.startSelectTheme(LoginForDevActivity.this);
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (AppConfig.DEMO_UI_STYLE == 0) {
            modifyTheme.setVisibility(View.VISIBLE);
            styleTv.setText(getString(R.string.style_classic));
        } else {
            modifyTheme.setVisibility(View.GONE);
            styleTv.setText(getString(R.string.style_minimalist));
        }
    }

    private void setCurrentTheme() {
        int currentTheme = TUIThemeManager.getInstance().getCurrentTheme();
        if (currentTheme == TUIThemeManager.THEME_LIGHT) {
            logo.setBackgroundResource(R.drawable.demo_ic_logo_light);
            mLoginView.setBackgroundResource(R.drawable.button_border_light);
        } else if (currentTheme == TUIThemeManager.THEME_LIVELY) {
            logo.setBackgroundResource(R.drawable.demo_ic_logo_lively);
            mLoginView.setBackgroundResource(R.drawable.button_border_lively);
        } else if (currentTheme == TUIThemeManager.THEME_SERIOUS) {
            logo.setBackgroundResource(R.drawable.demo_ic_logo_serious);
            mLoginView.setBackgroundResource(R.drawable.button_border_serious);
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            finish();
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (themeChangedReceiver != null) {
            LocalBroadcastManager.getInstance(this).unregisterReceiver(themeChangedReceiver);
            themeChangedReceiver = null;
        }
        if (languageChangedReceiver != null) {
            LocalBroadcastManager.getInstance(this).unregisterReceiver(languageChangedReceiver);
            languageChangedReceiver = null;
        }
    }
}
