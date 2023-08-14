package com.tencent.qcloud.tuikit.tuicallkit.utils;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.utils.BrandUtils;
import com.tencent.qcloud.tuikit.tuicallengine.utils.PermissionUtils;
import com.tencent.qcloud.tuikit.tuicallkit.R;

import java.lang.reflect.Method;
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
        //Android S(31) need apply for this permission,refer to:https://developer.android.com/about/versions/12/features/bluetooth-permissions?hl=zh-cn
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            title.append(context.getString(R.string.tuicalling_permission_separator));
            title.append(context.getString(R.string.tuicalling_permission_bluetooth));
            reason.append(context.getString(R.string.tuicalling_permission_bluetooth_reason));
            permissionList.add(Manifest.permission.BLUETOOTH_CONNECT);
        }

        ApplicationInfo applicationInfo = context.getApplicationInfo();
        String appName = context.getPackageManager().getApplicationLabel(applicationInfo).toString();

        String[] permissions = permissionList.toArray(new String[0]);
        PermissionRequester.newInstance(permissions)
                .title(context.getString(R.string.tuicalling_permission_title, appName, title))
                .description(reason.toString())
                .settingsTip(context.getString(R.string.tuicalling_permission_tips, title) + "\n" + reason.toString())
                .callback(callback)
                .request();
    }

    public static void requestFloatPermission(Context context) {
        if (PermissionUtils.hasPermission(context)) {
            return;
        }
        if (BrandUtils.isBrandXiaoMi()) {
            startXiaomiPermissionSettings(context);
        } else {
            startCommonSettings(context);
        }
    }

    private static void startXiaomiPermissionSettings(Context context) {
        if (!isMiuiOptimization()) {
            startCommonSettings(context);
            return;
        }

        try {
            Intent intent = new Intent("miui.intent.action.APP_PERM_EDITOR");
            intent.setClassName("com.miui.securitycenter",
                    "com.miui.permcenter.permissions.PermissionsEditorActivity");
            intent.putExtra("extra_pkgname", context.getPackageName());
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);

            ToastUtil.toastShortMessage(context.getString(R.string.tuicallkit_float_permission_hint));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void startCommonSettings(Context context) {
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
                intent.setData(Uri.parse("package:" + context.getPackageName()));
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(intent);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //Check whether MIUI-optimization is enabled on Xiaomi phone(Developer option -> Enable MIUI-optimization)
    public static boolean isMiuiOptimization() {
        String miuiOptimization = "";
        try {
            Class systemProperties = Class.forName("android.os.systemProperties");
            Method get = systemProperties.getDeclaredMethod("get", String.class, String.class);
            miuiOptimization = (String) get.invoke(systemProperties, "persist.sys.miuiOptimization", "");
            //The user has not adjusted the MIUI-optimization switch (default) | user open MIUI-optimization
            return TextUtils.isEmpty(miuiOptimization) | "true".equals(miuiOptimization);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private static void requestVivoFloatPermission(Context context) {
        Intent intent = new Intent();
        String model = BrandUtils.getModel();
        boolean isVivoY85 = false;
        if (!TextUtils.isEmpty(model)) {
            isVivoY85 = model.contains("Y85") && !model.contains("Y85A");
        }

        if (!TextUtils.isEmpty(model) && (isVivoY85 || model.contains("vivo Y53L"))) {
            intent.setClassName("com.vivo.permissionmanager",
                    "com.vivo.permissionmanager.activity.PurviewTabActivity");
            intent.putExtra("tabId", "1");
        } else {
            intent.setClassName("com.vivo.permissionmanager",
                    "com.vivo.permissionmanager.activity.SoftPermissionDetailActivity");
            intent.setAction("secure.intent.action.softPermissionDetail");
        }

        intent.putExtra("packagename", context.getPackageName());
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        try {
            context.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
