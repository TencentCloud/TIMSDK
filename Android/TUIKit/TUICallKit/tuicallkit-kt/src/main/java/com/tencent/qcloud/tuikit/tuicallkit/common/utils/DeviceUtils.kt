package com.tencent.qcloud.tuikit.tuicallkit.common.utils

import android.app.ActivityManager
import android.app.KeyguardManager
import android.content.Context
import android.os.Build
import android.view.Window
import android.view.WindowManager
import com.tencent.qcloud.tuicore.util.TUIBuild

object DeviceUtils {
    fun setScreenLockParams(window: Window) {
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                    or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )
    }

    fun isScreenLocked(context: Context): Boolean {
        val keyguardManager = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        return if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            keyguardManager.isDeviceLocked()
        } else {
            keyguardManager.inKeyguardRestrictedInputMode()
        }
    }

    fun isAppRunningForeground(context: Context): Boolean {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager?
        val runningAppProcessInfos = activityManager?.runningAppProcesses ?: return false
        val packageName = context.packageName
        for (appProcessInfo in runningAppProcessInfos) {
            if (appProcessInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                && appProcessInfo.processName == packageName) {
                return true
            }
        }
        return false
    }
}