package com.tencent.qcloud.tim.tuiofflinepush;

import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMOfflinePushConfig;
import com.tencent.qcloud.tim.tuiofflinepush.OEMPush.OEMPushSetting;
import com.tencent.qcloud.tim.tuiofflinepush.TPNSPush.TPNSPushSetting;
import com.tencent.qcloud.tim.tuiofflinepush.utils.BrandUtil;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;

public class TUIOfflinePushManager {
    public static final String TAG = TUIOfflinePushManager.class.getSimpleName();
    private static TUIOfflinePushManager instance;

    private String pushToken;
    private boolean isInternationalFlavor = false;
    private PushSettingInterface pushSetting;
    private static boolean isTPNSChannel = false;

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
    public void registerPush(Context context, String userId) {
        initPush(context, userId);
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


    //************* 以下为组件内部调用 *************
    private String getPushToken() {
        return pushToken;
    }

    void setInternationalFlavor(boolean internationalFlavor) {
        isInternationalFlavor = internationalFlavor;
    }

    void setPushToken(String pushToken) {
        this.pushToken = pushToken;
    }

    private void initPush(Context context, String userId) {
        SharedPreferences sharedPreferences = context.getSharedPreferences("TUIKIT_DEMO_SETTINGS", context.MODE_PRIVATE);
        isTPNSChannel = sharedPreferences.getBoolean("isTPNSChannel", PrivateConstants.isTPNSChannel);
        TUIOfflinePushLog.i(TAG, "initPush isTPNSChannel = " + isTPNSChannel);

        if (isTPNSChannel) {
            pushSetting = new TPNSPushSetting();
        } else {
            pushSetting = new OEMPushSetting();
        }
        pushSetting.initPush(context);
        pushSetting.bindUserID(userId);
        pushSetting.setPushCallback(new PushCallback() {
            @Override
            public void onTokenCallback(String token) {
                setPushTokenToTIM(token);
            }

            @Override
            public void onBadgeCallback(Context context, int number) {
                updateBadge(context, number);
            }
        });
    }

    private void unInitPush(Context context, String userId){
        if (pushSetting == null) {
            if (isTPNSChannel) {
                pushSetting = new TPNSPushSetting();
            } else {
                pushSetting = new OEMPushSetting();
            }
        }
        pushSetting.unBindUserID(context, userId);
        pushSetting.unInitPush(context);
        pushSetting.setPushCallback(null);
    }
    
    public interface PushCallback {
        void onTokenCallback(String token);
        void onBadgeCallback(Context context, int number);
    }

    void setPushTokenToTIM(String token) {
        setPushToken(token);

        if (TextUtils.isEmpty(pushToken)) {
            TUIOfflinePushLog.i(TAG, "setPushTokenToTIM third token is empty");
            return;
        }
        V2TIMOfflinePushConfig v2TIMOfflinePushConfig = null;
        if (!isTPNSChannel) {
            long businessID;
            if (isInternationalFlavor) {
                TUIOfflinePushLog.i(TAG, "flavor international");
                if (BrandUtil.isBrandXiaoMi()) {
                    businessID = PrivateConstants.XM_PUSH_BUZID_ABROAD;
                } else if (BrandUtil.isBrandHuawei()) {
                    businessID = PrivateConstants.HW_PUSH_BUZID_ABROAD;
                } else if (BrandUtil.isBrandMeizu()) {
                    businessID = PrivateConstants.MZ_PUSH_BUZID_ABROAD;
                } else if (BrandUtil.isBrandOppo()) {
                    businessID = PrivateConstants.OPPO_PUSH_BUZID_ABROAD;
                } else if (BrandUtil.isBrandVivo()) {
                    businessID = PrivateConstants.VIVO_PUSH_BUZID_ABROAD;
                } else if (BrandUtil.isGoogleServiceSupport()) {
                    businessID = PrivateConstants.GOOGLE_FCM_PUSH_BUZID_ABROAD;
                } else {
                    return;
                }
            } else {
                TUIOfflinePushLog.i(TAG, "flavor local");
                if (BrandUtil.isBrandXiaoMi()) {
                    businessID = PrivateConstants.XM_PUSH_BUZID;
                } else if (BrandUtil.isBrandHuawei()) {
                    businessID = PrivateConstants.HW_PUSH_BUZID;
                } else if (BrandUtil.isBrandMeizu()) {
                    businessID = PrivateConstants.MZ_PUSH_BUZID;
                } else if (BrandUtil.isBrandOppo()) {
                    businessID = PrivateConstants.OPPO_PUSH_BUZID;
                } else if (BrandUtil.isBrandVivo()) {
                    businessID = PrivateConstants.VIVO_PUSH_BUZID;
                } else if (BrandUtil.isGoogleServiceSupport()) {
                    businessID = PrivateConstants.GOOGLE_FCM_PUSH_BUZID;
                } else {
                    return;
                }
            }
            v2TIMOfflinePushConfig = new V2TIMOfflinePushConfig(businessID, pushToken);
            TUIOfflinePushLog.d(TAG, "setOfflinePushConfig businessID = " + businessID +  " pushToken = " + pushToken);
        } else {
            // tpns 接入需要在控制台添加授权绑定操作才可以执行
            // 规避后台一个 bug，国际版 传入空值会导致设置 token 失败， 所以随便传一个值。
            if (false/*TextUtils.equals(BuildConfig.FLAVOR, Constants.FLAVOR_INTERNATIONAL)*/) {
                v2TIMOfflinePushConfig = new V2TIMOfflinePushConfig(PrivateConstants.XM_PUSH_BUZID, pushToken, true);
            } else {
                v2TIMOfflinePushConfig = new V2TIMOfflinePushConfig(0, pushToken, true);
            }
            TUIOfflinePushLog.d(TAG, "setOfflinePushConfig tpns pushToken = " + pushToken);
        }

        V2TIMManager.getOfflinePushManager().setOfflinePushConfig(v2TIMOfflinePushConfig, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIOfflinePushLog.d(TAG, "setOfflinePushToken err code = " + code + " desc = " + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess() {
                TUIOfflinePushLog.d(TAG, "setOfflinePushToken success");
            }
        });
    }

    void updateBadge(final Context context, final int number) {
        if (!BrandUtil.isBrandHuawei()) {
            return;
        }
        TUIOfflinePushLog.i(TAG, "huawei badge = " + number);
        try {
            Bundle extra = new Bundle();
            extra.putString("package", context.getPackageName());
            extra.putString("class", PrivateConstants.BADGE_CLASS_NAME);
            extra.putInt("badgenumber", number);
            context.getContentResolver().call(Uri.parse("content://com.huawei.android.launcher.settings/badge/"), "change_badge", null, extra);
        } catch (Exception e) {
            TUIOfflinePushLog.w(TAG, "huawei badge exception: " + e.getLocalizedMessage());
        }
    }
}
