package com.tencent.qcloud.uikit.business.login.view;

import android.view.View;

/**
 * Created by valexhuang on 2018/7/2.
 */

public interface ILoginEvent {

    public void onLoginClick(View view, String userName, String password);

    public void onRegisterClick(View view, String userName, String password);

}
