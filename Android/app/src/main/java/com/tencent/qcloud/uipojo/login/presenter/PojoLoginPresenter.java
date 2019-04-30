package com.tencent.qcloud.uipojo.login.presenter;

import com.tencent.qcloud.uikit.common.utils.UIUtils;
import com.tencent.qcloud.uipojo.login.model.PojoLoginManager;
import com.tencent.qcloud.uipojo.login.view.ILoginView;

/**
 * Created by Administrator on 2018/7/2.
 */

public class PojoLoginPresenter {

    private ILoginView mView;
    private PojoLoginManager mManager = PojoLoginManager.getInstance();

    public PojoLoginPresenter(ILoginView view) {
        mView = view;
    }

    public void login(final String userName, final String userPassword) {
        mManager.login(userName, userPassword, new PojoLoginManager.LoginCallback() {
            @Override
            public void onSuccess(String res) {
                mView.onLoginSuccess(res);
            }

            @Override
            public void onFail(String module, int errCode, String errMsg) {
                mView.onLoginFail(module, errCode, errMsg);
                UIUtils.toastLongMessage("登录失败, errCode = " + errCode + ", errInfo = " + errMsg);
            }
        });
    }

    public void register(final String userName, final String userPassword) {
        mManager.register(userName, userPassword, new PojoLoginManager.LoginCallback() {
            @Override
            public void onSuccess(String data) {
                login(userName, userPassword);
            }

            @Override
            public void onFail(String module, int errCode, String errMsg) {
                UIUtils.toastLongMessage("注册失败, errCode = " + errCode + ", errInfo = " + errMsg);
            }
        });
    }

    public void imLoginForDev(final String userName, final String userSig, boolean autoLogin){
        mManager.imloginForDev(userName, userSig, autoLogin, new PojoLoginManager.LoginCallback() {
            @Override
            public void onSuccess(String usersig) {
                mView.onLoginSuccess(usersig);
            }

            @Override
            public void onFail(String module, int errCode, String errMsg) {
                mView.onLoginFail(module, errCode, errMsg);
            }
        });
    }

}
