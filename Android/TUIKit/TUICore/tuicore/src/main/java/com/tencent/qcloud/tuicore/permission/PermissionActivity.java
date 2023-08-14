package com.tencent.qcloud.tuicore.permission;

import static com.tencent.qcloud.tuicore.permission.PermissionRequester.PERMISSION_NOTIFY_EVENT_KEY;
import static com.tencent.qcloud.tuicore.permission.PermissionRequester.PERMISSION_NOTIFY_EVENT_SUB_KEY;
import static com.tencent.qcloud.tuicore.permission.PermissionRequester.PERMISSION_RESULT;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.TUIBuild;

import java.util.HashMap;
import java.util.Map;

@RequiresApi(api = Build.VERSION_CODES.M)
public class PermissionActivity extends Activity {
    private static final String TAG = "PermissionActivity";
    private static final int PERMISSION_REQUEST_CODE = 100;

    private TextView mRationaleTitleTv;
    private TextView mRationaleDescriptionTv;
    private ImageView mPermissionIconIv;
    private PermissionRequester.RequestData mRequestData;

    private PermissionRequester.Result mResult = PermissionRequester.Result.Denied;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mRequestData = getPermissionRequest();
        if (mRequestData == null || mRequestData.isPermissionsExistEmpty()) {
            Log.e(TAG, "onCreate mRequestData exist empty permission");
            finishWithResult(PermissionRequester.Result.Denied);
            return;
        }
        Log.i(TAG, "onCreate : " + mRequestData.toString());
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.M) {
            finishWithResult(PermissionRequester.Result.Granted);
            return;
        }

        makeBackGroundTransparent();
        initView();
        showPermissionRationale();

        requestPermissions(mRequestData.getPermissions(), PERMISSION_REQUEST_CODE);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        hidePermissionRationale();
        if (isAllPermissionsGranted(grantResults)) {
            finishWithResult(PermissionRequester.Result.Granted);
            return;
        }
        showSettingsTip();
    }

    private void showSettingsTip() {
        if (mRequestData == null) {
            return;
        }

        View tipLayout = LayoutInflater.from(this).inflate(R.layout.permission_tip_layout, null);
        TextView tipsTv = tipLayout.findViewById(R.id.tips);
        TextView positiveBtn = tipLayout.findViewById(R.id.positive_btn);
        TextView negativeBtn = tipLayout.findViewById(R.id.negative_btn);
        tipsTv.setText(mRequestData.getSettingsTip());

        Dialog permissionTipDialog = new AlertDialog.Builder(this).setView(tipLayout).setCancelable(false).create();

        positiveBtn.setOnClickListener(v -> {
            permissionTipDialog.dismiss();
            launchAppDetailsSettings();
            finishWithResult(PermissionRequester.Result.Requesting);
        });

        negativeBtn.setOnClickListener(v -> {
            permissionTipDialog.dismiss();
            finishWithResult(PermissionRequester.Result.Denied);
        });
        permissionTipDialog.setOnKeyListener((dialog, keyCode, event) -> {
            if (keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_UP) {
                permissionTipDialog.dismiss();
            }
            return true;
        });

        Window dialogWindow = permissionTipDialog.getWindow();
        dialogWindow.setBackgroundDrawable(new ColorDrawable());
        WindowManager.LayoutParams layoutParams = dialogWindow.getAttributes();
        layoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
        layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
        dialogWindow.setAttributes(layoutParams);
        permissionTipDialog.show();
    }

    /**
     * 启动应用程序的详细信息设置。
     *
     * Launch the application's details settings.
     */
    private void launchAppDetailsSettings() {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:" + getPackageName()));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        if (getPackageManager().queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY).size() <= 0) {
            Log.e(TAG, "launchAppDetailsSettings can not find system settings");
            return;
        }
        startActivity(intent);
    }

    private void finishWithResult(PermissionRequester.Result result) {
        Log.i(TAG, "finishWithResult : " + result);
        mResult = result;
        finish();
    }

    /*
     * 1、连续申请权限时，需要前一个权限申请完全结束；
     * 2、APP 从异常中恢复时，有些 Activity 在 onCreate 时就会申请权限；同时对于异常恢复，所有 Activity 可能被干掉，从新走流程；
     * 所以可能导致本次权限申请过早结束，此时须在 onDestroy 中返回结果。
     */
    @Override
    protected void onDestroy() {
        super.onDestroy();
        Map<String, Object> result = new HashMap<>(1);
        result.put(PERMISSION_RESULT, mResult);
        TUICore.notifyEvent(PERMISSION_NOTIFY_EVENT_KEY, PERMISSION_NOTIFY_EVENT_SUB_KEY, result);
    }

    private PermissionRequester.RequestData getPermissionRequest() {
        Intent intent = getIntent();
        if (intent == null) {
            return null;
        }
        return intent.getParcelableExtra(PermissionRequester.PERMISSION_REQUEST_KEY);
    }

    @SuppressLint("NewApi")
    private void makeBackGroundTransparent() {
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP) {
            View decorView = getWindow().getDecorView();
            decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            getWindow().setStatusBarColor(Color.TRANSPARENT);
            getWindow().setNavigationBarColor(Color.TRANSPARENT);
        }

        ActionBar actionBar = getActionBar();
        if (actionBar != null) {
            actionBar.hide();
        }
    }

    private void initView() {
        setContentView(R.layout.permission_activity_layout);
        mRationaleTitleTv = findViewById(R.id.permission_reason_title);
        mRationaleDescriptionTv = findViewById(R.id.permission_reason);
        mPermissionIconIv = findViewById(R.id.permission_icon);
    }

    /**
     * 安全合规要求，申请权限时，必须显示申请权限的理由。
     *
     * Security compliance requires that when applying for permission, the reason for applying for permission must be
     * displayed.
     */
    private void showPermissionRationale() {
        if (mRequestData == null) {
            return;
        }
        mRationaleTitleTv.setText(mRequestData.getTitle());
        mRationaleDescriptionTv.setText(mRequestData.getDescription());
        mPermissionIconIv.setBackgroundResource(mRequestData.getPermissionIconId());

        mRationaleTitleTv.setVisibility(View.VISIBLE);
        mRationaleDescriptionTv.setVisibility(View.VISIBLE);
        mPermissionIconIv.setVisibility(View.VISIBLE);
    }

    private void hidePermissionRationale() {
        mRationaleTitleTv.setVisibility(View.INVISIBLE);
        mRationaleDescriptionTv.setVisibility(View.INVISIBLE);
        mPermissionIconIv.setVisibility(View.INVISIBLE);
    }

    private boolean isAllPermissionsGranted(@NonNull int[] grantResults) {
        for (int result : grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return true;
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        return true;
    }
}