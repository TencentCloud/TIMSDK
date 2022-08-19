package com.tencent.qcloud.tim.demo.utils;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.RequiresApi;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.SplashActivity;
import com.tencent.qcloud.tim.demo.push.HandleOfflinePushCallBack;
import com.tencent.qcloud.tim.demo.push.OfflineMessageBean;
import com.tencent.qcloud.tim.demo.push.OfflineMessageDispatcher;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.TUIBuild;

import java.util.Locale;


public class TUIUtils {
    public static final String TAG = TUIUtils.class.getSimpleName();

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

    public static boolean isZh(Context context) {
        Locale locale;
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.N) {
            locale = context.getResources().getConfiguration().locale;
        } else {
            locale = context.getResources().getConfiguration().getLocales().get(0);
        }
        String language = locale.getLanguage();
        if (language.endsWith("zh"))
            return true;
        else
            return false;
    }

    public static int getCurrentVersionCode(Context context) {
        try {
            return context.getPackageManager().getPackageInfo(context.getPackageName(), 0).versionCode;
        } catch (PackageManager.NameNotFoundException ignored) {
            DemoLog.e(TAG, "getCurrentVersionCode exception= " + ignored);
        }
        return 0;
    }

    public static void handleOfflinePush(Intent intent, HandleOfflinePushCallBack callBack) {
        Context context = DemoApplication.instance().getApplicationContext();
        if (V2TIMManager.getInstance().getLoginStatus() == V2TIMManager.V2TIM_STATUS_LOGOUT) {
            Intent intentAction = new Intent(context, SplashActivity.class);
            if (intent != null) {
                intentAction.putExtras(intent);
            }
            intentAction.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intentAction);
            if (callBack != null) {
                callBack.onHandleOfflinePush(false);
            }
            return;
        }

        final OfflineMessageBean bean = OfflineMessageDispatcher.parseOfflineMessage(intent);
        if (bean != null) {
            if (callBack != null) {
                callBack.onHandleOfflinePush(true);
            }
            NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            if (manager != null) {
                manager.cancelAll();
            }

            if (bean.action == OfflineMessageBean.REDIRECT_ACTION_CHAT) {
                if (TextUtils.isEmpty(bean.sender)) {
                    return;
                }
                TUIUtils.startChat(bean.sender, bean.nickname, bean.chatType);
            }
        }
    }

    public static void handleOfflinePush(String ext, HandleOfflinePushCallBack callBack) {
        Context context = DemoApplication.instance().getApplicationContext();
        if (V2TIMManager.getInstance().getLoginStatus() == V2TIMManager.V2TIM_STATUS_LOGOUT) {
            Intent intentAction = new Intent(context, SplashActivity.class);
            if (!TextUtils.isEmpty(ext)) {
                intentAction.putExtra(TUIConstants.TUIOfflinePush.NOTIFICATION_EXT_KEY, ext);
            }
            intentAction.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intentAction);
            if (callBack != null) {
                callBack.onHandleOfflinePush(false);
            }
            return;
        }

        final OfflineMessageBean bean = OfflineMessageDispatcher.getOfflineMessageBeanFromContainer(ext);
        if (bean != null) {
            if (callBack != null) {
                callBack.onHandleOfflinePush(true);
            }
            NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            if (manager != null) {
                manager.cancelAll();
            }

            if (bean.action == OfflineMessageBean.REDIRECT_ACTION_CHAT) {
                if (TextUtils.isEmpty(bean.sender)) {
                    return;
                }
                TUIUtils.startChat(bean.sender, bean.nickname, bean.chatType);
            }
        }
    }

}
