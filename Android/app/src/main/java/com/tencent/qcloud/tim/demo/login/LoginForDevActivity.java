package com.tencent.qcloud.tim.demo.login;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.main.MainActivity;
import com.tencent.qcloud.tim.demo.signature.GenerateTestUserSig;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.Utils;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

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

//                String userId = "d15818615228";
//                String userSig = "eJxlkE1Pg0AURff8CsIWY*aDB9TEBRoiraKAY1A3hDKDGVsHMh0bofG-q9REEt-2nNx78w6WbdsOu7k-rZume1emMkMvHPvMdpBz8gf7XvKqNhXV-B8UH73UoqpbI-QEMQAQhOaO5EIZ2cpfg2MIcehjICScWTu*qaaqY4z3nUEAaDBX5MsE0-jhcplssl5cs5GxDCjbG1JkZTO6a1UoN3vaehfjnmmc48dVF8k46u4W8VqbPFvlaXClONyS9DUpw8gskqHAQfrsLZvtULptfj6rNPLt*BHsIxr4gOl8817onezUJBCEAROKfs6xPq0vYeRdHw__";

//                String userId = "d13812987870";
//                String userSig = "eJxlkEFPg0AYRO-8CsIVI7sLK4s3gpSgWIoYW0*EsFv40kDpsmjV*N9tqYkkzvW9zCTzpem6bjwn*XVZVfuxU4X66IWh3*oGMq7*YN8DL0pV2JL-g*LYgxRFuVVCThBTSglCcwe46BRs4dfg2GaYeMxl7twa*K6Ypi41zqmDUGq7cwXqCT6Gr0GcBe1D5NPjMq7uDvB57zyloROwPvfxOjejjZlHm126CqQqrSxu-FW6MOXoibqpK8U7C6-HxdBm5UsyHN5hmciWgs0aK-T82aSC9vIIvkEOIgwhNqNvQg6w7yaBIEwxsdE5hvat-QA6VV0q";

                UserInfo.getInstance().setUserId(mUserAccount.getText().toString());
                // 获取userSig函数
                final String userSig = GenerateTestUserSig.genTestUserSig(mUserAccount.getText().toString());

                TUIKit.login(mUserAccount.getText().toString(), userSig, new IUIKitCallBack() {
                    @Override
                    public void onError(String module, final int code, final String desc) {
                        runOnUiThread(new Runnable() {
                            public void run() {
                                ToastUtil.toastLongMessage("登录失败, errCode = " + code + ", errInfo = " + desc);
                            }
                        });
                        DemoLog.i(TAG, "imLogin errorCode = " + code + ", errorInfo = " + desc);
                    }

                    @Override
                    public void onSuccess(Object data) {
                        UserInfo.getInstance().setAutoLogin(true);
//                        UserInfo.getInstance().setUserSig(userSig);
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
        return true;
    }

    /**
     * 系统请求权限回调
     */
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        switch (requestCode) {
            case Utils.REQ_PERMISSION_CODE:
                if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                    ToastUtil.toastLongMessage("未全部授权，部分功能可能无法使用！");
                }
                break;
            default:
                super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

}
