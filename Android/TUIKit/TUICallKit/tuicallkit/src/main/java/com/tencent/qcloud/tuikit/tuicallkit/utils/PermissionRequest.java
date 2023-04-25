package com.tencent.qcloud.tuikit.tuicallkit.utils;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;

import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.utils.BrandUtils;
import com.tencent.qcloud.tuikit.tuicallengine.utils.PermissionUtils;
import com.tencent.qcloud.tuikit.tuicallkit.R;

import java.util.ArrayList;
import java.util.List;

public class PermissionRequest {

    public static void requestPermissions(Context context, TUICallDefine.MediaType type, PermissionCallback callback) {
        StringBuilder title = new StringBuilder().append(context.getString(R.string.tuicalling_permission_microphone));
        StringBuilder reason = new StringBuilder().append(context.getString(R.string.tuicalling_permission_mic_reason));
        List<String> permissionList = new ArrayList<>();
        permissionList.add(Manifest.permission.RECORD_AUDIO);

        if (TUICallDefine.MediaType.Video.equals(type)) {
            title.append(context.getString(R.string.tuicalling_permission_separator));
            title.append(context.getString(R.string.tuicalling_permission_camera));
            reason.append(context.getString(R.string.tuicalling_permission_camera_reason));
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
                .settingsTip(context.getString(R.string.tuicalling_permission_tips, title))
                .callback(callback)
                .request();
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
