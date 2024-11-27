package com.tencent.qcloud.tuikit.tuimultimediaplugin.pick.permission;

import static android.Manifest.permission;

import android.Manifest;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;
import com.tencent.imsdk.common.IMContext;
import com.tencent.imsdk.common.SystemUtil;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;

public class ImageVideoPermissionRequester {
    private static final String TAG = "ImageVideoPermissionReq";

    public static boolean checkPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (PermissionRequester.newInstance(permission.READ_MEDIA_IMAGES, permission.READ_MEDIA_VIDEO).has()) {
                return true;
            }
        }
        if (Build.VERSION.SDK_INT >= 34) {
            if (PermissionRequester.newInstance("android.permission.READ_MEDIA_VISUAL_USER_SELECTED").has()) {
                return true;
            }
        }
        return PermissionRequester.newInstance(permission.READ_EXTERNAL_STORAGE).has();
    }

    public static boolean checkVisualPermission() {
        if (Build.VERSION.SDK_INT >= 34) {
            return PermissionRequester.newInstance("android.permission.READ_MEDIA_VISUAL_USER_SELECTED").has();
        }
        return false;
    }

    public static void requestPermissions(PermissionCallback callback) {
        String title = ServiceInitializer.getAppContext().getString(R.string.multimedia_plugin_request_permission_media_title, getAppName());
        String description = ServiceInitializer.getAppContext().getString(R.string.multimedia_plugin_request_permission_media_reason);
        String tip = ServiceInitializer.getAppContext().getString(R.string.multimedia_plugin_request_permission_media_tip, getAppName());

        if (Build.VERSION.SDK_INT >= 34) {
            PermissionRequester.newInstance("android.permission.READ_MEDIA_VISUAL_USER_SELECTED", permission.READ_MEDIA_IMAGES, permission.READ_MEDIA_VIDEO)
                .title(title)
                .description(description)
                .settingsTip(tip)
                .callback(callback)
                .request();
        } else if (Build.VERSION.SDK_INT == Build.VERSION_CODES.TIRAMISU) {
            PermissionRequester.newInstance(permission.READ_MEDIA_IMAGES, permission.READ_MEDIA_VIDEO)
                .title(title)
                .description(description)
                .settingsTip(tip)
                .callback(callback)
                .request();
        } else {
            title = ServiceInitializer.getAppContext().getString(R.string.multimedia_plugin_request_permission_storage_title, getAppName());
            description = ServiceInitializer.getAppContext().getString(R.string.multimedia_plugin_request_permission_storage_reason);
            tip = ServiceInitializer.getAppContext().getString(R.string.multimedia_plugin_request_permission_storage_tip, getAppName());
            PermissionRequester.newInstance(permission.READ_EXTERNAL_STORAGE)
                .title(title)
                .description(description)
                .settingsTip(tip)
                .callback(callback)
                .request();
        }
    }

    public static String getAppName() {
        String appName = "";
        Context context = ServiceInitializer.getAppContext();
        PackageManager packageManager = context.getPackageManager();
        try {
            ApplicationInfo applicationInfo = packageManager.getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            packageManager.getApplicationLabel(applicationInfo);
            CharSequence labelCharSequence = applicationInfo.loadLabel(packageManager);
            if (labelCharSequence != null && labelCharSequence.length() > 0) {
                appName = labelCharSequence.toString();
            }
        } catch (PackageManager.NameNotFoundException e) {
            Log.e(TAG, "getAppName exception:" + e.getMessage());
        }

        return appName;
    }
}
