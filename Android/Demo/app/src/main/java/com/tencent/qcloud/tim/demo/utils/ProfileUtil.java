package com.tencent.qcloud.tim.demo.utils;

import android.app.Activity;
import android.content.Intent;
import android.view.View;

import com.tencent.qcloud.tim.demo.bean.UserInfo;
import com.tencent.qcloud.tim.demo.login.LoginForDevActivity;

public class ProfileUtil {
    public static final boolean DEFAULT_IS_OPEN_MESSAGE_READ_RECEIPT = false;

    public static void onLogoutSuccess(Activity activity) {
        UserInfo.getInstance().cleanUserInfo();
        if (activity != null) {
            Intent intent = new Intent(activity, LoginForDevActivity.class);
            intent.putExtra(Constants.LOGOUT, true);
            activity.startActivity(intent);
            activity.finish();
        }
    }

    public static void setTestEntry(View view) {
        // do nothing
    }
}
