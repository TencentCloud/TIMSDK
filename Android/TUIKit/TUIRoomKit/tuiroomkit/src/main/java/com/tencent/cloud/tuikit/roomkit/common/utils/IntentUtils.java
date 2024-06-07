package com.tencent.cloud.tuikit.roomkit.common.utils;

import android.app.Application;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;

public class IntentUtils {
    private static final String TAG = "IntentUtils";

    public static void safeStartActivity(Context context, Intent intent) {
        if (intent == null || context == null) {
            Log.e(TAG, "intent or activity is null");
            return;
        }
        if (context.getPackageManager().resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY) == null) {
            Log.w(TAG, "No activity match : " + intent.toString());
            return;
        }
        try {
            if (context instanceof Application) {
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            }
            context.startActivity(intent);
        } catch (ActivityNotFoundException e) {
            Log.e(TAG, "ActivityNotFoundException : " + intent.toString());
        }
    }
}
