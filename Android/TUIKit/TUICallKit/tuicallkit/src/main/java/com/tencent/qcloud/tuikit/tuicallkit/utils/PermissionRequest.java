package com.tencent.qcloud.tuikit.tuicallkit.utils;

import android.Manifest;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.os.Build;
import android.text.TextUtils;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.R;

import java.util.ArrayList;
import java.util.List;

public class PermissionRequest {

    public static void requestPermissions(Context context, TUICallDefine.MediaType type, PermissionCallback callback) {
        StringBuilder title = new StringBuilder().append(context.getString(R.string.tuicalling_permission_microphone));
        StringBuilder reason = new StringBuilder();
        String microphonePermissionsDescription = (String) TUICore.createObject(
                TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
                TUIConstants.Privacy.PermissionsFactory.PermissionsName.MICROPHONE_PERMISSIONS, null);
        if (!TextUtils.isEmpty(microphonePermissionsDescription)) {
            reason.append(microphonePermissionsDescription);
        } else {
            reason.append(context.getString(R.string.tuicalling_permission_mic_reason));
        }
        List<String> permissionList = new ArrayList<>();
        permissionList.add(Manifest.permission.RECORD_AUDIO);

        if (TUICallDefine.MediaType.Video.equals(type)) {
            title.append(context.getString(R.string.tuicalling_permission_separator));
            title.append(context.getString(R.string.tuicalling_permission_camera));
            String cameraPermissionsDescription = (String) TUICore.createObject(
                    TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
                    TUIConstants.Privacy.PermissionsFactory.PermissionsName.CAMERA_PERMISSIONS, null);
            if (!TextUtils.isEmpty(cameraPermissionsDescription)) {
                reason.append(cameraPermissionsDescription);
            } else {
                reason.append(context.getString(R.string.tuicalling_permission_camera_reason));
            }
            permissionList.add(Manifest.permission.CAMERA);
        }

        PermissionCallback permissionCallback = new PermissionCallback() {
            @Override
            public void onGranted() {
                requestBluetoothPermission(context, new PermissionCallback() {
                    @Override
                    public void onGranted() {
                        if (callback != null) {
                            callback.onGranted();
                        }
                    }
                });
            }

            @Override
            public void onDenied() {
                super.onDenied();
                if (callback != null) {
                    callback.onDenied();
                }
            }
        };

        ApplicationInfo applicationInfo = context.getApplicationInfo();
        String appName = context.getPackageManager().getApplicationLabel(applicationInfo).toString();

        String[] permissions = permissionList.toArray(new String[0]);
        PermissionRequester.newInstance(permissions)
                .title(context.getString(R.string.tuicalling_permission_title, appName, title))
                .description(reason.toString())
                .settingsTip(context.getString(R.string.tuicalling_permission_tips, title) + "\n" + reason.toString())
                .callback(permissionCallback)
                .request();
    }

    /**
     * Android S(31) need apply for Nearby devices(Bluetooth) permission to support bluetooth headsets.
     * Please refer to: https://developer.android.com/guide/topics/connectivity/bluetooth/permissions
     */
    private static void requestBluetoothPermission(Context context, PermissionCallback callback) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            callback.onGranted();
            return;
        }
        String title = context.getString(R.string.tuicalling_permission_bluetooth);
        String reason = context.getString(R.string.tuicalling_permission_bluetooth_reason);

        ApplicationInfo applicationInfo = context.getApplicationInfo();
        String appName = context.getPackageManager().getApplicationLabel(applicationInfo).toString();

        PermissionRequester.newInstance(Manifest.permission.BLUETOOTH_CONNECT)
                .title(context.getString(R.string.tuicalling_permission_title, appName, title))
                .description(reason)
                .settingsTip(reason)
                .callback(new PermissionCallback() {
                    @Override
                    public void onGranted() {
                        callback.onGranted();
                    }

                    @Override
                    public void onDenied() {
                        super.onDenied();
                        //bluetooth is unnecessary permission, return permission granted
                        callback.onGranted();
                    }
                })
                .request();
    }

    public static void requestFloatPermission(Context context) {
        if (PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()) {
            return;
        }
        //In TUICallKit,Please open both OverlayWindows and Background pop-ups permission.
        PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION, PermissionRequester.BG_START_PERMISSION)
                .request();
    }
}
