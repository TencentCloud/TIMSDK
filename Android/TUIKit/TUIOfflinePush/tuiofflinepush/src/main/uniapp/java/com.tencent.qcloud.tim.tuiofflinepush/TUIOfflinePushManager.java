package com.tencent.qcloud.tim.tuiofflinepush;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import com.alibaba.fastjson.JSONObject;
import com.tencent.qcloud.tim.tuiofflinepush.interfaces.PushCallback;
import com.tencent.qcloud.tim.tuiofflinepush.interfaces.PushSettingInterface;
import com.tencent.qcloud.tim.tuiofflinepush.notification.ParseNotification;
import com.tencent.qcloud.tim.tuiofflinepush.oempush.OEMPushSetting;
import com.tencent.qcloud.tim.tuiofflinepush.utils.BrandUtil;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushErrorBean;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;
import io.dcloud.feature.uniapp.bridge.UniJSCallback;

public class TUIOfflinePushManager {
    public static final String TAG = TUIOfflinePushManager.class.getSimpleName();
    private static TUIOfflinePushManager instance;

    private String pushToken;
    private PushSettingInterface pushSetting;
    private Context mContext;

    private UniJSCallback jsNotificationCallback;
    private Intent mClickIntentData;

    private UniJSCallback jsLifeCycleCallback;

    private TUIOfflinePushManager() {}

    public static TUIOfflinePushManager getInstance() {
        if (instance == null) {
            instance = new TUIOfflinePushManager();
        }
        return instance;
    }

    /**
     *  注册离线推送服务, IM 账号登录成功时调用
     *
     *  @note 请注意：
     *  如果您没有使用 TUILogin 提供的接口，您需要在完成登录操作后，手动调用该接口即可开启推送服务
     */
    public void registerPush(Context context, String userId, UniJSCallback uniJSCallback) {
        TUIOfflinePushLog.d(TAG, "registerPush");
        mContext = context;
        initPush(context, userId, uniJSCallback);
    }

    /**
     *  反注册离线推送服务
     *
     *  @note 请注意：
     *  如果您没有使用 TUILogin 提供的接口，您需要在完成登出操作后，手动调用该接口即可关闭推送服务
     */
    public void unRegisterPush(Context context, String userId) {
        unInitPush(context, userId);
    }

    public Context getContext() {
        return mContext;
    }

    //************* 以下为组件内部调用 *************
    private String getPushToken() {
        return pushToken;
    }

    void setPushToken(String pushToken) {
        this.pushToken = pushToken;
    }

    private void initPush(Context context, String userId, UniJSCallback uniJSCallback) {
        if (pushSetting == null) {
            pushSetting = new OEMPushSetting();
        }
        pushSetting.setPushCallback(new PushCallback() {
            @Override
            public void onTokenCallback(String token) {
                TUIOfflinePushLog.e(TAG, "onTokenCallback-- token" + token);
                setPushTokenToTIM(token);
                uniJSCallback.invokeAndKeepAlive(token);
            }

            @Override
            public void onTokenErrorCallBack(TUIOfflinePushErrorBean errorBean) {
                TUIOfflinePushLog.e(TAG, "onTokenErrorCallBack-- ");
                uniJSCallback.invokeAndKeepAlive(errorBean);
            }
        });
        pushSetting.initPush(context);
    }

    private void unInitPush(Context context, String userId) {
        if (pushSetting == null) {
            pushSetting = new OEMPushSetting();
        }

        pushSetting.setPushCallback(null);
    }

    void setJsNotificationCallback(UniJSCallback jsNotificationCallback) {
        this.jsNotificationCallback = jsNotificationCallback;
        callJsNotificationCallback();
    }

    public void clickNotification(Intent clickIntentData) {
        setNotificationIntent(clickIntentData);
        callJsNotificationCallback();
    }

    void setNotificationIntent(Intent clickIntentData) {
        this.mClickIntentData = clickIntentData;
    }

