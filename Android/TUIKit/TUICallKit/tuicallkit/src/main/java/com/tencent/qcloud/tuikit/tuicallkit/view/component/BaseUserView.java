package com.tencent.qcloud.tuikit.tuicallkit.view.component;

import android.content.Context;
import android.widget.RelativeLayout;

import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;

public abstract class BaseUserView extends RelativeLayout {
    public BaseUserView(Context context) {
        super(context);
    }

    public void updateUserInfo(CallingUserModel userModel) {
    }

    public void updateTextColor(int color) {
    }
}
