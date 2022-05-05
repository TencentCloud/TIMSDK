package com.tencent.qcloud.tuikit.tuichat.util;

import android.content.pm.ApplicationInfo;
import android.content.res.Resources;
import android.text.TextUtils;

import androidx.annotation.IntDef;

import com.tencent.qcloud.tuicore.util.PermissionRequester;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;

public class PermissionHelper {
    public static final int PERMISSION_MICROPHONE = 1;
    public static final int PERMISSION_CAMERA = 2;
    public static final int PERMISSION_STORAGE = 3;

    @IntDef({PERMISSION_MICROPHONE, PERMISSION_CAMERA, PERMISSION_STORAGE})
    public @interface PermissionType {
    }

    public static void requestPermission(@PermissionType int type, PermissionCallback callback) {
        String permission = null;
        String reason = null;
        String reasonTitle = null;
        String deniedAlert = null;
        ApplicationInfo applicationInfo = TUIChatService.getAppContext().getApplicationInfo();
        int permissionIcon = 0;
        Resources resources = TUIChatService.getAppContext().getResources();
        String appName = resources.getString(applicationInfo.labelRes);
        switch (type) {
            case PERMISSION_MICROPHONE: {
                permission = PermissionRequester.PermissionConstants.MICROPHONE;
                reasonTitle = resources.getString(R.string.chat_permission_mic_reason_title, appName);
                reason = resources.getString(R.string.chat_permission_mic_reason);
                deniedAlert = resources.getString(R.string.chat_permission_mic_dialog_alert, appName);
                permissionIcon = R.drawable.chat_permission_icon_mic;
                break;
            }
            case PERMISSION_CAMERA: {
                permission = PermissionRequester.PermissionConstants.CAMERA;
                reasonTitle = resources.getString(R.string.chat_permission_camera_reason_title, appName);
                reason = resources.getString(R.string.chat_permission_camera_reason);
                deniedAlert = resources.getString(R.string.chat_permission_camera_dialog_alert, appName);
                permissionIcon = R.drawable.chat_permission_icon_camera;
                break;
            }
            case PERMISSION_STORAGE: {
                permission = PermissionRequester.PermissionConstants.STORAGE;
                reasonTitle = resources.getString(R.string.chat_permission_storage_reason_title, appName);
                reason = resources.getString(R.string.chat_permission_storage_reason);
                deniedAlert = resources.getString(R.string.chat_permission_storage_dialog_alert, appName);
                permissionIcon = R.drawable.chat_permission_icon_file;
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
                    .reasonIcon(permissionIcon)
                    .deniedAlert(deniedAlert)
                    .callback(simpleCallback)
                    .request();
        }
    }

    public interface PermissionCallback {
        void onGranted();
        void onDenied();
    }
}
