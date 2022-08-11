package com.tencent.qcloud.tuikit.tuicallkit.base;

import android.app.NotificationManager;
import android.content.Context;
import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;
import com.tencent.qcloud.tuikit.tuicallkit.ui.R;
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils;
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView;

public class BaseCallActivity extends AppCompatActivity {
    private static final String TAG = "BaseCallActivity";

    private static BaseCallView      mBaseCallView;
    private static AppCompatActivity mActivity;
    private static RelativeLayout    mLayoutContainer;

    public static void updateBaseView(BaseCallView view) {
        mBaseCallView = view;
        if (null != mLayoutContainer && null != mBaseCallView) {
            mLayoutContainer.removeAllViews();
            if (null != mBaseCallView.getParent()) {
                ((ViewGroup) mBaseCallView.getParent()).removeView(mBaseCallView);
            }
            mLayoutContainer.addView(mBaseCallView);
        }
    }

    public static void finishActivity() {
        if (null != mActivity) {
            mActivity.finish();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TUILog.i(TAG, "onCreate");
        DeviceUtils.setScreenLockParams(getWindow());
        mActivity = this;
        setContentView(R.layout.tuicalling_base_activity);
    }

    @Override
    protected void onResume() {
        super.onResume();
        TUILog.i(TAG, "onResume");
        initView();
        // clear notifications after a call is processed
        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancelAll();
    }

    private void initView() {
        mLayoutContainer = findViewById(R.id.rl_container);
        mLayoutContainer.removeAllViews();
        if (null != mBaseCallView) {
            if (null != mBaseCallView.getParent()) {
                ((ViewGroup) mBaseCallView.getParent()).removeView(mBaseCallView);
            }
            mLayoutContainer.addView(mBaseCallView);
        }
    }

    @Override
    public void onBackPressed() {

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (null != mBaseCallView && null != mBaseCallView.getParent()) {
            ((ViewGroup) mBaseCallView.getParent()).removeView(mBaseCallView);
        }
        mBaseCallView = null;
        TUILog.i(TAG, "onDestroy");
    }
}