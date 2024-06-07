package com.tencent.qcloud.tim.demo.login;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.TIMAppService;
import com.tencent.qcloud.tim.demo.bean.UserInfo;
import com.tencent.qcloud.tim.demo.config.AppConfig;
import com.tencent.qcloud.tim.demo.main.MainActivity;
import com.tencent.qcloud.tim.demo.main.MainMinimalistActivity;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIUtils;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUILoginConfig;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import java.util.ArrayList;
import java.util.List;

public class LoginWrapper {
    private static final String TAG = LoginWrapper.class.getSimpleName();

    private static class LoginWrapperHolder {
        private static final LoginWrapper loginInstance = new LoginWrapper();
    }

    public static LoginWrapper getInstance() {
        return LoginWrapper.LoginWrapperHolder.loginInstance;
    }

    private V2TIMSDKListener v2TIMSDKListener;
    private V2TIMConversationListener v2TIMConversationListener;
    private List<AppLoginListener> appLoginObservers = new ArrayList<>();

    private LoginWrapper() {
        initIMSDKObserver();
    }

    private void initIMSDKObserver() {
        if (v2TIMSDKListener == null) {
            v2TIMSDKListener = new V2TIMSDKListener() {
                @Override
                public void onConnecting() {
                    for (AppLoginListener listener : appLoginObservers) {
                        listener.onConnecting();
                    }
                }

                @Override
                public void onConnectSuccess() {
                    for (AppLoginListener listener : appLoginObservers) {
                        listener.onConnectSuccess();
                    }

                    tryToAutoLogin();
                }

                @Override
                public void onConnectFailed(int code, String error) {
                    for (AppLoginListener listener : appLoginObservers) {
                        listener.onConnectFailed(code, error);
                    }
                }

                @Override
                public void onUserSigExpired() {
                    for (AppLoginListener listener : appLoginObservers) {
                        listener.onUserSigExpired();
                    }
                }
            };
        }

        if (v2TIMConversationListener == null) {
            v2TIMConversationListener = new V2TIMConversationListener() {
                @Override
                public void onSyncServerStart() {
                    for (AppLoginListener listener : appLoginObservers) {
                        listener.onSyncServerStart();
                    }
                }

                @Override
                public void onSyncServerFinish() {
                    for (AppLoginListener listener : appLoginObservers) {
                        listener.onSyncServerFinish();
                    }
                }

                @Override
                public void onSyncServerFailed() {
                    for (AppLoginListener listener : appLoginObservers) {
                        listener.onSyncServerFailed();
                    }
                }
            };
        }

        V2TIMManager.getInstance().addIMSDKListener(v2TIMSDKListener);
        V2TIMManager.getConversationManager().addConversationListener(v2TIMConversationListener);
    }

    public void addAppLoginObserver(final AppLoginListener observer) {
        if (observer == null) {
            return;
        }

        ThreadUtils.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!appLoginObservers.contains(observer)) {
                    appLoginObservers.add(observer);
                }
            }
        });
    }

    public void removeLoginObserver(AppLoginListener observer) {
        if (observer == null) {
            return;
        }

        ThreadUtils.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                appLoginObservers.remove(observer);
            }
        });
    }

    public void loginIMSDK(Context context, int sdkAppID, String userID, String userSig, TUILoginConfig config, TUICallback tuiCallback) {
        TUILogin.login(context, sdkAppID, userID, userSig, config, new TUICallback() {
            @Override
            public void onError(final int code, final String desc) {
                UserInfo.getInstance().setLastLoginCode(code);
                if (tuiCallback != null) {
                    tuiCallback.onError(code, desc);
                }
            }

            @Override
            public void onSuccess() {
                UserInfo.getInstance().setLastLoginCode(BaseConstants.ERR_SUCC);
                if (tuiCallback != null) {
                    tuiCallback.onSuccess();
                }
            }
        });
    }

    public void initUserLocalData(Context context, int sdkAppID, String userID, TUICallback tuiCallback) {
        if (!TUILogin.init(context, sdkAppID, null, null)) {
            Log.e(TAG, "initSDK failed");
            return;
        }

        TUILogin.setLoginUser(AppConfig.DEMO_SDK_APPID, userID);
        V2TIMManager.getInstance().callExperimentalAPI("initLocalStorage", userID, new V2TIMValueCallback<Object>() {
            @Override
            public void onSuccess(Object o) {
                if (tuiCallback != null) {
                    tuiCallback.onSuccess();
                }
            }

            @Override
            public void onError(int code, String desc) {
                DemoLog.e(TAG, "initLocalStorage error:" + code + ", desc:" + desc);
                if (tuiCallback != null) {
                    tuiCallback.onError(code, desc);
                }
            }
        });
    }

    private void tryToAutoLogin() {
        int loginStatus = V2TIMManager.getInstance().getLoginStatus();
        int lastLoginCode = UserInfo.getInstance().getLastLoginCode();
        UserInfo userInfo = UserInfo.getInstance();
        if (loginStatus == V2TIMManager.V2TIM_STATUS_LOGOUT && !TextUtils.isEmpty(userInfo.getUserId()) && userInfo.isAutoLogin()
            && (lastLoginCode >= BaseConstants.ERR_SDK_NET_ENCODE_FAILED && lastLoginCode <= BaseConstants.ERR_SDK_NET_SEND_REMAINING_TIMEOUT_NO_NETWORK)) {
            DemoLog.i(TAG, "onConnectSuccess, login IMSDK");
            loginIMSDK(TIMAppService.getAppContext(), AppConfig.DEMO_SDK_APPID, userInfo.getUserId(), userInfo.getUserSig(), TUIUtils.getLoginConfig(),
                new TUICallback() {
                    @Override
                    public void onSuccess() {
                        // do nothing
                    }

                    @Override
                    public void onError(int errorCode, String errorMessage) {
                        UserInfo.getInstance().setLastLoginCode(errorCode);
                        if ((lastLoginCode < BaseConstants.ERR_SDK_NET_ENCODE_FAILED
                                && lastLoginCode > BaseConstants.ERR_SDK_NET_SEND_REMAINING_TIMEOUT_NO_NETWORK)) {
                            if (AppConfig.DEMO_UI_STYLE == AppConfig.DEMO_UI_STYLE_CLASSIC) {
                                MainActivity.finishMainActivity();
                            } else {
                                MainMinimalistActivity.finishMainActivity();
                            }

                            TIMAppService.getInstance().startLoginActivity();
                        }
                    }
                });
        }
    }

    public abstract static class AppLoginListener {
        public void onConnecting() {}

        public void onConnectSuccess() {}

        public void onConnectFailed(int code, String error) {}

        public void onUserSigExpired() {}

        public void onSyncServerStart() {}

        public void onSyncServerFinish() {}

        public void onSyncServerFailed() {}
    }
}
