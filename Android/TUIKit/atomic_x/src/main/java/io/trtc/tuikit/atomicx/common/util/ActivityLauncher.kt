package io.trtc.tuikit.atomicx.common.util

import android.app.Application
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log

object ActivityLauncher {
    private const val TAG = "IntentUtils"

    @JvmStatic
    fun startActivity(context: Context?, intent: Intent?) {
        if (intent == null || context == null) {
            Log.e(TAG, "intent or activity is null")
            return
        }
        if (context.packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY) == null) {
            Log.w(TAG, "No activity match : $intent")
            return
        }
        try {
            if (context is Application) {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        } catch (e: ActivityNotFoundException) {
            Log.e(TAG, "ActivityNotFoundException : $intent")
        }
    }
}
