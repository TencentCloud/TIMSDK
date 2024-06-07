package com.tencent.cloud.tuikit.roomkit.common.utils;

import android.annotation.SuppressLint;
import android.app.AppOpsManager;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Binder;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.TUIBuild;

import java.lang.reflect.Method;

public class DrawOverlaysPermissionUtil {

    @SuppressLint("NewApi")
    public static boolean isGrantedDrawOverlays() {
        Context context = TUILogin.getAppContext();
        if (BrandUtils.isBrandXiaoMi()) {
            if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.M) {
                return Settings.canDrawOverlays(context);
            }

            if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.KITKAT) {
                return isXiaomiBgStartPermissionAllowed(context);
            }
            return true;
        } else if (BrandUtils.isBrandVivo()) {
            return isVivoBgStartPermissionAllowed(context);
        } else {
            if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.M) {
                return Settings.canDrawOverlays(context);
            } else if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.KITKAT) {
                return hasPermissionBelowMarshmallow(context);
            }
            return true;
        }
    }

    public static void requestDrawOverlays() {
        Context context = TUILogin.getAppContext();
        if (isGrantedDrawOverlays()) {
            return;
        }
        if (BrandUtils.isBrandVivo()) {
            requestVivoFloatPermission(context);
        } else {
            startCommonSettings(context);
        }
    }

    private static boolean hasPermissionBelowMarshmallow(Context context) {
        try {
            AppOpsManager manager = null;
            if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.KITKAT) {
                manager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
            }
            if (manager == null) {
                return false;
            }
            Method dispatchMethod = AppOpsManager.class.getMethod("checkOp", int.class, int.class, String.class);
            return AppOpsManager.MODE_ALLOWED == (Integer) dispatchMethod.invoke(
                    manager, 24, Binder.getCallingUid(), context.getApplicationContext().getPackageName());
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean isXiaomiBgStartPermissionAllowed(Context context) {
        try {
            AppOpsManager appOpsManager = null;
            if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.KITKAT) {
                appOpsManager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
            }
            if (appOpsManager == null) {
                return false;
            }
            int op = 10021;
            Method method = appOpsManager.getClass().getMethod("checkOpNoThrow",
                    new Class[]{int.class, int.class, String.class});
            method.setAccessible(true);
            int result = (int) method.invoke(appOpsManager, op, android.os.Process.myUid(), context.getPackageName());
            return AppOpsManager.MODE_ALLOWED == result;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private static boolean isVivoBgStartPermissionAllowed(Context context) {
        try {
            Uri uri = Uri.parse("content://com.vivo.permissionmanager.provider.permission/start_bg_activity");
            Cursor cursor = context.getContentResolver().query(uri, null, "pkgname = ?",
                    new String[]{context.getPackageName()},
                    null);
            if (cursor.moveToFirst()) {
                int state = cursor.getInt(cursor.getColumnIndex("currentstate"));
                return 0 == state;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
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