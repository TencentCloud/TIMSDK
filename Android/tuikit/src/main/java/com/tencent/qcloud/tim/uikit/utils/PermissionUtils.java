package com.tencent.qcloud.tim.uikit.utils;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import androidx.core.app.ActivityCompat;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;

public class PermissionUtils {

    private static final String TAG = PermissionUtils.class.getSimpleName();

    public static boolean checkPermission(Context context, String permission) {
        TUIKitLog.i(TAG, "checkPermission permission:" + permission + "|sdk:" + Build.VERSION.SDK_INT);
        boolean flag = true;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            int result = ActivityCompat.checkSelfPermission(context, permission);
            if (PackageManager.PERMISSION_GRANTED != result) {
                showPermissionDialog(context);
                flag = false;
            }
        }
        return flag;
    }

    private static void showPermissionDialog(final Context context) {
        AlertDialog permissionDialog = new AlertDialog.Builder(context)
                .setMessage(TUIKit.getAppContext().getString(R.string.permission_content))
                .setPositiveButton(TUIKit.getAppContext().getString(R.string.setting), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                        Uri packageURI = Uri.parse("package:" + context.getPackageName());
                        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageURI);
                        context.startActivity(intent);
                    }
                })
                .setNegativeButton(TUIKit.getAppContext().getString(R.string.cancel), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        //关闭页面或者做其他操作
                        dialog.cancel();
                    }
                })
                .create();
        permissionDialog.show();
    }

}
