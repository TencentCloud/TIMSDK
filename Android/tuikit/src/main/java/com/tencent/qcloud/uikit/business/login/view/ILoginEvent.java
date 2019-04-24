package com.tencent.qcloud.uikit.business.login.view;

import android.view.View;


public interface ILoginEvent {

    void onLoginClick(View view, String userName, String password);

    void onRegisterClick(View view, String userName, String password);

}
