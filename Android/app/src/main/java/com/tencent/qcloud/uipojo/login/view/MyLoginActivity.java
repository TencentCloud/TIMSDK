package com.tencent.qcloud.uipojo.login.view;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import com.tencent.qcloud.tim.tuikit.R;
import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uipojo.login.model.PojoLoginManager;
import com.tencent.qcloud.uipojo.main.MainActivity;

public class MyLoginActivity extends Activity implements View.OnClickListener {

    EditText mUser, mPassword;
    Button mLoginBtn;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        mUser = findViewById(R.id.login_user);
        mPassword = findViewById(R.id.login_password);
        mLoginBtn = findViewById(R.id.login_btn);
        mLoginBtn.setOnClickListener(this);
    }


    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.login_btn:
                login();
                break;
        }
    }

    /**
     * 点击登录按钮后，向自己的业务服务器进行登录操作
     */
    private void login() {
        final String userid = mUser.getText().toString();
        final String password = mPassword.getText().toString();
        /**
         * 此处为demo示例实现,
         *
         * 开发者需实现到自己业务服务器的登录逻辑，替换这段代码
         *
         * 登录完成后应返回usersig，在通过userid和usersig进行im登录
         */

        PojoLoginManager.getInstance().login(userid, password, new PojoLoginManager.LoginCallback() {
            @Override
            public void onSuccess(String usersig) {
                //登录成功后通过userid和usersig进行im登录
                imLogin(userid, usersig);
            }

            @Override
            public void onFail(String module, int errCode, String errMsg) {
                Log.e("login fail", errMsg);
            }
        });
    }


    /**
     * 用户在向自己的业务服务器登录完成后，在成功的回调中进行im的登录
     */
    private void imLogin(String account, String userSig) {
        /**
         * TUIKit已封装IM的登录接口，直接调用即可
         *
         * 如果用户想自行完成IM登录,调用TIMManager.getInstance().login
         */
        TUIKit.login(account, userSig, new IUIKitCallBack() {

            @Override
            public void onSuccess(Object data) {
                /**
                 * 此处为demo示例实现,
                 *
                 * IM登录成功后的回调操作，一般为跳转到应用的主页
                 *
                 */

                Intent intent = new Intent(MyLoginActivity.this, MainActivity.class);
                startActivity(intent);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                Log.e("imlogin fail", errMsg);
            }
        });
    }
}

