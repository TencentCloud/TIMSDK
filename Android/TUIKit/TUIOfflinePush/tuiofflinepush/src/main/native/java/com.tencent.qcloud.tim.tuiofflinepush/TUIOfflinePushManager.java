package com.tencent.qcloud.tim.tuiofflinepush;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMOfflinePushConfig;
import com.tencent.qcloud.tim.tuiofflinepush.interfaces.PushCallback;
import com.tencent.qcloud.tim.tuiofflinepush.interfaces.PushSettingInterface;
import com.tencent.qcloud.tim.tuiofflinepush.notification.ParseNotification;
import com.tencent.qcloud.tim.tuiofflinepush.oempush.OEMPushSetting;
import com.tencent.qcloud.tim.tuiofflinepush.utils.BrandUtil;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushErrorBean;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushParamBean;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushUtils;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import java.util.HashMap;

public class TUIOfflinePushManager {
    public static final String TAG = TUIOfflinePushManager.class.getSimpleName();
    private static TUIOfflinePushManager instance;

    private String pushToken;
    private boolean isInternationalFlavor = false;
    private PushSettingInterface pushSetting;

    private Intent mNotificationIntent;
    private long mBussinessId = 0;
    private boolean mAutoRegisterPush = true;

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
     *
     *
     *  Register offline push service, called when IM account login is successful
     *
     *  @note
     *  If you do not use the interface provided by TUILogin, you need to manually call the interface after completing the login operation to enable the push
     * service
     */
    public void registerPush(Context context) {
        if (!mAutoRegisterPush) {
            TUIOfflinePushLog.e(TAG, "you are calling api: registerPush(String json, Context context)");
            return;
        }
        initConfig(context);
        initPush(context);
    }

    /**
     *  手动注册离线推送服务, IM 账号登录成功时调用,调用该接口不需要再填充参数到组件的 PrivateConstants 里。
     *
     *  Register offline push service, called when IM account login is successful.Calling this interface does not require filling parameters into the
     * component's PrivateConstants.
     *
     *  @param  json：
     * {
     *    // huawei
     *   "huaweiPushBussinessId": "",    // 在腾讯云控制台上传第三方推送证书后分配的证书ID  // The certificate ID assigned in the Tencent Cloud console
     *   "huaweiBadgeClassName": "", // 角标参数，默认为应用的 launcher 界面的类名 // Angular parameter, defaults to the class name of the application's
     * launcher interface
     *
     *   // xiaomi
     *   "xiaomiPushBussinessId": "",// 在腾讯云控制台上传第三方推送证书后分配的证书ID // The certificate ID assigned in the Tencent Cloud console
     *   "xiaomiPushAppId": "",// 小米开放平台分配的应用APPID  // APPID, Allocated by Xiaomi Open Platform
     *   "xiaomiPushAppKey": "",// 小米开放平台分配的应用APPKEY // APPKEY, Allocated by Xiaomi Open Platform
     *
     *   // meizu
     *   "meizuPushBussinessId": "", // 在腾讯云控制台上传第三方推送证书后分配的证书ID // The certificate ID assigned in the Tencent Cloud console
     *   "meizuPushAppId": "",// 魅族开放平台分配的应用APPID // APPID, Allocated by meizu Open Platform
     *   "meizuPushAppKey": "",// 魅族开放平台分配的应用APPKEY // APPKEY, Allocated by meizu Open Platform
     *
     *   // vivo
     *   "vivoPushBussinessId": "", // 在腾讯云控制台上传第三方推送证书后分配的证书ID // The certificate ID assigned in the Tencent Cloud console
     *
     *   // google
     *   "fcmPushBussinessId": "", // 在腾讯云控制台上传第三方推送证书后分配的证书ID // The certificate ID assigned in the Tencent Cloud console
     *
     *   // oppo
     *   "oppoPushBussinessId": "", // 在腾讯云控制台上传第三方推送证书后分配的证书ID // The certificate ID assigned in the Tencent Cloud console
     *   "oppoPushAppKey": "",// oppo开放平台分配的应用 AppKey // AppKey, Allocated by OPPO Open Platform
     *   "oppoPushAppSecret": "",// oppo开放平台分配的应用 AppSecret // AppSecret, Allocated by OPPO Open Platform
     *
     *   // honor
     *   "honorPushBussinessId": "",  // 在腾讯云控制台上传第三方推送证书后分配的证书ID  // The certificate ID assigned in the Tencent Cloud console
     *  }
     *
     */
    public void registerPush(String json, Context context) {
        if (TextUtils.isEmpty(json)) {
            TUIOfflinePushLog.e(TAG, "registerPush json is null");
            return;
        }

        mAutoRegisterPush = false;
        initConfig(context);
        boolean success = parseJson2TUIOfflinePushParamBean(json);
        if (success) {
            initPush(context);
        } else {
            TUIOfflinePushLog.e(TAG, "parseJson2TUIOfflinePushParamBean failed");
        }
    }

