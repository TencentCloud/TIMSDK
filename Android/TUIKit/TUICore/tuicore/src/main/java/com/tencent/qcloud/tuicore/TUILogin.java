package com.tencent.qcloud.tuicore;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUILoginListener;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import static com.tencent.imsdk.v2.V2TIMManager.V2TIM_STATUS_LOGINED;


/**
 * 负责 IM 和 TRTC 的登录逻辑
 */
public class TUILogin {
    private static final String TAG = TUILogin.class.getSimpleName();

    private static class TUILoginHolder {
        private static final TUILogin loginInstance = new TUILogin();
    }

    public static TUILogin getInstance() {
        return TUILoginHolder.loginInstance;
    }

    private Context appContext;
    private int sdkAppId = 0;
    private String userId;
    private String userSig;
    private boolean hasLoginSuccess = false;

    private final List<TUILoginListener> listenerList = new CopyOnWriteArrayList<>();

    private TUILogin() {}

    private final V2TIMSDKListener imSdkListener = new V2TIMSDKListener() {
        @Override
        public void onConnecting() {
            for (TUILoginListener listener : listenerList) {
                listener.onConnecting();
            }
            TUICore.notifyEvent(TUIConstants.NetworkConnection.EVENT_CONNECTION_STATE_CHANGED,
                    TUIConstants.NetworkConnection.EVENT_SUB_KEY_CONNECTING, null);
        }

        @Override
        public void onConnectSuccess() {
            for (TUILoginListener listener : listenerList) {
                listener.onConnectSuccess();
            }
            TUICore.notifyEvent(TUIConstants.NetworkConnection.EVENT_CONNECTION_STATE_CHANGED,
                    TUIConstants.NetworkConnection.EVENT_SUB_KEY_CONNECT_SUCCESS, null);
        }

        @Override
        public void onConnectFailed(int code, String error) {
            for (TUILoginListener listener : listenerList) {
                listener.onConnectFailed(code, error);
            }
            TUICore.notifyEvent(TUIConstants.NetworkConnection.EVENT_CONNECTION_STATE_CHANGED,
                    TUIConstants.NetworkConnection.EVENT_SUB_KEY_CONNECT_FAILED, null);
        }

        @Override
        public void onKickedOffline() {
            for (TUILoginListener listener : listenerList) {
                listener.onKickedOffline();
            }
            TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                    TUIConstants.TUILogin.EVENT_SUB_KEY_USER_KICKED_OFFLINE, null);
        }

