package com.tencent.qcloud.tim.tuiofflinepush;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMOfflinePushConfig;
import com.tencent.qcloud.tim.tuiofflinepush.utils.BrandUtil;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;

public class TUIOfflinePushManager {
    public static final String TAG = TUIOfflinePushManager.class.getSimpleName();
    private static TUIOfflinePushManager instance;

    private String pushToken;
    private boolean isInternationalFlavor = false;
    private PushSetting pushSetting = new PushSetting();

    public static TUIOfflinePushManager getInstance() {
        if (instance == null) {
            instance = new TUIOfflinePushManager();
        }
        return instance;
    }


    public void registerPush(Context context, String userId) {
        initPush(context, userId);
    }

    public void unRegisterPush(Context context, String userId) {
        unInitPush(context, userId);
    }

    public String getPushToken() {
        return pushToken;
    }

    public void setInternationalFlavor(boolean internationalFlavor) {
        isInternationalFlavor = internationalFlavor;
    }

    public void setPushToken(String pushToken) {
        this.pushToken = pushToken;
    }


    public void initPush(Context context, String userId) {
        if (pushSetting == null) {
            pushSetting = new PushSetting();
        }
        pushSetting.initPush(context);
        pushSetting.bindUserID(userId);
    }

    public void unInitPush(Context context, String userId){
        if (pushSetting == null) {
            pushSetting = new PushSetting();
        }
        pushSetting.unBindUserID(context, userId);
        pushSetting.unInitPush(context);
    }

    public void setPushTokenToTIM(String token) {
        setPushToken(token);

        if (TextUtils.isEmpty(pushToken)) {
            TUIOfflinePushLog.i(TAG, "setPushTokenToTIM third token is empty");
            return;
        }
        V2TIMOfflinePushConfig v2TIMOfflinePushConfig = null;
        if (!PushSetting.isTPNSChannel) {
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
            v2TIMOfflinePushConfig = new V2TIMOfflinePushConfig(businessID, pushToken, false);
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

    public void updateBadge(final Context context, final int number) {
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
