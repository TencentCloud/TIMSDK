package com.tencent.qcloud.uikit;

import android.content.Context;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMConnListener;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMGroupEventListener;
import com.tencent.imsdk.TIMGroupTipsElem;
import com.tencent.imsdk.TIMLogLevel;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMMessageListener;
import com.tencent.imsdk.TIMOfflinePushListener;
import com.tencent.imsdk.TIMOfflinePushNotification;
import com.tencent.imsdk.TIMRefreshListener;
import com.tencent.imsdk.TIMSdkConfig;
import com.tencent.imsdk.TIMUserConfig;
import com.tencent.imsdk.TIMUserStatusListener;
import com.tencent.imsdk.ext.message.TIMUserConfigMsgExt;
import com.tencent.qcloud.uikit.business.chat.c2c.model.C2CChatManager;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.business.session.model.SessionManager;
import com.tencent.qcloud.uikit.common.BackgroundTasks;
import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.common.component.face.FaceManager;
import com.tencent.qcloud.uikit.common.utils.FileUtil;
import com.tencent.qcloud.uikit.operation.UIKitMessageRevokedManager;

import java.util.List;

/**
 * Created by valexhuang on 2018/6/22.
 */

public class TUIKit {
    private static Context appContext;
    private static BaseUIKitConfigs baseConfigs;

    /**
     * TUIKit的初始化函数
     *
     * @param context  应用的上下文，一般为对应应用的ApplicationContext
     * @param sdkAppID 您在腾讯云注册应用时分配的sdkAppID
     * @param configs  TUIKit的相关配置项，一般使用默认即可，需特殊配置参考API文档
     */
    public static void init(Context context, int sdkAppID, BaseUIKitConfigs configs) {
        appContext = context;
        baseConfigs = configs;
        long current = System.currentTimeMillis();

        initIM(context, sdkAppID);
        System.out.println("TUIKIT>>>>>>>>>>>>>>>>>>" + (System.currentTimeMillis() - current));
        current = System.currentTimeMillis();

        BackgroundTasks.initInstance();
        FileUtil.initPath();
        System.out.println("TUIKIT>>>>>>>>>>>>>>>>>>" + (System.currentTimeMillis() - current));
        current = System.currentTimeMillis();
        FaceManager.loadFaceFiles();
        System.out.println("TUIKIT>>>>>>>>>>>>>>>>>>" + (System.currentTimeMillis() - current));

        SessionManager.getInstance().init();
        C2CChatManager.getInstance().init();
        GroupChatManager.getInstance().init();
    }

    public static void login(String userid, String usersig, final IUIKitCallBack callback) {
        TIMManager.getInstance().login(userid, usersig, new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                callback.onError("TUIKit login", code, desc);
            }

            @Override
            public void onSuccess() {
                callback.onSuccess(null);
            }
        });
    }

    private static void initIM(Context context, int sdkAppID) {
        TIMSdkConfig config = getBaseConfigs().getTIMSdkConfig();
        if (config == null) {
            config = new TIMSdkConfig(sdkAppID)
                    .setLogLevel(TIMLogLevel.DEBUG).enableCrashReport(true);
        }
        TIMManager.getInstance().init(context, config);
        // 设置离线消息通知
        TIMManager.getInstance().setOfflinePushListener(new TIMOfflinePushListener() {

            @Override
            public void handleNotification(TIMOfflinePushNotification var1) {

            }
        });

        TIMUserConfig userConfig = new TIMUserConfig();
        userConfig.setUserStatusListener(new TIMUserStatusListener() {
            @Override
            public void onForceOffline() {
                if (baseConfigs.getIMEventListener() != null) {
                    baseConfigs.getIMEventListener().onForceOffline();
                }
                TUIKit.unInit();
            }

            @Override
            public void onUserSigExpired() {
                if (baseConfigs.getIMEventListener() != null) {
                    baseConfigs.getIMEventListener().onUserSigExpired();
                }
                TUIKit.unInit();
            }
        });

        userConfig.setConnectionListener(new TIMConnListener() {
            @Override
            public void onConnected() {
                if (getBaseConfigs().getIMEventListener() != null)
                    getBaseConfigs().getIMEventListener().onConnected();
            }

            @Override
            public void onDisconnected(int code, String desc) {
                if (getBaseConfigs().getIMEventListener() != null)
                    getBaseConfigs().getIMEventListener().onDisconnected(code, desc);
            }

            @Override
            public void onWifiNeedAuth(String name) {
                if (getBaseConfigs().getIMEventListener() != null)
                    getBaseConfigs().getIMEventListener().onWifiNeedAuth(name);
            }
        });

        userConfig.setRefreshListener(new TIMRefreshListener() {
            @Override
            public void onRefresh() {

            }

            @Override
            public void onRefreshConversation(List<TIMConversation> conversations) {
                SessionManager.getInstance().onRefreshConversation(conversations);
                if (TUIKit.getBaseConfigs().getIMEventListener() != null) {
                    TUIKit.getBaseConfigs().getIMEventListener().onRefreshConversation(conversations);
                }
            }
        });

        userConfig.setGroupEventListener(new TIMGroupEventListener() {
            @Override
            public void onGroupTipsEvent(TIMGroupTipsElem elem) {
                if (TUIKit.getBaseConfigs().getIMEventListener() != null) {
                    TUIKit.getBaseConfigs().getIMEventListener().onGroupTipsEvent(elem);
                }
            }
        });

        TIMManager.getInstance().addMessageListener(new TIMMessageListener() {
            @Override
            public boolean onNewMessages(List<TIMMessage> msgs) {
                if (TUIKit.getBaseConfigs().getIMEventListener() != null) {
                    TUIKit.getBaseConfigs().getIMEventListener().onNewMessages(msgs);
                }
                return false;
            }
        });

        TIMUserConfigMsgExt ext = new TIMUserConfigMsgExt(userConfig);
        ext.setMessageRevokedListener(UIKitMessageRevokedManager.getInstance());
        TIMManager.getInstance().setUserConfig(ext);

    }


    public static void unInit() {
        SessionManager.getInstance().destroySession();
        C2CChatManager.getInstance().destroyC2CChat();
        GroupChatManager.getInstance().destroyGroupChat();
    }


    public static Context getAppContext() {
        return appContext;
    }

    public static BaseUIKitConfigs getBaseConfigs() {
        return baseConfigs;
    }
}
