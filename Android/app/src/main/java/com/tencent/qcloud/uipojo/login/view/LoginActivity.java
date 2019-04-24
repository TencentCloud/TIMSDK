package com.tencent.qcloud.uipojo.login.view;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;

import com.huawei.android.hms.agent.HMSAgent;
import com.huawei.android.hms.agent.common.handler.ConnectHandler;
import com.huawei.android.hms.agent.push.handler.GetTokenHandler;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.log.QLog;
import com.tencent.imsdk.utils.IMFunc;
import com.tencent.qcloud.tim.tuikit.R;
import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.business.login.view.ILoginEvent;
import com.tencent.qcloud.uikit.business.login.view.LoginView;
import com.tencent.qcloud.uikit.common.utils.UIUtils;
import com.tencent.qcloud.uipojo.login.presenter.PojoLoginPresenter;
import com.tencent.qcloud.uipojo.main.MainActivity;
import com.tencent.qcloud.uipojo.thirdpush.ThirdPushTokenMgr;
import com.tencent.qcloud.uipojo.utils.Constants;
import com.vivo.push.IPushActionListener;
import com.vivo.push.PushClient;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by valexhuang on 2018/6/21.
 * <p>
 * Demo的登录Activity，实现了注册逻辑，账号信信息缓存，被踢登录等等，相对复杂
 * <p>
 * 如果用户只是想简单的了解IM系统的登录机制，参考 {@link com.tencent.qcloud.uipojo.login.view.MyLoginActivity}即可
 */

public class LoginActivity extends Activity implements ILoginEvent, ILoginView, AdapterView.OnItemSelectedListener {

    LoginView mLoginPanel;

    Spinner mSpinner;
    private ArrayAdapter adapter;
    private Button mBtnLoginIm;

    /**
     * 1、这里的一组 userid 和 usersig 可以直接使用，便于您快速开始测试和调试
     *
     * 2、如要使用自己的账号测试，需要把 Constants 中的 SDKAPPID 替换为您在控制台申请的，userid 和 userSig 替换为您在控制台用开发辅助工具生成的账号
     *
     * 3、但真正要线上使用，肯定不适合采用这种做法，而是推荐服务端方案：https://cloud.tencent.com/document/product/269/1507
     *
     */
    String userId_1 = "IM01";
    String userSig_1 = "eJxlz11vgjAUgOF7fkXT2y2zLVTq7gaZWSMwvzBzNwRt1bpAAavolv33RWayJju3z3tycr4cAACcR7OHfL3Wx9Jk5lJJCB4BRPD*D6tKiSw3mduIfyjPlWpklm*MbDrElFKCkN0oIUujNupW8BhhSw-iI*tO-K57CGGf*cy1E7XtMH5ehnwS1kO3-15N9W68CoanVpip*XwTvd4Cs6Q4LuhYp5F*eZXc2-LdU5QSlQeDCSH9M0uW7SjY12qVjEg7u*OeT9IgKfy0ji-h3jppVCFv-3g*pYwMmKUn2RyULruAIEwxcdF1oPPt-ADjGlt7";

    String userId_2 = "IM02";
    String userSig_2 = "eJxlz11PgzAUgOF7fgXhVuNOKV0b75Cpq1I-YCq7IoQWqROGpS5M43834hJJPLfPe3JyPh3Xdb1VnJ4UZbl9b21u953y3FPXA*-4D7tOy7ywOTbyH6qh00blRWWVGRERQnyAaaOlaq2u9KHgAvyJ9nKTjyd*1wMARBlleJro5xHF*Tri99HyrQxuFmGMa7YWsprfwRyXQvCBnqFhswPTHy1n1cUlW4W8Dm*jBhZJKOMspc2HHyfXV090L15R9pDU8eyRvjCRImKyik9OWt2owz8BJYRhhCa6U6bX23YMfEAE*Rh*xnO*nG8M8lnb";

