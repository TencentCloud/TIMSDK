package com.tencent.qcloud.tuikit.tuicallkit.utils

import android.app.ActivityManager
import android.content.Context
import android.os.PowerManager
import android.text.TextUtils
import android.util.DisplayMetrics
import android.view.Window
import android.view.WindowManager

object DeviceUtils {
    fun setScreenLockParams(window: Window?) {
        if (null == window) {
            return
        }
        val powerManager = window.context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val isScreenOn = powerManager.isScreenOn
        if (isScreenOn) {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                        or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                        or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                        or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                        or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                        or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
    }

    fun isServiceRunning(context: Context?, className: String): Boolean {
        if (context == null || TextUtils.isEmpty(className)) {
            return false
        }
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val info = am.getRunningServices(0x7FFFFFFF)
        if (info == null || info.size == 0) {
            return false
        }
        for (aInfo in info) {
            if (className == aInfo.service.className) {
                return true
            }
        }
        return false
    }

    fun isAppRunningForeground(context: Context): Boolean {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager?
        val runningAppProcessInfos = activityManager?.runningAppProcesses ?: return false
        val packageName = context.packageName
        for (appProcessInfo in runningAppProcessInfos) {
            if (appProcessInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND && appProcessInfo.processName == packageName) {
                return true
            }
        }
        return false
    }

    fun getScreenWidth(context: Context): Int {
        val metric = DisplayMetrics()
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        wm.defaultDisplay.getMetrics(metric)
        return metric.widthPixels
    }

    fun getScreenHeight(context: Context): Int {
        val metric = DisplayMetrics()
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        wm.defaultDisplay.getMetrics(metric)
        return metric.heightPixels
    }
}