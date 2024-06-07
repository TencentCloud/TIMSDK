package com.tencent.qcloud.tim.demo.utils;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

public class SystemUtil {
    private static final String TAG = "SystemUtil";
    public static boolean isNetworkConnected(Context context) {
        ConnectivityManager connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivityManager == null) {
            Log.e(TAG, "connectivityManager is null");
            return false;
        }

        NetworkInfo activeNetworkInfo = null;
        try {
            activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (activeNetworkInfo != null) {
            if (activeNetworkInfo.isConnected()) {
                return true;
            } else {
                return false;
            }
        } else {
            Log.e(TAG, "activeNetwork is null");
            return false;
        }
    }
}