    /**
     *  反注册离线推送服务
     *
     *  @note 请注意：
     *  如果您没有使用 TUILogin 提供的接口，您需要在完成登出操作后，手动调用该接口即可关闭推送服务
     *
     *  Unregister offline push service
     *
     *  @note
     *  If you do not use the interface provided by TUILogin, you need to manually call this interface after completing the logout operation to close the push
     * service
     */
    public void unRegisterPush() {
        unInitPush();
    }

    //************* 以下为组件内部调用  The following is the internal call of the component*************
    private String getPushToken() {
        return pushToken;
    }

    void setInternationalFlavor(boolean internationalFlavor) {
        isInternationalFlavor = internationalFlavor;
    }

    void setPushToken(String pushToken) {
        this.pushToken = pushToken;
    }

    boolean parseJson2TUIOfflinePushParamBean(String json) {
        TUIOfflinePushParamBean tuiOfflinePushParamBean = null;
        try {
            tuiOfflinePushParamBean = new Gson().fromJson(json, TUIOfflinePushParamBean.class);
            if (tuiOfflinePushParamBean != null) {
                mBussinessId = TUIOfflinePushUtils.json2TUIOfflinePushParamBean(tuiOfflinePushParamBean);
                return true;
            }
        } catch (Exception e) {
            TUIOfflinePushLog.e(TAG, "e =" + e);
        }

        return false;
    }

    private void initPush(Context context) {
        if (pushSetting == null) {
            pushSetting = new OEMPushSetting();
        }
        pushSetting.setPushCallback(new PushCallback() {
            @Override
            public void onTokenCallback(String token) {
                setPushTokenToTIM(token);
            }

            @Override
            public void onTokenErrorCallBack(TUIOfflinePushErrorBean errorBean) {
                if (errorBean != null) {
                    TUIOfflinePushLog.e(TAG, "onTokenErrorCallBack code = " + errorBean.getErrorCode() + ", code des = " + errorBean.getErrorDescription());
                }
            }
        });
        pushSetting.initPush(context);
    }

    private void unInitPush() {
        if (pushSetting == null) {
            pushSetting = new OEMPushSetting();
        }

        pushSetting.setPushCallback(null);
    }

    void initConfig(Context context) {
        TUIOfflinePushConfig.getInstance().setContext(context);
    }

    public void clickNotification(Intent clickIntentData) {
        setNotificationIntent(clickIntentData);
        parseNotificationAndSendBroadCast();
    }

    public void setNotificationIntent(Intent mNotificationIntent) {
        this.mNotificationIntent = mNotificationIntent;
    }

    public void parseNotificationAndSendBroadCast() {
        if (mNotificationIntent == null) {
            Log.e(TAG, "mClickIntentData is null");
            return;
        }

        // callback "ext"
        String ext = ParseNotification.parseOfflineMessage(mNotificationIntent);
        if (TextUtils.isEmpty(ext)) {
            Log.e(TAG, "ext is null");
        }
        Log.d(TAG, "parseNotificationAndSendBroadCast ext = " + ext);

        notifyNotificationEvent(ext);

        Intent intent = new Intent(TUIConstants.TUIOfflinePush.NOTIFICATION_BROADCAST_ACTION);
        intent.putExtra(TUIConstants.TUIOfflinePush.NOTIFICATION_EXT_KEY, ext);
        LocalBroadcastManager.getInstance(TUIOfflinePushService.appContext).sendBroadcast(intent);

        // callback intent
        // notifyNotificationEvent(mNotificationIntent);

        /*Intent intent = new Intent();
        intent.setAction(TUIConstants.TUIOfflinePush.NOTIFICATION_BROADCAST_ACTION);
        intent.putExtras(mNotificationIntent);
        LocalBroadcastManager.getInstance(TUIOfflinePushService.appContext).sendBroadcast(intent);
        TUIOfflinePushLog.d(TAG, "parseNotificationAndSendBroadCast sendBroadcast = " + mNotificationIntent);*/
    }