        @Override
        public void onUserSigExpired() {
            for (TUILoginListener listener : listenerList) {
                listener.onUserSigExpired();
            }
            TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                    TUIConstants.TUILogin.EVENT_SUB_KEY_USER_SIG_EXPIRED, null);
        }

        @Override
        public void onSelfInfoUpdated(V2TIMUserFullInfo info) {
            TUIConfig.setSelfInfo(info);
            notifyUserInfoChanged(info);
        }
    };

    /**
     * IMSDK 登录
     *
     * @param context  应用的上下文，一般为对应应用的 ApplicationContext
     * @param sdkAppId 您在腾讯云注册应用时分配的sdkAppID
     * @param userId   用户名
     * @param userSig  从业务服务器获取的 userSig
     * @param callback  登录回调
     */
    public static void login(@NonNull Context context, int sdkAppId, String  userId, String userSig, TUICallback callback) {
        getInstance().internalLogin(context, sdkAppId, userId, userSig, callback);
    }

    /**
     * IMSDK 登出
     * @param callback 登出回调
     */
    public static void logout(TUICallback callback) {
        getInstance().internalLogout(callback);
    }

    public static void addLoginListener(TUILoginListener listener) {
        getInstance().internalAddLoginListener(listener);
    }

    public static void removeLoginListener(TUILoginListener listener) {
        getInstance().internalRemoveLoginListener(listener);
    }

    private void internalLogin(Context context, final int sdkAppId, final String  userId, final String userSig, TUICallback callback) {
        if (this.sdkAppId != 0 && sdkAppId != this.sdkAppId) {
            logout((TUICallback) null);
        }
        this.appContext = context;
        this.sdkAppId = sdkAppId;
        V2TIMManager.getInstance().addIMSDKListener(imSdkListener);
        // 开始初始化 IMSDK，发送广播
        TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT, null);
        // 用户操作初始化, 默认已经读过隐私协议
        boolean initSuccess = V2TIMManager.getInstance().initSDK(context, sdkAppId, null);
        if (initSuccess) {
            this.userId = userId;
            this.userSig = userSig;
            if (TextUtils.equals(userId, V2TIMManager.getInstance().getLoginUser()) && !TextUtils.isEmpty(userId)) {
                TUICallback.onSuccess(callback);
                getUserInfo(userId);
                return;
            }

            V2TIMManager.getInstance().login(userId, userSig, new V2TIMCallback() {
                @Override
                public void onSuccess() {
                    hasLoginSuccess = true;
                    getUserInfo(userId);
                    TUICallback.onSuccess(callback);
                    TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, null);
                }

                @Override
                public void onError(int code, String desc) {
                    TUICallback.onError(callback, code, ErrorMessageConverter.convertIMError(code, desc));
                }
            });
        } else {
            TUICallback.onError(callback, -1, "init failed");
        }
    }

    private void internalLogout(TUICallback callback) {
        // 开始反初始化 IMSDK，发送广播
        TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_START_UNINIT, null);
        V2TIMManager.getInstance().logout(new V2TIMCallback() {
            @Override
            public void onSuccess() {
                sdkAppId = 0;
                userId = null;
                userSig = null;
                V2TIMManager.getInstance().unInitSDK();
                TUIConfig.clearSelfInfo();
                TUICallback.onSuccess(callback);
                TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS, null);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    private void internalAddLoginListener(TUILoginListener listener) {
        Log.i(TAG, "addLoginListener listener : " + listener);
        if (listener == null) {
            return;
        }
        if (!listenerList.contains(listener)) {
            listenerList.add(listener);
        }
    }

    private void internalRemoveLoginListener(TUILoginListener listener) {
        Log.i(TAG, "removeLoginListener listener : " + listener);
        if (listener == null) {
            return;
        }
        listenerList.remove(listener);
    }

    /**
     * IMSDK 初始化
     *
     * @param context  应用的上下文，一般为对应应用的 ApplicationContext
     * @param sdkAppId 您在腾讯云注册应用时分配的sdkAppID
     * @param config  IMSDK 的相关配置项，一般使用默认即可，需特殊配置参考API文档
     * @param listener  IMSDK 初始化监听器
     * @return  true：成功；false：失败，如果 context 为空会返回失败
     */
    @Deprecated
    public static boolean init(@NonNull Context context, int sdkAppId, @Nullable V2TIMSDKConfig config, @Nullable V2TIMSDKListener listener) {
        if (getInstance().sdkAppId != 0 && sdkAppId != getInstance().sdkAppId) {
            logout((V2TIMCallback) null);
            unInit();
        }
        getInstance().appContext = context;
        getInstance().sdkAppId = sdkAppId;
        V2TIMManager.getInstance().addIMSDKListener(new V2TIMSDKListener() {
            @Override
            public void onConnecting() {
                if (listener != null) {
                    listener.onConnecting();
                }
            }

            @Override
            public void onConnectSuccess() {
                if (listener != null) {
                    listener.onConnectSuccess();
                }
            }

            @Override
            public void onConnectFailed(int code, String error) {
                if (listener != null) {
                    listener.onConnectFailed(code, ErrorMessageConverter.convertIMError(code, error));
                }
            }

            @Override
            public void onKickedOffline() {
                if (listener != null) {
                    listener.onKickedOffline();
                }
                TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                        TUIConstants.TUILogin.EVENT_SUB_KEY_USER_KICKED_OFFLINE, null);
            }

            @Override
            public void onUserSigExpired() {
                if (listener != null) {
                    listener.onUserSigExpired();
                }
                TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                        TUIConstants.TUILogin.EVENT_SUB_KEY_USER_SIG_EXPIRED, null);
            }

            @Override
            public void onSelfInfoUpdated(V2TIMUserFullInfo info) {
                if (listener != null) {
                    listener.onSelfInfoUpdated(info);
                }

                TUIConfig.setSelfInfo(info);
                notifyUserInfoChanged(info);
            }
        });
        // 开始初始化 IMSDK，发送广播
        TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT, null);
        // 用户操作初始化, 默认已经读过隐私协议
        return V2TIMManager.getInstance().initSDK(context, sdkAppId, config);
    }

    /**
     * 反初始化 IMSDK，释放资源
     */
    @Deprecated
    public static void unInit() {
        getInstance().sdkAppId = 0;
        // 开始反初始化 IMSDK，发送广播
        TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_START_UNINIT, null);

        V2TIMManager.getInstance().unInitSDK();
        TUIConfig.clearSelfInfo();
    }

    /**
     * 用户登录
     *
     * @param userId   用户名
     * @param userSig  从业务服务器获取的 userSig
     * @param callback 登录是否成功的回调
     */
    @Deprecated
    public static void login(@NonNull String userId, @NonNull String userSig, @Nullable V2TIMCallback callback) {
        getInstance().userId = userId;
        getInstance().userSig = userSig;
        if (TextUtils.equals(userId, V2TIMManager.getInstance().getLoginUser()) && !TextUtils.isEmpty(userId)) {
            if (callback != null) {
                callback.onSuccess();
            }
            getUserInfo(userId);
            return;
        }

        V2TIMManager.getInstance().login(userId, userSig, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                getInstance().hasLoginSuccess = true;
                if (callback != null) {
                    callback.onSuccess();
                }
                getUserInfo(userId);
                TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, null);
            }

            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onError(code, ErrorMessageConverter.convertIMError(code, desc));
                }
            }
        });
    }

    /**
     * 用户退出登录
     *
     * @param callback 退出登录是否成功的回调
     */
    @Deprecated
    public static void logout(@Nullable V2TIMCallback callback) {
        V2TIMManager.getInstance().logout(new V2TIMCallback() {
            @Override
            public void onSuccess() {
                getInstance().userId = null;
                getInstance().userSig = null;
                if (callback != null) {
                    callback.onSuccess();
                }
                TUIConfig.clearSelfInfo();

                TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS, null);
            }

            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onError(code, ErrorMessageConverter.convertIMError(code, desc));
                }
            }
        });
    }

    private static void getUserInfo(String userId) {
        List<String> userIdList = new ArrayList<>();
        userIdList.add(userId);
        V2TIMManager.getInstance().getUsersInfo(userIdList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (v2TIMUserFullInfos.isEmpty()) {
                    Log.e(TAG, "get logined userInfo failed. list is empty");
                    return;
                }
                V2TIMUserFullInfo userFullInfo = v2TIMUserFullInfos.get(0);
                TUIConfig.setSelfInfo(userFullInfo);
                notifyUserInfoChanged(userFullInfo);
            }

            @Override
            public void onError(int code, String desc) {
                Log.e(TAG, "get logined userInfo failed. code : " + code + " desc : " + ErrorMessageConverter.convertIMError(code, desc));
            }
        });
    }

    private static void notifyUserInfoChanged(V2TIMUserFullInfo userFullInfo) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUILogin.SELF_ID, userFullInfo.getUserID());
        param.put(TUIConstants.TUILogin.SELF_SIGNATURE, userFullInfo.getSelfSignature());
        param.put(TUIConstants.TUILogin.SELF_NICK_NAME, userFullInfo.getNickName());
        param.put(TUIConstants.TUILogin.SELF_FACE_URL, userFullInfo.getFaceUrl());
        param.put(TUIConstants.TUILogin.SELF_BIRTHDAY, userFullInfo.getBirthday());
        param.put(TUIConstants.TUILogin.SELF_ROLE, userFullInfo.getRole());
        param.put(TUIConstants.TUILogin.SELF_GENDER, userFullInfo.getGender());
        param.put(TUIConstants.TUILogin.SELF_LEVEL, userFullInfo.getLevel());
        param.put(TUIConstants.TUILogin.SELF_ALLOW_TYPE, userFullInfo.getAllowType());
        TUICore.notifyEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_INFO_UPDATED, param);
    }

    /**
     * 获取 sdkAppId，未初始化时 sdkAppId 默认为 0
     * @return sdkAppId
     */
    public static int getSdkAppId() {
        return getInstance().sdkAppId;
    }

    /**
     * 获取 userId，未登录时 userId 默认为 null
     * @return userId
     */
    public static String getUserId() {
        return getInstance().userId;
    }

    /**
     * 获取 userSig，未登录时 userSig 默认为 null
     * @return userSig
     */
    public static String getUserSig() {
        return getInstance().userSig;
    }

    /**
     * 获取当前登录用户昵称
     * @return 当前登录用户昵称
     */
    public static String getNickName() {
        return TUIConfig.getSelfNickName();
    }

    /**
     * 获取当前登录用户头像
     * @return 当前登录用户头像
     */
    public static String getFaceUrl() {
        return TUIConfig.getSelfFaceUrl();
    }

    /**
     * 获取应用上下文，为初始化时传入的 applicationContext
     * @return appContext
     */
    public static Context getAppContext() {
        return getInstance().appContext;
    }

    /**
     * 用户是否已经登录
     * @return true：用户已经登录； false：用户尚未登录
     */
    public static boolean isUserLogined() {
        return getInstance().hasLoginSuccess && V2TIMManager.getInstance().getLoginStatus() == V2TIM_STATUS_LOGINED;
    }

    /**
     * 获取当前已经登录的用户 id，如果未初始化会返回 null
     * @return userId
     */
    public static String getLoginUser() {
        return V2TIMManager.getInstance().getLoginUser();
    }
}