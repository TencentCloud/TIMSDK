package com.tencent.liteav.trtccalling.model.util;

import android.app.AppOpsManager;
import android.content.Context;
import android.database.Cursor;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Binder;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.RequiresApi;

import java.lang.reflect.Method;

public class PermissionUtil {
    private static final String TAG = "PermissionUtil";

    //是否已经有权限了,或者是否已经给用户提示过了
    public static boolean mHasPermissionOrHasHinted = false;

    public static boolean hasPermission(Context context) {
        if (BrandUtil.isBrandXiaoMi()) {
            if (Build.VERSION.SDK_INT >= 30 && !Settings.canDrawOverlays(context)) {
                return false;
            }
            return isXiaomiBgStartPermissionAllowed(context);
        } else if (BrandUtil.isBrandVivo()) {
            return isVivoBgStartPermissionAllowed(context);
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                return Settings.canDrawOverlays(context);
            } else {
                return hasPermissionBelowMarshmallow(context);
            }
        }
    }

    public static boolean hasPermissionOnActivityResult(Context context) {
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.O) {
            return hasPermissionForO(context);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return Settings.canDrawOverlays(context);
        } else {
            return hasPermissionBelowMarshmallow(context);
        }
    }

    /**
     * 6.0以下判断是否有权限
     * 理论上6.0以上才需处理权限，但有的国内rom在6.0以下就添加了权限
     */
    static boolean hasPermissionBelowMarshmallow(Context context) {
        try {
            AppOpsManager manager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
            Method dispatchMethod = AppOpsManager.class.getMethod("checkOp", int.class, int.class, String.class);
            return AppOpsManager.MODE_ALLOWED == (Integer) dispatchMethod.invoke(
                    manager, 24, Binder.getCallingUid(), context.getApplicationContext().getPackageName());
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 用于判断8.0时是否有权限，仅用于OnActivityResult
     */
    @RequiresApi(api = Build.VERSION_CODES.M)
    private static boolean hasPermissionForO(Context context) {
        try {
            WindowManager mgr = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
            if (mgr == null) return false;
            View viewToAdd = new View(context);
            WindowManager.LayoutParams params = new WindowManager.LayoutParams(0, 0,
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
                            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY : WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                    PixelFormat.TRANSPARENT);
            viewToAdd.setLayoutParams(params);
            mgr.addView(viewToAdd, params);
            mgr.removeView(viewToAdd);
            return true;
        } catch (Exception e) {
            Log.e(TAG, "hasPermissionForO e:" + e.toString());
        }
        return false;
    }

    //小米后台拉起应用权限是否开启
    public static boolean isXiaomiBgStartPermissionAllowed(Context context) {
        AppOpsManager appOpsManager = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
        int op = 10021;
        try {
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

    //Vivo后台拉起应用权限是否开启
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
}