    void notifyNotificationEvent(String ext) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIOfflinePush.NOTIFICATION_EXT_KEY, ext);
        TUICore.notifyEvent(TUIConstants.TUIOfflinePush.EVENT_NOTIFY, TUIConstants.TUIOfflinePush.EVENT_NOTIFY_NOTIFICATION, param);
    }

    void notifyNotificationEvent(Intent intent) {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIOfflinePush.NOTIFICATION_INTENT_KEY, intent);
        TUICore.notifyEvent(TUIConstants.TUIOfflinePush.EVENT_NOTIFY, TUIConstants.TUIOfflinePush.EVENT_NOTIFY_NOTIFICATION, param);
    }

    void setPushTokenToTIM(String token) {
        setPushToken(token);

        if (TextUtils.isEmpty(pushToken)) {
            TUIOfflinePushLog.i(TAG, "setPushTokenToTIM third token is empty");
            return;
        }
        V2TIMOfflinePushConfig v2TIMOfflinePushConfig = null;

        if (mBussinessId == 0) {
            int brand = BrandUtil.getInstanceType();
            TUIOfflinePushLog.d(TAG, "setPushTokenToTIM brand is" + brand);
            if (isInternationalFlavor) {
                TUIOfflinePushLog.i(TAG, "flavor international");
                switch (brand) {
                    case TUIOfflinePushConfig.BRAND_XIAOMI:
                        mBussinessId = PrivateConstants.xiaomiPushBussinessIdAbroad;
                        break;
                    case TUIOfflinePushConfig.BRAND_HONOR:
                        mBussinessId = PrivateConstants.honorPushBussinessIdAbroad;
                        break;
                    case TUIOfflinePushConfig.BRAND_HUAWEI:
                        mBussinessId = PrivateConstants.huaweiPushBussinessIdAbroad;
                        break;
                    case TUIOfflinePushConfig.BRAND_MEIZU:
                        mBussinessId = PrivateConstants.meizuPushBussinessIdAbroad;
                        break;
                    case TUIOfflinePushConfig.BRAND_OPPO:
                        mBussinessId = PrivateConstants.oppoPushBussinessIdAbroad;
                        break;
                    case TUIOfflinePushConfig.BRAND_VIVO:
                        mBussinessId = PrivateConstants.vivoPushBussinessIdAbroad;
                        break;
                    default:
                        if (BrandUtil.isGoogleServiceSupport()) {
                            mBussinessId = PrivateConstants.fcmPushBussinessIdAbroad;
                        }
                        break;
                }
            } else {
                TUIOfflinePushLog.i(TAG, "flavor local");
                switch (brand) {
                    case TUIOfflinePushConfig.BRAND_XIAOMI:
                        mBussinessId = PrivateConstants.xiaomiPushBussinessId;
                        break;
                    case TUIOfflinePushConfig.BRAND_HONOR:
                        mBussinessId = PrivateConstants.honorPushBussinessId;
                        break;
                    case TUIOfflinePushConfig.BRAND_HUAWEI:
                        mBussinessId = PrivateConstants.huaweiPushBussinessId;
                        break;
                    case TUIOfflinePushConfig.BRAND_MEIZU:
                        mBussinessId = PrivateConstants.meizuPushBussinessId;
                        break;
                    case TUIOfflinePushConfig.BRAND_OPPO:
                        mBussinessId = PrivateConstants.oppoPushBussinessId;
                        break;
                    case TUIOfflinePushConfig.BRAND_VIVO:
                        mBussinessId = PrivateConstants.vivoPushBussinessId;
                        break;
                    default:
                        if (BrandUtil.isGoogleServiceSupport()) {
                            mBussinessId = PrivateConstants.fcmPushBussinessId;
                        }
                        break;
                }
            }
        }

        v2TIMOfflinePushConfig = new V2TIMOfflinePushConfig(mBussinessId, pushToken);
        TUIOfflinePushLog.d(TAG, "setOfflinePushConfig businessID = " + mBussinessId + " pushToken = " + pushToken);

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
        if (BrandUtil.getInstanceType() != TUIOfflinePushConfig.BRAND_HUAWEI) {
            return;
        }
        TUIOfflinePushLog.i(TAG, "huawei badge = " + number);
        try {
            Bundle extra = new Bundle();
            extra.putString("package", context.getPackageName());
            extra.putString("class", PrivateConstants.huaweiBadgeClassName);
            extra.putInt("badgenumber", number);
            context.getContentResolver().call(Uri.parse("content://com.huawei.android.launcher.settings/badge/"), "change_badge", null, extra);
        } catch (Exception e) {
            TUIOfflinePushLog.w(TAG, "huawei badge exception: " + e.getLocalizedMessage());
        }
    }
}