    void callJsNotificationCallback() {
        if (mClickIntentData == null) {
            TUIOfflinePushLog.e(TAG, "mClickIntentData is null");
            return;
        }

        String ext = ParseNotification.parseOfflineMessage(mClickIntentData);
        if (TextUtils.isEmpty(ext)) {
            TUIOfflinePushLog.e(TAG, "ext is null");
        }

        // 点击事件回调js
        TUIOfflinePushLog.d(TAG, "callJsNotificationCallback ext = " + ext);
        if (jsNotificationCallback != null) {
            JSONObject data = new JSONObject();
            data.put(TUIOfflinePushModule.RESPONSE_NOTIFICATION_KEY, ext);
            TUIOfflinePushLog.d(TAG, "callJsNotificationCallback invoke data--" + data);
            jsNotificationCallback.invokeAndKeepAlive(data);
            mClickIntentData = null;
        } else {
            TUIOfflinePushLog.e(TAG, "callJsNotificationCallback jsNotificationCallback is null");
        }
    }

    void setJsLifeCycleCallback(UniJSCallback jsLifeCycleCallback) {
        this.jsLifeCycleCallback = jsLifeCycleCallback;
    }

    void initActivityLifecycle(Context context) {
        if (context instanceof Application) {
            ((Application) context).registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
                private int foregroundActivities = 0;
                private boolean isChangingConfiguration;

                @Override
                public void onActivityCreated(Activity activity, Bundle bundle) {
                    TUIOfflinePushLog.i(TAG, "onActivityCreated bundle: " + bundle);
                    if (bundle != null) { // 若bundle不为空则程序异常结束
                        // 重启整个程序
                    }
                }

                @Override
                public void onActivityStarted(Activity activity) {
                    foregroundActivities++;
                    TUIOfflinePushLog.i(TAG, "onActivityStarted foregroundActivities = " + foregroundActivities);
                    TUIOfflinePushLog.i(TAG, "onActivityStarted isChangingConfiguration = " + isChangingConfiguration);
                    if (foregroundActivities == 1 && !isChangingConfiguration) {
                        TUIOfflinePushLog.i(TAG, "application enter foreground");
                        if (jsLifeCycleCallback != null) {
                            JSONObject data = new JSONObject();
                            data.put(TUIOfflinePushModule.RESPONSE_APPSHOW_KEY, 1);
                            TUIOfflinePushLog.d(TAG, "calljsLifeCycleCallback invoke data--" + data);
                            jsLifeCycleCallback.invokeAndKeepAlive(data);
                        } else {
                            TUIOfflinePushLog.e(TAG, "jsLifeCycleCallback is null");
                        }
                    }
                    isChangingConfiguration = false;
                }

                @Override
                public void onActivityResumed(Activity activity) {
                    TUIOfflinePushLog.i(TAG, "onActivityResumed foregroundActivities = " + foregroundActivities);
                }

                @Override
                public void onActivityPaused(Activity activity) {
                    TUIOfflinePushLog.i(TAG, "onActivityPaused foregroundActivities = " + foregroundActivities);
                }

                @Override
                public void onActivityStopped(Activity activity) {
                    foregroundActivities--;
                    TUIOfflinePushLog.i(TAG, "onActivityStopped foregroundActivities = " + foregroundActivities);
                    if (foregroundActivities == 0) {
                        // 应用切到后台
                        TUIOfflinePushLog.i(TAG, "application enter background");
                        if (jsLifeCycleCallback != null) {
                            JSONObject data = new JSONObject();
                            data.put(TUIOfflinePushModule.RESPONSE_APPSHOW_KEY, 0);
                            TUIOfflinePushLog.d(TAG, "calljsLifeCycleCallback invoke data--" + data);
                            jsLifeCycleCallback.invokeAndKeepAlive(data);
                        } else {
                            TUIOfflinePushLog.e(TAG, "jsLifeCycleCallback is null");
                        }
                    }
                    isChangingConfiguration = activity.isChangingConfigurations();
                    TUIOfflinePushLog.i(TAG, "onActivityStarted isChangingConfiguration = " + isChangingConfiguration);
                }

                @Override
                public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {}

                @Override
                public void onActivityDestroyed(Activity activity) {
                    TUIOfflinePushLog.i(TAG, "onActivityDestroyed foregroundActivities = " + foregroundActivities);
                }
            });
        }
    }

    void setPushTokenToTIM(String token) {
        setPushToken(token);

        if (TextUtils.isEmpty(pushToken)) {
            TUIOfflinePushLog.i(TAG, "setPushTokenToTIM third token is empty");
            return;
        }
    }
}
