package com.tencent.qcloud.tuikit.tuicallkit.view.root;

import android.content.Context;
import android.view.View;
import android.widget.RelativeLayout;

import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingAction;

public abstract class BaseCallView extends RelativeLayout {
    protected Context          mContext;
    protected TUICallingAction mCallingAction;

    public BaseCallView(Context context) {
        super(context);
        mContext = context;
        mCallingAction = new TUICallingAction(context);
    }

    public void userEnter(CallingUserModel userModel) {
    }

    public void userAdd(CallingUserModel userModel) {
    }

    public void userLeave(CallingUserModel userModel) {
    }

    public void updateUserInfo(CallingUserModel userModel) {
    }

    public void updateCallingHint(String hint) {
    }

    public void updateCallTimeView(String time) {
    }

    public void updateUserView(View view) {
    }

    public void updateFunctionView(View view) {
    }

    public void updateSwitchAudioView(View view) {
    }

    public void addOtherUserView(View view) {
    }

    public void enableFloatView(View view) {
    }

    public void enableAddUserView(View view) {
    }

    public void updateBackgroundColor(int color) {
    }

    public void updateTextColor(int color) {
    }

    public void finish() {
        clearAllViews();
        removeAllViews();
        detachAllViewsFromParent();
        onDetachedFromWindow();
    }

    public void clearAllViews() {
        updateCallingHint("");
        updateCallTimeView(null);
        updateUserView(null);
        updateFunctionView(null);
        updateSwitchAudioView(null);
        addOtherUserView(null);
    }
}
