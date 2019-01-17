package com.tencent.qcloud.uipojo.login.view;

import org.json.JSONObject;

/**
 * Created by Administrator on 2018/7/2.
 */

public interface ILoginView {
    void onLoginSuccess(Object res);

    void onLoginFail(String module, int errCode, String errMsg);

    void onRegisterSuccess(Object res);

    void onRegisterFail(String module, int errCode, String errMsg);
}


