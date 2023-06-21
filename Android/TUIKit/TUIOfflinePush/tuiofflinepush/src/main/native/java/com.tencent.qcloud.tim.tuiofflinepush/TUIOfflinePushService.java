package com.tencent.qcloud.tim.tuiofflinepush;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMManager;
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

    private long totalUnread;

    @Override
    public void init(Context context) {
        appContext = context;
        userId = V2TIMManager.getInstance().getLoginUser();

        initContext();
        initListener();
        initActivityLifecycle();
        initFlavor();
    }

    private void initListener() {
        TUICore.registerService(TUIConstants.TUIOfflinePush.SERVICE_NAME, this);

        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_KICKED_OFFLINE, this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_SIG_EXPIRED, this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS, this);

        TUICore.registerEvent(
            TUIOfflinePushConfig.EVENT_KEY_OFFLINE_MESSAGE_PRIVATE_RING, TUIOfflinePushConfig.EVENT_SUB_KEY_OFFLINE_MESSAGE_PRIVATE_RING, this);
    }

    private void initActivityLifecycle() {
        if (appContext instanceof Application) {
            final V2TIMConversationListener unreadListener = new V2TIMConversationListener() {
                @Override
                public void onTotalUnreadMessageCountChanged(long totalUnreadCount) {
                    TUIOfflinePushService.this.totalUnread = totalUnreadCount;
                    TUIOfflinePushManager.getInstance().updateBadge(appContext, (int) TUIOfflinePushService.this.totalUnread);
                }
            };
            final ITUINotification unreadNotification = new ITUINotification() {
                @Override
                public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
                    if (param != null) {
                        Object unreadCount = param.get(TUIConstants.TUIConversation.TOTAL_UNREAD_COUNT);
                        if (unreadCount instanceof Long) {
                            TUIOfflinePushService.this.totalUnread = (long) unreadCount;
                            TUIOfflinePushManager.getInstance().updateBadge(appContext, (int) TUIOfflinePushService.this.totalUnread);
                        }
                    }
                }
            };

            ((Application) appContext).registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
                private int foregroundActivities = 0;
                private boolean isChangingConfiguration;

                @Override
                public void onActivityCreated(Activity activity, Bundle bundle) {
                    TUIOfflinePushLog.i(TAG, "onActivityCreated bundle: " + bundle);
                }

                @Override
                public void onActivityStarted(Activity activity) {
                    foregroundActivities++;
                    if (foregroundActivities == 1 && !isChangingConfiguration) {
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

                        V2TIMManager.getConversationManager().addConversationListener(unreadListener);
                        TUICore.registerEvent(
                            TUIConstants.TUIConversation.EVENT_UNREAD, TUIConstants.TUIConversation.EVENT_SUB_KEY_UNREAD_CHANGED, unreadNotification);
                    }
                    isChangingConfiguration = false;
                }

                @Override
                public void onActivityResumed(Activity activity) {}

                @Override
                public void onActivityPaused(Activity activity) {}

                @Override
                public void onActivityStopped(Activity activity) {
                    foregroundActivities--;
                    if (foregroundActivities == 0) {
                        TUIOfflinePushLog.i(TAG, "application enter background");
                        V2TIMManager.getOfflinePushManager().doBackground((int) totalUnread, new V2TIMCallback() {
                            @Override
                            public void onError(int code, String desc) {
                                TUIOfflinePushLog.e(TAG, "doBackground err = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                            }

                            @Override
                            public void onSuccess() {
                                TUIOfflinePushLog.i(TAG, "doBackground success");
                            }
                        });

                        V2TIMManager.getConversationManager().removeConversationListener(unreadListener);
                        TUICore.unRegisterEvent(
                            TUIConstants.TUIConversation.EVENT_UNREAD, TUIConstants.TUIConversation.EVENT_SUB_KEY_UNREAD_CHANGED, unreadNotification);
                    }
                    isChangingConfiguration = activity.isChangingConfigurations();
                }

                @Override
                public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {}

                @Override
                public void onActivityDestroyed(Activity activity) {}
            });
        }
    }

    private void initFlavor() {
        boolean isInternationalFlavor = false;
        String buildFlavor = (String) getBuildConfigValue("FLAVOR");
        if (TextUtils.equals("international", buildFlavor)) {
            isInternationalFlavor = true;
        } else {
            isInternationalFlavor = false;
        }

        TUIOfflinePushManager.getInstance().setInternationalFlavor(isInternationalFlavor);
    }

    void initContext() {
        TUIOfflinePushConfig.getInstance().setContext(appContext);
    }

    private static Object getBuildConfigValue(String fieldName) {
        try {
            String appPackageName = appContext.getPackageName();
            if (TextUtils.equals("com.tencent.qcloud.tim.tuikit", appPackageName)) {
                appPackageName = "com.tencent.qcloud.tim.demo";
            } else {
                return "local";
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
        TUIOfflinePushManager.getInstance().registerPush(appContext);
    }

    private void logout() {
        TUIOfflinePushManager.getInstance().unRegisterPush();
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        TUIOfflinePushLog.d(TAG, "onNotifyEvent key = " + key + "subKey = " + subKey);
        if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED.equals(key)) {
            if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_KICKED_OFFLINE.equals(subKey) || TUIConstants.TUILogin.EVENT_SUB_KEY_USER_SIG_EXPIRED.equals(subKey)
                || TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS.equals(subKey)) {
                logout();
            } else if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS.equals(subKey)) {
                logined();
            }
        } else if (TextUtils.equals(key, TUIOfflinePushConfig.EVENT_KEY_OFFLINE_MESSAGE_PRIVATE_RING)) {
            if (TextUtils.equals(subKey, TUIOfflinePushConfig.EVENT_SUB_KEY_OFFLINE_MESSAGE_PRIVATE_RING)) {
                Boolean isPrivateRing = (Boolean) param.get(TUIOfflinePushConfig.OFFLINE_MESSAGE_PRIVATE_RING);
                TUIOfflinePushConfig.getInstance().setAndroidPrivateRing(isPrivateRing);
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