    String userId_3 = "IM03";
    String userSig_3 = "eJxlz1FPgzAQwPF3PkXD64xpKRW2xIeKiIyNuAyi8kII3KDRFWRl1Ri-uxGXDOO9-v6Xy30aCCEzWW0vi7JsB6ly9dGBiRbIxObFGbtOVHmhctpX-xDeO9FDXuwU9CMSxpiF8bQRFUglduJUhGtMJ3qoXvLxxO*6jTFxXMf9k4h6xLWfeuHGi684D-hzzbO7B34TtzUGP4iGqAepl82jSLLInleDdkGHdfp61Kk9czdvt4kHQXOfsnksaz2jWdno1ZPyo2XL9-bW09eTk0rs4fSP7TDmUkomeoT*IFo5BhYmjFgU-4xpfBnf8qhb6w__";

    String userId_4 = "IM04";
    String userSig_4 = "eJxlj1FPgzAUhd-5FU1fZ7SlLaDJHsAsWGMjc2QiL6TSllUdI6ybc8b-bsQlknhfv*-knPvpAQBgfrc4l3W92bWuch*dhuAKQATP-mDXWVVJV5Fe-YP60NleV9I43Q8QM8Z8hMaOVbp11tiTwQWiI7pVr9VQ8RunCOEwCiMyVmwzQDGbX-PkoV4KWq5snPLg4ulFtUGeoPVsoWIcTO7dY2lw38isvJSxjf2syG*M2Be388aIVapzl-GC7sRhOSmfCSsLyY-JW3rs3qfTUaWza336h4aMRYSON*91v7WbdhB8hBn2Cfo56H1537YXW4k_";

    String mIMLoginUserId;
    String mIMLoginUserSig;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //在代码里动态添加LoginView
        //setContentView(new LoginView(this));
        setContentView(R.layout.activity_login);
        mLoginPanel = findViewById(R.id.login_view);
        mLoginPanel.setLoginEvent(this);

        testUserName();

        mFlashView = findViewById(R.id.flash_view);
        mAutoLogin = getIntent().getBooleanExtra(Constants.AUTO_LOGIN, false);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
        mPresenter = new PojoLoginPresenter(this);
        MainActivity.init = false;
        checkPermission(this);
//        initCache();


