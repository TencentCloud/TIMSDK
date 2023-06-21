package com.tencent.qcloud.tim.demo;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.text.TextUtils;
import android.util.Log;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.tencent.qcloud.tim.demo.config.InitSetting;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import java.util.Map;

public class TIMAppService extends ServiceInitializer implements ITUIService, ITUINotification {
    public static final String TAG = TIMAppService.class.getSimpleName();
    private static TIMAppService instance;

    public static TIMAppService getInstance() {
        return instance;
    }

    public Context mContext;

    private BroadcastReceiver languageChangedReceiver;

    private InitSetting initSetting;

    @Override
    public void init(Context context) {
        instance = this;
        mContext = context;

        initSetting = new InitSetting(mContext);
        initSetting.init();
        initThemeAndLanguageChangedReceiver();
        initService();
    }

    private void initService() {
        TUICore.registerService(TUIConstants.TIMAppKit.SERVICE_NAME, this);

        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_KICKED_OFFLINE, this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_SIG_EXPIRED, this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS, this);
        TUICore.registerEvent(TUIConstants.TIMAppKit.NOTIFY_RTCUBE_EVENT_KEY,
                TUIConstants.TIMAppKit.NOFITY_IMLOGIN_SUCCESS_SUB_KEY, this);
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        Log.d(TAG, "onNotifyEvent key = " + key + "subKey = " + subKey);
        if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED.equals(key)) {
            if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_KICKED_OFFLINE.equals(subKey) || TUIConstants.TUILogin.EVENT_SUB_KEY_USER_SIG_EXPIRED.equals(subKey)
                || TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS.equals(subKey)) {
                Log.d(TAG, "logout im");
            } else if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS.equals(subKey)) {
                Log.d(TAG, "login im ");
            }
        } else if (TUIConstants.TIMAppKit.NOTIFY_RTCUBE_EVENT_KEY.equals(key) && TUIConstants.TIMAppKit.NOFITY_IMLOGIN_SUCCESS_SUB_KEY.equals(subKey)) {
            if (param != null) {
                Intent intent = (Intent) param.get(TUIConstants.TIMAppKit.OFFLINE_PUSH_INTENT_DATA);
                TUIUtils.handleOfflinePush(intent, null);
            }
            if (!TextUtils.isEmpty(TUIUtils.offlineData)) {
                TUIUtils.handleOfflinePush(TUIUtils.offlineData, null);
                TUIUtils.offlineData = null;
            }
        }
    }

    private void initThemeAndLanguageChangedReceiver() {
        languageChangedReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                initSetting.setPermissionRequestContent();
            }
        };

        IntentFilter languageFilter = new IntentFilter();
        languageFilter.addAction(Constants.DEMO_LANGUAGE_CHANGED_ACTION);
        LocalBroadcastManager.getInstance(mContext).registerReceiver(languageChangedReceiver, languageFilter);
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
}
