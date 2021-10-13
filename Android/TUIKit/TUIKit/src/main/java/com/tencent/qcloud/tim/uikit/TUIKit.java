package com.tencent.qcloud.tim.uikit;

import android.content.Context;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.tencent.imsdk.common.IMLog;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;


public class TUIKit {
    public static final String TAG = "TUIKit";

    /**
     * TUIKit的初始化函数
     *
     * @param context  应用的上下文，一般为对应应用的ApplicationContext
     * @param sdkAppID 您在腾讯云注册应用时分配的sdkAppID
     * @param config  IMSDK 的相关配置项，一般使用默认即可，需特殊配置参考API文档
     * @param listener  IMSDK 初始化监听器
     */
    public static void init(Context context, int sdkAppID, @Nullable V2TIMSDKConfig config, @Nullable V2TIMSDKListener listener) {
        TUILogin.init(context, sdkAppID, config, listener);
    }

    /**
     * 释放一些资源等，一般可以在退出登录时调用
     */
    public static void unInit() {
        TUILogin.unInit();
    }

    /**
     * 获取TUIKit保存的上下文Context，该Context会长期持有，所以应该为Application级别的上下文
     *
     * @return
     */
    public static Context getAppContext() {
        return TUILogin.getAppContext();
    }


    /**
     * 用户IM登录
     *
     * @param userid   用户名
     * @param usersig  从业务服务器获取的usersig
     * @param callback 登录是否成功的回调
     */
    public static void login(final String userid, final String usersig, final V2TIMCallback callback) {
        TUILogin.login(userid, usersig, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                if (callback != null) {
                    callback.onSuccess();
                }
                loginTUIKitLive(TUILogin.getSdkAppId(), userid, usersig);
            }

            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onError(code, desc);
                }
            }
        });
    }

    public static void logout(final V2TIMCallback callback) {
        logoutTUIKitLive();
        TUILogin.logout(callback);
    }


    private static void loginTUIKitLive(int sdkAppId, String userId, String userSig) {
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUILive.SDK_APP_ID, sdkAppId);
        param.put(TUIConstants.TUILive.USER_ID, userId);
        param.put(TUIConstants.TUILive.USER_SIG, userSig);
        TUICore.callService(TUIConstants.TUILive.SERVICE_NAME, TUIConstants.TUILive.METHOD_LOGIN, param);
    }

    private static void logoutTUIKitLive() {
        TUICore.callService(TUIConstants.TUILive.SERVICE_NAME, TUIConstants.TUILive.METHOD_LOGOUT, null);
    }

    public static boolean isUserLogined() {
        return TUILogin.isUserLogined();
    }

    public static void sendLiveGroupMessage(String data) {
        Map<String, Object> map = new HashMap<>();
        map.put(TUIConstants.TUIChat.MESSAGE_CONTENT, data);
        TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_SEND_MESSAGE, map);
    }

    public static void startActivity(String activityName, Bundle param) {
        TUICore.startActivity(activityName, param);
    }

    public static void startChat(String chatId, String chatName, int chatType) {
        Bundle bundle = new Bundle();
        bundle.putString(TUIConstants.TUIChat.CHAT_ID, chatId);
        bundle.putString(TUIConstants.TUIChat.CHAT_NAME, chatName);
        bundle.putInt(TUIConstants.TUIChat.CHAT_TYPE, chatType);
        if (chatType == V2TIMConversation.V2TIM_C2C) {
            TUICore.startActivity(TUIConstants.TUIChat.C2C_CHAT_ACTIVITY_NAME, bundle);
        } else if (chatType == V2TIMConversation.V2TIM_GROUP) {
            TUICore.startActivity(TUIConstants.TUIChat.GROUP_CHAT_ACTIVITY_NAME, bundle);
        }
    }

    public static void startCall(String sender, String data) {
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUICalling.SENDER, sender);
        param.put(TUIConstants.TUICalling.PARAM_NAME_CALLMODEL, data);
        TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_START_CALL, param);
    }

}