        if (mAutoLogin) {
            if (TIMManager.getInstance().isInited()) {
                mFlashView.setVisibility(View.VISIBLE);
                mFlashView.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        mFlashView.setVisibility(View.GONE);
                    }
                }, 1000);
            }
        } else {
            mFlashView.setVisibility(View.GONE);
        }

        if(IMFunc.isBrandHuawei()){
            // 华为离线推送
            HMSAgent.connect(this, new ConnectHandler() {
                @Override
                public void onConnect(int rst) {
                    QLog.i("huaweipush", "HMS connect end:" + rst);
                }
            });
            getHuaWeiPushToken();
        }
        if(IMFunc.isBrandVivo()){
            // vivo离线推送
            PushClient.getInstance(getApplicationContext()).turnOnPush(new IPushActionListener() {
                @Override
                public void onStateChanged(int state) {
                    if(state == 0){
                        String regId = PushClient.getInstance(getApplicationContext()).getRegId();
                        QLog.i("vivopush", "open vivo push success regId = " + regId);
                        ThirdPushTokenMgr.getInstance().setThirdPushToken(regId);
                        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
                    }else {
                        // 根据vivo推送文档说明，state = 101 表示该vivo机型或者版本不支持vivo推送，链接：https://dev.vivo.com.cn/documentCenter/doc/156
                        QLog.i("vivopush", "open vivo push fail state = " + state);
                    }
                }
            });
        }
    }

    private void getHuaWeiPushToken() {
        HMSAgent.Push.getToken(new GetTokenHandler() {
            @Override
            public void onResult(int rtnCode) {
                QLog.i("huaweipush", "get token: end" + rtnCode);
            }
        });
    }

    private void testUserName() {
        mSpinner = findViewById(R.id.user_id_spinner);
        adapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_dropdown_item, getDataSource());
        mSpinner.setAdapter(adapter);
        mSpinner.setOnItemSelectedListener(this);

        mBtnLoginIm = (Button)findViewById(R.id.loginim_btn);
        mBtnLoginIm.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mPresenter.imLoginForDev(mIMLoginUserId, mIMLoginUserSig, true);
            }
        });
    }

    private List<String> getDataSource(){
        List<String> list = new ArrayList<String>() ;
        list.add(userId_1);
        list.add(userId_2);
        list.add(userId_3);
        list.add(userId_4);
        return list  ;
    }

    @Override
    public void onItemSelected(AdapterView<?> adapterView, View view, int position, long id) {
        String item = (String) mSpinner.getItemAtPosition(position);
        Log.e("vinson", "position = " + position + ", item " + item);
        mIMLoginUserId = item;
        if(position == 0){
            mIMLoginUserSig = userSig_1;
        }else if(position == 1){
            mIMLoginUserSig = userSig_2;
        }else if(position == 2){
            mIMLoginUserSig = userSig_3;
        }else if(position == 3){
            mIMLoginUserSig = userSig_4;
        }
    }

    @Override
    public void onNothingSelected(AdapterView<?> adapterView) {

    }

    private static final int REQ_PERMISSION_CODE = 0x100;
    PojoLoginPresenter mPresenter;
    private boolean mAutoLogin;
    View mFlashView;

    @Override
    protected void onNewIntent(Intent intent) {
        MainActivity.init = false;
        super.onNewIntent(intent);
    }

    //从本地缓存里获取用户信息
    private void initCache() {
        SharedPreferences shareInfo = getApplication().getSharedPreferences(Constants.USERINFO, 0);
        String account = shareInfo.getString(Constants.ACCOUNT, "");
        String password = shareInfo.getString(Constants.PWD, "");
        ((LoginView) mLoginPanel).getAccountEditor().setText(account);
        ((LoginView) mLoginPanel).getAccountEditor().requestFocus();
        ((LoginView) mLoginPanel).getPasswordEditor().setText(password);
        if (TextUtils.isEmpty(account)) {
            mLoginPanel.setModel(false);
        } else {
            if (mAutoLogin) {
                mPresenter.login(account, password);
            }
        }
    }

    @Override
    public void onLoginClick(View view, String userName, String password) {
        //往业务服务器发起登录请求
        mPresenter.login(userName, password);

        // 这里省去了去业务服务器发起登录请求的流程，直接登陆IM
//        mPresenter.imLoginForDev(userName, userSig, true);

    }

    @Override
    public void onRegisterClick(View view, String userName, String password) {
        //往业务服务器发起注册请求
        mPresenter.register(userName, password);
    }


    @Override
    public void onLoginSuccess(Object res) {
        //登录成功的回调，这里的登录成功已经IM的登录成功回调了
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(((LoginView) mLoginPanel).getPasswordEditor().getWindowToken(), 0);
        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
        finish();
    }

    @Override
    public void onLoginFail(String module, int errCode, String errMsg) {
        UIUtils.toastLongMessage("登录失败：" + errMsg);
    }

    @Override
    public void onRegisterSuccess(Object res) {
        UIUtils.toastLongMessage("注册成功");
        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
        finish();
    }

    @Override
    public void onRegisterFail(String module, int errCode, String errMsg) {
        UIUtils.toastLongMessage("注册失败：" + errMsg);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            MainActivity.exitApp();
            finish();
        }
        return true;
    }


    //权限检查
    public static boolean checkPermission(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            List<String> permissions = new ArrayList<>();
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TUIKit.getAppContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TUIKit.getAppContext(), Manifest.permission.CAMERA)) {
                permissions.add(Manifest.permission.CAMERA);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TUIKit.getAppContext(), Manifest.permission.RECORD_AUDIO)) {
                permissions.add(Manifest.permission.RECORD_AUDIO);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TUIKit.getAppContext(), Manifest.permission.READ_PHONE_STATE)) {
                permissions.add(Manifest.permission.READ_PHONE_STATE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TUIKit.getAppContext(), Manifest.permission.READ_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE);
            }
            if (permissions.size() != 0) {
                String[] permissionsArray = permissions.toArray(new String[1]);
                ActivityCompat.requestPermissions(activity,
                        permissionsArray,
                        REQ_PERMISSION_CODE);
                return false;
            }
        }

        return true;
    }

    /**
     * 系统请求权限回调
     *
     * @param requestCode
     * @param permissions
     * @param grantResults
     */
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        switch (requestCode) {
            case REQ_PERMISSION_CODE:
                if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                    UIUtils.toastLongMessage("未全部授权，部分功能可能无法使用！");
                }
                break;
            default:
                super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

}
