package com.tencent.qcloud.tuikit.tuicallkit.utils;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.net.Uri;
import android.provider.Settings;
import android.text.TextUtils;

import androidx.annotation.IntDef;

import com.tencent.qcloud.tuicore.util.PermissionRequester;
import com.tencent.qcloud.tuikit.tuicallengine.utils.BrandUtils;
import com.tencent.qcloud.tuikit.tuicallengine.utils.PermissionUtils;
import com.tencent.qcloud.tuikit.tuicallkit.R;

public class PermissionRequest {
    public static final int PERMISSION_MICROPHONE = 1;
    public static final int PERMISSION_CAMERA     = 2;

    @IntDef({PERMISSION_MICROPHONE, PERMISSION_CAMERA})
    public @interface PermissionType {
    }

    public static void requestPermission(Context context, @PermissionType int type1, @PermissionType int type2,
                                         PermissionCallback callback) {
        requestPermission(context, type2, new PermissionCallback() {
            @Override
            public void onGranted() {
                requestPermission(context, type1, new PermissionCallback() {
                    @Override
                    public void onGranted() {
                        if (null != callback) {
                            callback.onGranted();
                        }
                    }

                    @Override
                    public void onDenied() {
                        if (null != callback) {
                            callback.onDenied();
                        }
                    }

                    @Override
                    public void onDialogApproved() {
                        if (null != callback) {
                            callback.onDialogApproved();
                        }
                    }

                    @Override
                    public void onDialogRefused() {
                        if (null != callback) {
                            callback.onDialogRefused();
                        }
                    }
                });

            }

            @Override
            public void onDenied() {
                if (null != callback) {
                    callback.onDenied();
                }
            }

            @Override
            public void onDialogApproved() {
                if (null != callback) {
                    callback.onDialogApproved();
                }
            }

            @Override
            public void onDialogRefused() {
                if (null != callback) {
                    callback.onDialogRefused();
                }
            }
        });
    }

    public static void requestPermission(Context context, @PermissionType int type, PermissionCallback callback) {
        String permission = null;
        String reason = null;
        String reasonTitle = null;
        String deniedAlert = null;
        ApplicationInfo applicationInfo = context.getApplicationInfo();
        String appName = context.getPackageManager().getApplicationLabel(applicationInfo).toString();
        switch (type) {
            case PERMISSION_MICROPHONE: {
                permission = PermissionRequester.PermissionConstants.MICROPHONE;
                reasonTitle = context.getString(R.string.tuicalling_permission_mic_reason_title, appName);
                reason = context.getString(R.string.tuicalling_permission_mic_reason);
                deniedAlert = context.getString(R.string.tuicalling_tips_start_audio);
                break;
            }
            case PERMISSION_CAMERA: {
                permission = PermissionRequester.PermissionConstants.CAMERA;
                reasonTitle = context.getString(R.string.tuicalling_permission_camera_reason_title, appName);
                reason = context.getString(R.string.tuicalling_permission_camera_reason);
                deniedAlert = context.getString(R.string.tuicalling_tips_start_camera);
                break;
            }
            default:
                break;
        }

        PermissionRequester.SimpleCallback simpleCallback = new PermissionRequester.SimpleCallback() {
            @Override
            public void onGranted() {
                if (callback != null) {
                    callback.onGranted();
                }
            }

            @Override
            public void onDenied() {
                if (callback != null) {
                    callback.onDenied();
                }
            }
        };
        if (!TextUtils.isEmpty(permission)) {
            PermissionRequester.permission(permission)
                    .reason(reason)
                    .reasonTitle(reasonTitle)
                    .deniedAlert(deniedAlert)
                    .callback(simpleCallback)
                    .permissionDialogCallback(new PermissionRequester.PermissionDialogCallback() {
                        @Override
                        public void onApproved() {
                            if (callback != null) {
                                callback.onDialogApproved();
                            }
                        }

                        @Override
                        public void onRefused() {
                            if (callback != null) {
                                callback.onDialogRefused();
                            }
                        }
                    })
                    .request();
        }
    }

    public abstract static class PermissionCallback {

        public void onGranted() {
        }

        public void onDenied() {
        }

        public void onDialogApproved() {
        }

        public void onDialogRefused() {
        }
    }

    public static void requestFloatPermission(Context context) {
        if (PermissionUtils.hasPermission(context)) {
            return;
        }
        if (BrandUtils.isBrandVivo()) {
            requestVivoFloatPermission(context);
        } else {
            startCommonSettings(context);
        }
    }

    private static void startCommonSettings(Context context) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
            intent.setData(Uri.parse("package:" + context.getPackageName()));
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        }
    }

    private static void requestVivoFloatPermission(Context context) {
        Intent vivoIntent = new Intent();
        String model = BrandUtils.getModel();
        boolean isVivoY85 = false;
        if (!TextUtils.isEmpty(model)) {
            isVivoY85 = model.contains("Y85") && !model.contains("Y85A");
        }

        if (!TextUtils.isEmpty(model) && (isVivoY85 || model.contains("vivo Y53L"))) {
            vivoIntent.setClassName("com.vivo.permissionmanager",
                    "com.vivo.permissionmanager.activity.PurviewTabActivity");
            vivoIntent.putExtra("tabId", "1");
        } else {
            vivoIntent.setClassName("com.vivo.permissionmanager",
                    "com.vivo.permissionmanager.activity.SoftPermissionDetailActivity");
            vivoIntent.setAction("secure.intent.action.softPermissionDetail");
        }

        vivoIntent.putExtra("packagename", context.getPackageName());
        vivoIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(vivoIntent);
    }
}
