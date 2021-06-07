package com.tencent.qcloud.tim.demo.login;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.android.tpush.XGIOperateCallback;
import com.tencent.android.tpush.XGPushManager;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.main.MainActivity;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.Utils;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.Arrays;
/**
 * <p>
 * Demo的登录Activity
 * 用户名可以是任意非空字符，但是前提需要按照下面文档修改代码里的 SDKAPPID 与 PRIVATEKEY
 * https://github.com/tencentyun/TIMSDK/tree/master/Android
 * <p>
 */

public class LoginForDevActivity extends Activity {

    private static final String TAG = LoginForDevActivity.class.getSimpleName();
    private Button mLoginView;
    private EditText mUserAccount;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login_for_dev_activity);

        mLoginView = findViewById(R.id.login_btn);
        // 用户名可以是任意非空字符，但是前提需要按照下面文档修改代码里的 SDKAPPID 与 PRIVATEKEY
        // https://github.com/tencentyun/TIMSDK/tree/master/Android
        mUserAccount = findViewById(R.id.login_user);
        mUserAccount.setText(UserInfo.getInstance().getUserId());
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
        Utils.checkPermission(this);
        mLoginView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                UserInfo.getInstance().setUserId(mUserAccount.getText().toString());
                // 获取userSig函数
                String userSig = GenerateTestUserSig.genTestUserSig(mUserAccount.getText().toString());
                UserInfo.getInstance().setUserSig(userSig);
                TUIKit.login(mUserAccount.getText().toString(), userSig, new IUIKitCallBack() {
                    @Override
                    public void onError(String module, final int code, final String desc) {
                        runOnUiThread(new Runnable() {
                            public void run() {
                                ToastUtil.toastLongMessage(getString(R.string.failed_login_tip) + ", errCode = " + code + ", errInfo = " + desc);
                            }
                        });
                        DemoLog.i(TAG, "imLogin errorCode = " + code + ", errorInfo = " + desc);
                    }

                    @Override
                    public void onSuccess(Object data) {

                        // 重要：IM 登录用户账号时，调用 TPNS 账号绑定接口绑定业务账号，即可以此账号为目标进行 TPNS 离线推送
                        XGPushManager.AccountInfo accountInfo = new XGPushManager.AccountInfo(
                                XGPushManager.AccountType.UNKNOWN.getValue(), UserInfo.getInstance().getUserId());
                        XGPushManager.upsertAccounts(LoginForDevActivity.this, Arrays.asList(accountInfo),
                                new XGIOperateCallback() {
                            @Override
                            public void onSuccess(Object o, int i) {
                                Log.w(TAG, "upsertAccounts success");
                            }

                            @Override
                            public void onFail(Object o, int i, String s) {
                                Log.w(TAG, "upsertAccounts failed");
                            }
                        });

                        UserInfo.getInstance().setAutoLogin(true);
                        Intent intent = new Intent(LoginForDevActivity.this, MainActivity.class);
                        startActivity(intent);
                        finish();
                    }
                });
            }
        });
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            finish();
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 系统请求权限回调
     */
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        switch (requestCode) {
            case Utils.REQ_PERMISSION_CODE:
                if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                    ToastUtil.toastLongMessage(getString(R.string.permission_tip));
                }
                break;
            default:
                super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

}
