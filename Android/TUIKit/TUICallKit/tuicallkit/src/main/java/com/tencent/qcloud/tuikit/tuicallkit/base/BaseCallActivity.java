package com.tencent.qcloud.tuikit.tuicallkit.base;

import android.app.NotificationManager;
import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.RelativeLayout;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils;
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView;

public class BaseCallActivity extends AppCompatActivity {
    private static AppCompatActivity mActivity;
    private static BaseCallView      mBaseCallView;
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
        DeviceUtils.setScreenLockParams(getWindow());
        mActivity = this;
        setContentView(R.layout.tuicalling_base_activity);
        initStatusBar();
    }

    private void initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
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
        mLayoutContainer = null;
        mActivity = null;
    }
}