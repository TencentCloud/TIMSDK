package com.tencent.qcloud.tim.demo;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import com.tencent.android.tpush.XGIOperateCallback;
import com.tencent.android.tpush.XGPushConfig;
import com.tencent.android.tpush.XGPushManager;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tim.demo.login.LoginForDevActivity;
import com.tencent.qcloud.tim.demo.login.UserInfo;
import com.tencent.qcloud.tim.demo.main.MainActivity;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.thirdpush.OfflineMessageDispatcher;
import com.tencent.qcloud.tim.demo.thirdpush.ThirdPushTokenMgr;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.PrivateConstants;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.modules.chat.base.OfflineMessageBean;
import com.tencent.qcloud.tim.uikit.modules.chat.base.OfflineMessageContainerBean;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.Arrays;

public class SplashActivity extends Activity {

    private static final String TAG = SplashActivity.class.getSimpleName();
    private static final int SPLASH_TIME = 1500;
    private View mFlashView;
    private UserInfo mUserInfo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);

        mFlashView = findViewById(R.id.flash_view);
        mUserInfo = UserInfo.getInstance();

        // TPNS SDK 注册
        prepareTPNSRegister();
        handleData();
    }

    private void handleData() {
        if (mUserInfo != null && mUserInfo.isAutoLogin()) {
            login();
        } else {
            mFlashView.postDelayed(new Runnable() {
                @Override
                public void run() {
                    startLogin();
                }
            }, SPLASH_TIME);
        }
    }

    private void login() {
        TUIKit.login(mUserInfo.getUserId(), mUserInfo.getUserSig(), new IUIKitCallBack() {
            @Override
            public void onError(String module, final int code, final String desc) {
                runOnUiThread(new Runnable() {
                    public void run() {
                        ToastUtil.toastLongMessage(getString(R.string.failed_login_tip) + ", errCode = " + code + ", errInfo = " + desc);
                        startLogin();
                    }
                });
                DemoLog.i(TAG, "imLogin errorCode = " + code + ", errorInfo = " + desc);
            }

            @Override
            public void onSuccess(Object data) {
                // 重要：IM 登录用户账号时，调用 TPNS 账号绑定接口绑定业务账号，即可以此账号为目标进行 TPNS 离线推送
                XGPushManager.AccountInfo accountInfo = new XGPushManager.AccountInfo(
                        XGPushManager.AccountType.UNKNOWN.getValue(), mUserInfo.getUserId());
                XGPushManager.upsertAccounts(SplashActivity.this, Arrays.asList(accountInfo), new XGIOperateCallback() {
                    @Override
                    public void onSuccess(Object o, int i) {
                        Log.w(TAG, "upsertAccounts success");
                    }

                    @Override
                    public void onFail(Object o, int i, String s) {
                        Log.w(TAG, "upsertAccounts failed");
                    }
                });
                startMain();
            }
        });
    }

    private void startLogin() {
Intent intent = new Intent(SplashActivity.this, LoginForDevActivity.class);
        startActivity(intent);
        finish();
    }

    private void startMain() {
        DemoLog.i(TAG, "startMain" );

        OfflineMessageBean bean = OfflineMessageDispatcher.parseOfflineMessage(getIntent());
        if (bean != null) {
            DemoLog.i(TAG, "startMain offlinePush bean is " + bean);
            OfflineMessageDispatcher.redirect(bean);
            finish();
            return;
        }
        DemoLog.i(TAG, "startMain offlinePush bean is null" );

        Intent intent = new Intent(SplashActivity.this, MainActivity.class);
        startActivity(intent);
        finish();
    }

    /**
     * TPNS SDK 推送服务注册接口
     *
     * 小米、魅族、OPPO 的厂商通道配置通过接口设置，
     * 华为、vivo 的厂商通道配置需在 AndroidManifest.xml 文件内添加，
     * FCM 通过 FCM 配置文件。
     */
    private void prepareTPNSRegister() {
        final Context context = SplashActivity.this;

        XGPushConfig.enableDebug(context, true);

        XGPushConfig.setMiPushAppId(context, PrivateConstants.XM_PUSH_APPID);
        XGPushConfig.setMiPushAppKey(context, PrivateConstants.XM_PUSH_APPKEY);

        XGPushConfig.setMzPushAppId(context, PrivateConstants.MZ_PUSH_APPID);
        XGPushConfig.setMzPushAppKey(context, PrivateConstants.MZ_PUSH_APPKEY);

        XGPushConfig.setOppoPushAppId(context, PrivateConstants.OPPO_PUSH_APPKEY);
        XGPushConfig.setOppoPushAppKey(context, PrivateConstants.OPPO_PUSH_APPSECRET);

        // 重要：开启厂商通道注册
        XGPushConfig.enableOtherPush(context, true);

        // 是否启用 FCM 推送；
        // 在 enableOtherPush(context, true) 时将默认置为 true，此时若设备同时支持谷歌服务和厂商自己的推送服务，将会优先进行 FCM 注册；
//        XGPushConfig.enableFcmPush(context, false);

        // 注册 TPNS 推送服务
        XGPushManager.registerPush(context, new XGIOperateCallback() {
            @Override
            public void onSuccess(Object o, int i) {
                Log.w(TAG, "tpush register success token: " + o);

                // 重要：获取通过 TPNS SDK 注册到的厂商推送 token，并调用 IM 接口设置和上传。
                if (XGPushConfig.isUsedOtherPush(context)) {
                    String otherPushToken = XGPushConfig.getOtherPushToken(SplashActivity.this);
                    if (!TextUtils.isEmpty(otherPushToken)) {
                        ThirdPushTokenMgr.getInstance().setThirdPushToken(otherPushToken);
                        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
                    }
                }
            }

            @Override
            public void onFail(Object o, int i, String s) {
                Log.w(TAG, "tpush register failed errCode: " + i + ", errMsg: " + s);
            }
        });
    }
}
