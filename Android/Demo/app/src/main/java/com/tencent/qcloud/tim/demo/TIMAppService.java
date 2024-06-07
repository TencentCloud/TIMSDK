package com.tencent.qcloud.tim.demo;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.google.auto.service.AutoService;
import com.tencent.qcloud.tim.demo.bean.UserInfo;
import com.tencent.qcloud.tim.demo.config.AppConfig;
import com.tencent.qcloud.tim.demo.config.InitSetting;
import com.tencent.qcloud.tim.demo.custom.CustomConfigHelper;
import com.tencent.qcloud.tim.demo.login.LoginForDevActivity;
import com.tencent.qcloud.tim.demo.main.MainActivity;
import com.tencent.qcloud.tim.demo.main.MainMinimalistActivity;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import com.tencent.qcloud.tuicore.interfaces.TUILoginListener;
import com.tencent.qcloud.tuicore.util.ToastUtil;

@AutoService(TUIInitializer.class)
@TUIInitializerDependency("TIMCommon")
@TUIInitializerID("TIMAppService")
public class TIMAppService implements TUIInitializer, ITUIService {
    public static final String TAG = TIMAppService.class.getSimpleName();
    private static TIMAppService instance;

    public static TIMAppService getInstance() {
        return instance;
    }

    public Context mContext;

    private BroadcastReceiver languageChangedReceiver;
    private BroadcastReceiver themeChangedReceiver;

    private InitSetting initSetting;

    @Override
    public void init(Context context) {
        instance = this;
        mContext = context;

        initSetting = new InitSetting(mContext);
        initSetting.init();
        initThemeAndLanguageChangedReceiver();
        initLoginStatusListener();
    }

    public void initLoginStatusListener() {
        TUILogin.addLoginListener(loginStatusListener);
    }

    private final TUILoginListener loginStatusListener = new TUILoginListener() {
        @Override
        public void onKickedOffline() {
            ToastUtil.toastLongMessage(getAppContext().getString(R.string.repeat_login_tip));
            logout();
        }

        @Override
        public void onUserSigExpired() {
            ToastUtil.toastLongMessage(getAppContext().getString(R.string.expired_login_tip));
            TUILogin.logout(new TUICallback() {
                @Override
                public void onSuccess() {
                    logout();
                }

                @Override
                public void onError(int errorCode, String errorMessage) {
                    logout();
                }
            });
        }
    };

    public void logout() {
        DemoLog.i(TAG, "logout");
        UserInfo.getInstance().cleanUserInfo();

        Intent intent = new Intent(getAppContext(), LoginForDevActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("LOGOUT", true);
        getAppContext().startActivity(intent);

        if (AppConfig.DEMO_UI_STYLE == AppConfig.DEMO_UI_STYLE_CLASSIC) {
            MainActivity.finishMainActivity();
        } else {
            MainMinimalistActivity.finishMainActivity();
        }
    }

    private void initThemeAndLanguageChangedReceiver() {
        languageChangedReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                initSetting.setPermissionRequestContent();
            }
        };

        themeChangedReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                CustomConfigHelper.initConversationDefaultAvatar();
            }
        };
        IntentFilter languageFilter = new IntentFilter();
        languageFilter.addAction(Constants.DEMO_LANGUAGE_CHANGED_ACTION);
        LocalBroadcastManager.getInstance(mContext).registerReceiver(languageChangedReceiver, languageFilter);

        IntentFilter themeFilter = new IntentFilter();
        themeFilter.addAction(Constants.DEMO_THEME_CHANGED_ACTION);
        LocalBroadcastManager.getInstance(mContext).registerReceiver(themeChangedReceiver, themeFilter);
    }

    public void registerPushManually() {
        if (initSetting == null) {
            initSetting = new InitSetting(mContext);
        }

        initSetting.registerPushManually();
    }

    public void initBeforeLogin(int sdkappid) {
        if (initSetting == null) {
            initSetting = new InitSetting(mContext);
        }

        initSetting.initBeforeLogin(sdkappid);
    }

    public void startLoginActivity() {
        Intent intent = new Intent(mContext, LoginForDevActivity.class);
        mContext.startActivity(intent);
    }

    public static Context getAppContext() {
        return ServiceInitializer.getAppContext();
    }
}
