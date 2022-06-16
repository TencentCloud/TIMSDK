package com.tencent.qcloud.tim.tuiofflinepush;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;

import java.lang.reflect.Field;
import java.util.Map;

public class TUIOfflinePushService extends ServiceInitializer implements ITUINotification, ITUIService {
    public static final String TAG = TUIOfflinePushService.class.getSimpleName();

    public static Context appContext;
    public String userId;

    @Override
    public void init(Context context) {
        appContext = context;
        userId = V2TIMManager.getInstance().getLoginUser();

        initListener();
        initActivityLifecycle();
        initFlavor();
    }

    private void initListener() {
        TUICore.registerService(TUIConstants.TUIOfflinePush.SERVICE_NAME, this);

        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_KICKED_OFFLINE,
                this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_SIG_EXPIRED,
                this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS,
                this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
                TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS,
                this);

    }

    private void initActivityLifecycle() {
        if (appContext instanceof Application) {
            ((Application) appContext).registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
                private int foregroundActivities = 0;
                private boolean isChangingConfiguration;

                private final V2TIMConversationListener unreadListener = new V2TIMConversationListener() {
                    @Override
                    public void onTotalUnreadMessageCountChanged(long totalUnreadCount) {
                        TUIOfflinePushManager.getInstance().updateBadge(appContext, (int) totalUnreadCount);
                    }
                };

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
                    if (foregroundActivities == 1 && !isChangingConfiguration) {
                        // 应用切到前台
                        TUIOfflinePushLog.i(TAG, "application enter foreground");
                        V2TIMManager.getOfflinePushManager().doForeground(new V2TIMCallback() {
                            @Override
                            public void onError(int code, String desc) {
                                TUIOfflinePushLog.e(TAG, "doForeground err = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                            }

                            @Override
                            public void onSuccess() {
                                TUIOfflinePushLog.i(TAG, "doForeground success");
                            }
                        });

                        V2TIMManager.getConversationManager().removeConversationListener(unreadListener);
                    }
                    isChangingConfiguration = false;
                }

                @Override
                public void onActivityResumed(Activity activity) {

                }

                @Override
                public void onActivityPaused(Activity activity) {

                }

                @Override
                public void onActivityStopped(Activity activity) {
                    foregroundActivities--;
                    if (foregroundActivities == 0) {
                        // 应用切到后台
                        TUIOfflinePushLog.i(TAG, "application enter background");
                        V2TIMManager.getConversationManager().getTotalUnreadMessageCount(new V2TIMValueCallback<Long>() {
                            @Override
                            public void onSuccess(Long aLong) {
                                int totalCount = aLong.intValue();
                                V2TIMManager.getOfflinePushManager().doBackground(totalCount, new V2TIMCallback() {
                                    @Override
                                    public void onError(int code, String desc) {
                                        TUIOfflinePushLog.e(TAG, "doBackground err = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                                    }

                                    @Override
                                    public void onSuccess() {
                                        TUIOfflinePushLog.i(TAG, "doBackground success");
                                    }
                                });
                            }

                            @Override
                            public void onError(int code, String desc) {

                            }
                        });

                        V2TIMManager.getConversationManager().addConversationListener(unreadListener);
                    }
                    isChangingConfiguration = activity.isChangingConfigurations();
                }

                @Override
                public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {

                }

                @Override
                public void onActivityDestroyed(Activity activity) {

                }
            });
        }
    }

    private void initFlavor() {
        boolean isInternationalFlavor = false;
        String buildFlavor = (String) getBuildConfigValue("FLAVOR");
        if (TextUtils.equals("international", buildFlavor)) {
            isInternationalFlavor = true;
        } else {
            isInternationalFlavor= false;
        }

        TUIOfflinePushManager.getInstance().setInternationalFlavor(isInternationalFlavor);
    }

    private static Object getBuildConfigValue(String fieldName) {
        try {
            String appPackageName = appContext.getPackageName();
            if (TextUtils.equals("com.tencent.qcloud.tim.tuikit", appPackageName)) {
                appPackageName = "com.tencent.qcloud.tim.demo";
            }
            Class<?> clazz = Class.forName(appPackageName + ".BuildConfig");
            Field field = clazz.getField(fieldName);
            return field.get(null);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (NullPointerException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "local";
    }

    private void logined() {
        TUIOfflinePushManager.getInstance().registerPush(appContext, userId);
    }

    private void logout() {
        TUIOfflinePushManager.getInstance().unRegisterPush(appContext, userId);
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        TUIOfflinePushLog.d(TAG, "onNotifyEvent key = " + key + "subKey = " + subKey);
        if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED.equals(key)) {
            if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_KICKED_OFFLINE.equals(subKey) ||
                    TUIConstants.TUILogin.EVENT_SUB_KEY_USER_SIG_EXPIRED.equals(subKey) ||
                    TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS.equals(subKey)){
                logout();
            } else if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS.equals(subKey)) {
                logined();
            }
        }
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        TUIOfflinePushLog.d(TAG, "onCall method = " + method);
        if (TextUtils.equals(TUIConstants.TUIOfflinePush.METHOD_UNREGISTER_PUSH, method)) {
            logout();
        }
        return null;
    }
}
