package com.tencent.qcloud.tim.tuiofflinepush.TPNSPush;

import android.content.Context;
import android.text.TextUtils;

import com.heytap.msp.push.HeytapPushManager;
import com.tencent.android.tpush.XGIOperateCallback;
import com.tencent.android.tpush.XGPushConfig;
import com.tencent.android.tpush.XGPushManager;
import com.tencent.qcloud.tim.tuiofflinepush.PrivateConstants;
import com.tencent.qcloud.tim.tuiofflinepush.PushSettingInterface;
import com.tencent.qcloud.tim.tuiofflinepush.TUIOfflinePushManager;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class TPNSPushSetting implements PushSettingInterface {
    private static final String TAG = TPNSPushSetting.class.getSimpleName();
    private Context mContext;

    protected static TUIOfflinePushManager.PushCallback mPushCallback = null;

    @Override
    public void initPush(Context context) {
        mContext = context;
        // 关闭 TPNS SDK 拉活其他 app 的功能
        // ref: https://cloud.tencent.com/document/product/548/36674#.E5.A6.82.E4.BD.95.E5.85.B3.E9.97.AD-tpns-.E7.9A.84.E4.BF.9D.E6.B4.BB.E5.8A.9F.E8.83.BD.EF.BC.9F
        XGPushConfig.enablePullUpOtherApp(mContext, false);

        // TPNS SDK 注册
        prepareTPNSRegister();
    }

    @Override
    public void bindUserID(String userId) {
        // 重要：IM 登录用户账号时，调用 TPNS 账号绑定接口绑定业务账号，即可以此账号为目标进行 TPNS 离线推送
        XGPushManager.AccountInfo accountInfo = new XGPushManager.AccountInfo(
                XGPushManager.AccountType.UNKNOWN.getValue(), userId);
        XGPushManager.upsertAccounts(mContext, Arrays.asList(accountInfo), new XGIOperateCallback() {
            @Override
            public void onSuccess(Object o, int i) {
                TUIOfflinePushLog.w(TAG, "upsertAccounts success");
            }

            @Override
            public void onFail(Object o, int i, String s) {
                TUIOfflinePushLog.w(TAG, "upsertAccounts failed");
            }
        });
    }

    @Override
    public void unBindUserID(Context context, String userId) {
        TUIOfflinePushLog.d(TAG, "tpns 解绑");
        // TPNS 账号解绑业务账号
        XGIOperateCallback xgiOperateCallback = new XGIOperateCallback() {
            @Override
            public void onSuccess(Object data, int flag) {
                TUIOfflinePushLog.i(TAG, "onSuccess, data:" + data + ", flag:" + flag);
            }
            @Override
            public void onFail(Object data, int errCode, String msg) {
                TUIOfflinePushLog.w(TAG, "onFail, data:" + data + ", code:" + errCode + ", msg:" + msg);
            }
        };

        //XGPushManager.delAccount(context, UserInfo.getInstance().getUserId(), xgiOperateCallback);
        Set<Integer> accountTypeSet = new HashSet<>();
        accountTypeSet.add(XGPushManager.AccountType.CUSTOM.getValue());
        accountTypeSet.add(XGPushManager.AccountType.IMEI.getValue());
        XGPushManager.delAccounts(context, accountTypeSet, xgiOperateCallback);
    }

    @Override
    public void unInitPush(Context context) {
        TUIOfflinePushLog.d(TAG, "tpns 反注册");
        XGPushManager.unregisterPush(context, new XGIOperateCallback() {
            @Override
            public void onSuccess(Object data, int i) {
                TUIOfflinePushLog.d(TAG, "反注册成功");
                ToastUtil.toastLongMessage("TPNS反注册成功");
            }

            @Override
            public void onFail(Object data, int errCode, String msg) {
                TUIOfflinePushLog.d(TAG, "反注册失败，错误码：" + errCode + ",错误信息：" + msg);
            }
        });
    }

    /**
     * TPNS SDK 推送服务注册接口
     *
     * 小米、魅族、OPPO 的厂商通道配置通过接口设置，
     * 华为、vivo 的厂商通道配置需在 AndroidManifest.xml 文件内添加，
     * FCM 通过 FCM 配置文件。
     */
    private void prepareTPNSRegister() {
        TUIOfflinePushLog.i(TAG, "prepareTPNSRegister()");
        final Context context = mContext;

        XGPushConfig.enableDebug(context, true);

        XGPushConfig.setMiPushAppId(context, PrivateConstants.XM_PUSH_APPID);
        XGPushConfig.setMiPushAppKey(context, PrivateConstants.XM_PUSH_APPKEY);

        XGPushConfig.setMzPushAppId(context, PrivateConstants.MZ_PUSH_APPID);
        XGPushConfig.setMzPushAppKey(context, PrivateConstants.MZ_PUSH_APPKEY);

        XGPushConfig.setOppoPushAppId(context, PrivateConstants.OPPO_PUSH_APPKEY);
        XGPushConfig.setOppoPushAppKey(context, PrivateConstants.OPPO_PUSH_APPSECRET);

        // 重要：开启厂商通道注册
        XGPushConfig.enableOtherPush(context, true);

        XGPushConfig.setUseFcmFirst(context, false);

        // 注册 TPNS 推送服务
        XGPushManager.registerPush(context, new XGIOperateCallback() {
            @Override
            public void onSuccess(Object o, int i) {
                TUIOfflinePushLog.w(TAG, "tpush register success token: " + o);

                String token = (String) o;
                if (!TextUtils.isEmpty(token)) {
                    if (mPushCallback != null) {
                        mPushCallback.onTokenCallback(token);
                    } else {
                        TUIOfflinePushLog.e(TAG, "mPushCallback is null");
                    }
                }

                // 重要：获取通过 TPNS SDK 注册到的厂商推送 token，并调用 IM 接口设置和上传。
                if (XGPushConfig.isUsedOtherPush(context)) {
                    String otherPushToken = XGPushConfig.getOtherPushToken(context);
                    TUIOfflinePushLog.w(TAG, "otherPushToken token: " + otherPushToken);
                }

                // OPPO 手机默认关闭通知，需要申请
                HeytapPushManager.requestNotificationPermission();
            }

            @Override
            public void onFail(Object o, int i, String s) {
                TUIOfflinePushLog.w(TAG, "tpush register failed errCode: " + i + ", errMsg: " + s);
            }
        });
    }

    public void setPushCallback(TUIOfflinePushManager.PushCallback callback){
        mPushCallback = callback;
    }
}
