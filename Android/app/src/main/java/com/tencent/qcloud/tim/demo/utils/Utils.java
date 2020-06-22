package com.tencent.qcloud.tim.demo.utils;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import com.tencent.qcloud.tim.uikit.TUIKit;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import androidx.core.app.ActivityCompat;

public class Utils {

    private static final String TAG = Utils.class.getSimpleName();

    public static final int REQ_PERMISSION_CODE = 0x100;

    public static void printBundle(Intent intent) {
        DemoLog.i(TAG, "intent: " + intent);
        if (intent == null) {
            return;
        }
        Bundle bundle = intent.getExtras();
        DemoLog.i(TAG, "bundle: " + bundle);
        if (bundle == null) {
            // oppo scheme url解析
            Uri uri = intent.getData();
            Set<String> set = null;
            if (uri != null) {
                set = uri.getQueryParameterNames();
            }
            if (set != null) {
                for (String key : set) {
                    String value = uri.getQueryParameter(key);
                    DemoLog.i(TAG, "push scheme url key: " + key + " value: " + value);
                }
            }
        } else {
            String ext = bundle.getString("ext");
            DemoLog.i(TAG, "push custom data ext: " + ext);

            Set<String> set = bundle.keySet();
            if (set != null) {
                for (String key : set) {
                    Object value = bundle.get(key);
                    DemoLog.i(TAG, "push custom data key: " + key + " value: " + value);
                }
            }
        }
    }


    //权限检查
    public static boolean checkPermission(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            List<String> permissions = new ArrayList<>();
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TUIKit.getAppContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TUIKit.getAppContext(), Manifest.permission.CAMERA)) {
                permissions.add(Manifest.permission.CAMERA);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TUIKit.getAppContext(), Manifest.permission.RECORD_AUDIO)) {
                permissions.add(Manifest.permission.RECORD_AUDIO);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TUIKit.getAppContext(), Manifest.permission.READ_PHONE_STATE)) {
                permissions.add(Manifest.permission.READ_PHONE_STATE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TUIKit.getAppContext(), Manifest.permission.READ_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE);
            }
            if (permissions.size() != 0) {
                String[] permissionsArray = permissions.toArray(new String[1]);
                ActivityCompat.requestPermissions(activity,
                        permissionsArray,
                        REQ_PERMISSION_CODE);
                return false;
            }
        }

        return true;
    }
}
