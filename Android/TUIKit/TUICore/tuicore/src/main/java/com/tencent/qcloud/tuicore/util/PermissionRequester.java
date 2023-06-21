package com.tencent.qcloud.tuicore.util;

import android.Manifest;
import android.app.ActionBar;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.text.TextUtils;
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
import androidx.annotation.StringDef;
import androidx.core.content.ContextCompat;
import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.TUIConfig;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public final class PermissionRequester {
    private static final List<String> PERMISSIONS = getPermissions();

    private static PermissionRequester instance;
    private static Context applicationContext;
    private SimpleCallback mSimpleCallback;
    private FullCallback mFullCallback;
    private PermissionDialogCallback mDialogCallback;
    private Set<String> mPermissions;
    private List<String> mPermissionsRequest;
    private String mCurrentRequestPermission;
    private List<String> mPermissionsGranted;
    private List<String> mPermissionsDenied;

    private static boolean isRequesting = false;

    private String mReason;
    private String mReasonTitle;
    private String mDeniedAlert;
    private int mIconId;

    private static final Map<String, PermissionRequestContent> permissionRequestContentMap = new HashMap<>();

    public static class PermissionRequestContent {
        int iconResId;
        String reasonTitle;
        String reason;
        String deniedAlert;

        public void setReasonTitle(String reasonTitle) {
            this.reasonTitle = reasonTitle;
        }

        public void setReason(String reason) {
            this.reason = reason;
        }

        public void setIconResId(int iconResId) {
            this.iconResId = iconResId;
        }

        public void setDeniedAlert(String deniedAlert) {
            this.deniedAlert = deniedAlert;
        }
    }

    public static void setPermissionRequestContent(String permission, PermissionRequestContent content) {
        permissionRequestContentMap.put(permission, content);
    }

    /**
     * Return the permissions used in application.
     *
     * @return the permissions used in application
     */
    public static List<String> getPermissions() {
        return getPermissions(getApplicationContext().getPackageName());
    }

    /**
     * Return the permissions used in application.
     *
     * @param packageName The name of the package.
     * @return the permissions used in application
     */
    public static List<String> getPermissions(final String packageName) {
        PackageManager pm = getApplicationContext().getPackageManager();
        try {
            String[] permissions = pm.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS).requestedPermissions;
            if (permissions == null) {
                return Collections.emptyList();
            }
            return Arrays.asList(permissions);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public static boolean isGranted(final String... permissions) {
        for (String permission : permissions) {
            if (!isGranted(permission)) {
                return false;
            }
        }
        return true;
    }

    private static boolean isGranted(final String permission) {
        return TUIBuild.getVersionInt() < Build.VERSION_CODES.M
            || PackageManager.PERMISSION_GRANTED == ContextCompat.checkSelfPermission(getApplicationContext(), permission);
    }

    /**
     * Launch the application's details settings.
     */
    public static void launchAppDetailsSettings() {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:" + getApplicationContext().getPackageName()));
        if (!isIntentAvailable(intent)) {
            return;
        }
        getApplicationContext().startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
    }

    /**
     * Set the permissions.
     *
     * @param permission The permissions.
     * @return the single {@link PermissionRequester} instance
     */
    public static PermissionRequester permission(@PermissionConstants.Permission final String permission) {
        return new PermissionRequester(permission);
    }

    private static boolean isIntentAvailable(final Intent intent) {
        return getApplicationContext().getPackageManager().queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY).size() > 0;
    }

    private PermissionRequester(final String permission) {
        mPermissions = new LinkedHashSet<>();
        mCurrentRequestPermission = permission;
        for (String aPermission : PermissionConstants.getPermissions(permission)) {
            if (PERMISSIONS.contains(aPermission)) {
                mPermissions.add(aPermission);
            }
        }
    }

    /**
     * Set the simple call back.
     *
     * @param callback the simple call back
     * @return the single {@link PermissionRequester} instance
     */
    public PermissionRequester callback(final SimpleCallback callback) {
        mSimpleCallback = callback;
        return this;
    }

    /**
     * Set the full call back.
     *
     * @param callback the full call back
     * @return the single {@link PermissionRequester} instance
     */
    public PermissionRequester callback(final FullCallback callback) {
        mFullCallback = callback;
        return this;
    }

    public PermissionRequester reason(String reason) {
        mReason = reason;
        return this;
    }

    public PermissionRequester reasonTitle(String reasonTitle) {
        mReasonTitle = reasonTitle;
        return this;
    }

    public PermissionRequester deniedAlert(String deniedAlert) {
        mDeniedAlert = deniedAlert;
        return this;
    }

    public PermissionRequester reasonIcon(int iconId) {
        mIconId = iconId;
        return this;
    }

    public PermissionRequester permissionDialogCallback(PermissionDialogCallback callback) {
        mDialogCallback = callback;
        return this;
    }

    public void request() {
        if (isRequesting) {
            return;
        }
        isRequesting = true;
        instance = this;
        mPermissionsGranted = new ArrayList<>();
        mPermissionsRequest = new ArrayList<>();
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.M) {
            mPermissionsGranted.addAll(mPermissions);
            isRequesting = false;
            requestCallback();
            mDialogCallback = null;
        } else {
            for (String permission : mPermissions) {
                if (isGranted(permission)) {
                    mPermissionsGranted.add(permission);
                } else {
                    mPermissionsRequest.add(permission);
                }
            }
            if (mPermissionsRequest.isEmpty()) {
                isRequesting = false;
                requestCallback();
                mDialogCallback = null;
            } else {
                startPermissionActivity();
            }
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    private void startPermissionActivity() {
        mPermissionsDenied = new ArrayList<>();
        Context context = getApplicationContext();
        if (context == null) {
            return;
        }
        Intent intent = new Intent(context, PermissionActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    private void getPermissionsStatus() {
        for (String permission : mPermissionsRequest) {
            if (isGranted(permission)) {
                mPermissionsGranted.add(permission);
            } else {
                mPermissionsDenied.add(permission);
            }
        }
    }

    private void requestCallback() {
        if (mSimpleCallback != null) {
            if (mPermissionsRequest.size() == 0 || mPermissions.size() == mPermissionsGranted.size()) {
                mSimpleCallback.onGranted();
            } else {
                if (!mPermissionsDenied.isEmpty()) {
                    mSimpleCallback.onDenied();
                }
            }
            mSimpleCallback = null;
        }
        if (mFullCallback != null) {
            if (mPermissionsRequest.size() == 0 || mPermissions.size() == mPermissionsGranted.size()) {
                mFullCallback.onGranted(mPermissionsGranted);
            } else {
                if (!mPermissionsDenied.isEmpty()) {
                    mFullCallback.onDenied(mPermissionsDenied);
                }
            }
            mFullCallback = null;
        }
    }

    private void onRequestPermissionsResult(final Activity activity) {
        getPermissionsStatus();
        if (!mPermissionsDenied.isEmpty()) {
            showPermissionDialog(activity, new PermissionDialogCallback() {
                @Override
                public void onApproved() {
                    if (mDialogCallback != null) {
                        mDialogCallback.onApproved();
                    }
                    mDialogCallback = null;
                    launchAppDetailsSettings();
                }

                @Override
                public void onRefused() {
                    if (mDialogCallback != null) {
                        mDialogCallback.onRefused();
                    }
                    mDialogCallback = null;
                }
            });
        } else {
            isRequesting = false;
            mDialogCallback = null;
            activity.finish();
        }

        requestCallback();
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    public static class PermissionActivity extends Activity {
        private View mContentView;

        @Override
        protected void onCreate(@Nullable Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
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

            requestPermission();
        }

        private void requestPermission() {
            if (instance.mPermissionsRequest != null) {
                int size = instance.mPermissionsRequest.size();
                if (size <= 0) {
                    instance.onRequestPermissionsResult(this);
                } else {
                    fillContentView();
                    requestPermissions(instance.mPermissionsRequest.toArray(new String[size]), 1);
                }
            }
        }

        private void fillContentView() {
            PermissionRequestContent info = permissionRequestContentMap.get(instance.mCurrentRequestPermission);
            int iconResId = instance.mIconId;
            String reasonTitle = instance.mReasonTitle;
            String reason = instance.mReason;
            if (info != null) {
                if (info.iconResId != 0) {
                    iconResId = info.iconResId;
                }
                if (!TextUtils.isEmpty(info.reasonTitle)) {
                    reasonTitle = info.reasonTitle;
                }
                if (!TextUtils.isEmpty(info.reason)) {
                    reason = info.reason;
                }
            }
            if (TextUtils.isEmpty(reason)) {
                return;
            }
            setContentView(R.layout.permission_activity_layout);
            mContentView = findViewById(R.id.tuicore_permission_layout);
            TextView permissionReasonTitle = findViewById(R.id.permission_reason_title);
            TextView permissionReason = findViewById(R.id.permission_reason);
            ImageView permissionIcon = findViewById(R.id.permission_icon);
            permissionReasonTitle.setText(reasonTitle);
            permissionReason.setText(reason);
            if (iconResId != 0) {
                permissionIcon.setBackgroundResource(iconResId);
            }
        }

        private void hideContentView() {
            if (mContentView != null) {
                mContentView.setVisibility(View.INVISIBLE);
            }
        }

        @Override
        public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
            if (instance.mPermissionsRequest != null) {
                hideContentView();
                instance.onRequestPermissionsResult(this);
            }
        }

        @Override
        public boolean dispatchTouchEvent(MotionEvent ev) {
            return super.dispatchTouchEvent(ev);
        }

        @Override
        public boolean onTouchEvent(MotionEvent event) {
            return true;
        }

        @Override
        protected void onDestroy() {
            super.onDestroy();
            isRequesting = false;
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // interface
    ///////////////////////////////////////////////////////////////////////////

    public interface SimpleCallback {
        void onGranted();

        void onDenied();
    }

    public interface FullCallback {
        void onGranted(List<String> permissionsGranted);

        void onDenied(List<String> permissionsDenied);
    }

    public static final class PermissionConstants {
        public static final String CALENDAR = Manifest.permission_group.CALENDAR;
        public static final String CAMERA = Manifest.permission_group.CAMERA;
        public static final String CONTACTS = Manifest.permission_group.CONTACTS;
        public static final String LOCATION = Manifest.permission_group.LOCATION;
        public static final String MICROPHONE = Manifest.permission_group.MICROPHONE;
        public static final String PHONE = Manifest.permission_group.PHONE;
        public static final String SENSORS = Manifest.permission_group.SENSORS;
        public static final String SMS = Manifest.permission_group.SMS;
        public static final String STORAGE = Manifest.permission_group.STORAGE;

        private static final String[] GROUP_CALENDAR = {Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR};
        private static final String[] GROUP_CAMERA = {Manifest.permission.CAMERA};
        private static final String[] GROUP_CONTACTS = {
            Manifest.permission.READ_CONTACTS, Manifest.permission.WRITE_CONTACTS, Manifest.permission.GET_ACCOUNTS};
        private static final String[] GROUP_LOCATION = {Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION};
        private static final String[] GROUP_MICROPHONE = {Manifest.permission.RECORD_AUDIO};
        private static final String[] GROUP_PHONE = {Manifest.permission.READ_PHONE_STATE, Manifest.permission.READ_PHONE_NUMBERS,
            Manifest.permission.CALL_PHONE, Manifest.permission.READ_CALL_LOG, Manifest.permission.WRITE_CALL_LOG, Manifest.permission.ADD_VOICEMAIL,
            Manifest.permission.USE_SIP, Manifest.permission.PROCESS_OUTGOING_CALLS, Manifest.permission.ANSWER_PHONE_CALLS};
        private static final String[] GROUP_PHONE_BELOW_O = {Manifest.permission.READ_PHONE_STATE, Manifest.permission.READ_PHONE_NUMBERS,
            Manifest.permission.CALL_PHONE, Manifest.permission.READ_CALL_LOG, Manifest.permission.WRITE_CALL_LOG, Manifest.permission.ADD_VOICEMAIL,
            Manifest.permission.USE_SIP, Manifest.permission.PROCESS_OUTGOING_CALLS};
        private static final String[] GROUP_SENSORS = {Manifest.permission.BODY_SENSORS};
        private static final String[] GROUP_SMS = {
            Manifest.permission.SEND_SMS,
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.READ_SMS,
            Manifest.permission.RECEIVE_WAP_PUSH,
            Manifest.permission.RECEIVE_MMS,
        };
        private static final String[] GROUP_STORAGE = {
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
        };

        @StringDef({
            CALENDAR,
            CAMERA,
            CONTACTS,
            LOCATION,
            MICROPHONE,
            PHONE,
            SENSORS,
            SMS,
            STORAGE,
        })
        @Retention(RetentionPolicy.SOURCE)
        public @interface Permission {}

        public static String[] getPermissions(@Permission final String permission) {
            switch (permission) {
                case CALENDAR:
                    return GROUP_CALENDAR;
                case CAMERA:
                    return GROUP_CAMERA;
                case CONTACTS:
                    return GROUP_CONTACTS;
                case LOCATION:
                    return GROUP_LOCATION;
                case MICROPHONE:
                    return GROUP_MICROPHONE;
                case PHONE:
                    if (TUIBuild.getVersionInt() < Build.VERSION_CODES.O) {
                        return GROUP_PHONE_BELOW_O;
                    } else {
                        return GROUP_PHONE;
                    }
                case SENSORS:
                    return GROUP_SENSORS;
                case SMS:
                    return GROUP_SMS;
                case STORAGE:
                    return GROUP_STORAGE;
                default:
                    break;
            }
            return new String[] {permission};
        }
    }

    private static Context getApplicationContext() {
        if (applicationContext == null) {
            applicationContext = TUIConfig.getAppContext();
        }
        return applicationContext;
    }

    public void showPermissionDialog(Activity activity, PermissionDialogCallback callback) {
        PermissionRequestContent info = permissionRequestContentMap.get(instance.mCurrentRequestPermission);
        String deniedAlert = mDeniedAlert;
        if (info != null) {
            if (!TextUtils.isEmpty(info.deniedAlert)) {
                deniedAlert = info.deniedAlert;
            }
        }

        if (TextUtils.isEmpty(deniedAlert)) {
            deniedAlert = mReason;
        }

        if (TextUtils.isEmpty(deniedAlert)) {
            isRequesting = false;
            activity.finish();
            callback.onRefused();
            return;
        }

        activity.setContentView(R.layout.permission_activity_layout);

        View itemPop = LayoutInflater.from(activity).inflate(R.layout.permission_tip_layout, null);
        TextView tipsTv = itemPop.findViewById(R.id.tips);
        TextView positiveBtn = itemPop.findViewById(R.id.positive_btn);
        TextView negativeBtn = itemPop.findViewById(R.id.negative_btn);
        tipsTv.setText(deniedAlert);

        Dialog permissionTipDialog = new AlertDialog.Builder(activity)
                                         .setView(itemPop)
                                         .setCancelable(false)
                                         .setOnDismissListener(new DialogInterface.OnDismissListener() {
                                             @Override
                                             public void onDismiss(DialogInterface dialog) {
                                                 isRequesting = false;
                                             }
                                         })
                                         .create();

        positiveBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isRequesting = false;
                permissionTipDialog.cancel();
                activity.finish();
                callback.onApproved();
            }
        });

        negativeBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isRequesting = false;
                permissionTipDialog.cancel();
                activity.finish();
                callback.onRefused();
            }
        });
        permissionTipDialog.setOnKeyListener(new DialogInterface.OnKeyListener() {
            @Override
            public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
                if (keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN) {
                    isRequesting = false;
                    permissionTipDialog.cancel();
                    activity.finish();
                    callback.onRefused();
                }
                return false;
            }
        });

        permissionTipDialog.show();
        Window dialogWindow = permissionTipDialog.getWindow();
        dialogWindow.setBackgroundDrawable(new ColorDrawable());
        WindowManager.LayoutParams layoutParams = dialogWindow.getAttributes();
        layoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
        layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
        dialogWindow.setAttributes(layoutParams);
    }

    public interface PermissionDialogCallback {
        void onApproved();

        void onRefused();
    }
}