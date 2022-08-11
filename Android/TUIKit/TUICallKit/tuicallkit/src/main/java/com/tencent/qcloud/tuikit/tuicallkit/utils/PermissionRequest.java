package com.tencent.qcloud.tuikit.tuicallkit.utils;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.res.Resources;
import android.text.TextUtils;

import androidx.annotation.IntDef;

import com.tencent.qcloud.tuicore.util.PermissionRequester;
import com.tencent.qcloud.tuikit.tuicallkit.ui.R;

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
        ApplicationInfo applicationInfo = context.getApplicationContext().getApplicationInfo();
        Resources resources = context.getResources();
        String appName = resources.getString(applicationInfo.labelRes);
        switch (type) {
            case PERMISSION_MICROPHONE: {
                permission = PermissionRequester.PermissionConstants.MICROPHONE;
                reasonTitle = resources.getString(R.string.tuicalling_permission_mic_reason_title, appName);
                reason = resources.getString(R.string.tuicalling_permission_mic_reason);
                deniedAlert = resources.getString(R.string.tuicalling_tips_start_audio);
                break;
            }
            case PERMISSION_CAMERA: {
                permission = PermissionRequester.PermissionConstants.CAMERA;
                reasonTitle = resources.getString(R.string.tuicalling_permission_camera_reason_title, appName);
                reason = resources.getString(R.string.tuicalling_permission_camera_reason);
                deniedAlert = resources.getString(R.string.tuicalling_tips_start_camera);
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
}
