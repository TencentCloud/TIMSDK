package com.tencent.qcloud.tuikit.tuicallkit.common.utils

import android.Manifest
import android.app.AppOpsManager
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuikit.tuicallkit.R

object PermissionRequest {
    fun requestPermissions(context: Context, type: TUICallDefine.MediaType, callback: PermissionCallback?) {
        val title = StringBuilder().append(context.getString(R.string.tuicallkit_permission_microphone))
        val reason = StringBuilder()
        reason.append(getMicrophonePermissionHint(context))

        val permissionList: MutableList<String> = ArrayList()
        permissionList.add(Manifest.permission.RECORD_AUDIO)
        if (TUICallDefine.MediaType.Video == type) {
            title.append(context.getString(R.string.tuicallkit_permission_separator))
            title.append(context.getString(R.string.tuicallkit_permission_camera))
            reason.append(getCameraPermissionHint(context))
            permissionList.add(Manifest.permission.CAMERA)
        }

        if (PermissionRequester.newInstance(*permissionList.toTypedArray()).has()) {
            callback?.onGranted()
            return
        }

        val permissionCallback: PermissionCallback = object : PermissionCallback() {
            override fun onGranted() {
                requestBluetoothPermission(context, object : PermissionCallback() {
                    override fun onGranted() {
                        callback?.onGranted()
                    }
                })
            }

            override fun onDenied() {
                super.onDenied()
                callback?.onDenied()
            }
        }
        val applicationInfo = context.applicationInfo
        val appName = context.packageManager.getApplicationLabel(applicationInfo).toString()
        PermissionRequester.newInstance(*permissionList.toTypedArray())
            .title(context.getString(R.string.tuicallkit_permission_title, appName, title))
            .description(reason.toString())
            .settingsTip("${context.getString(R.string.tuicallkit_permission_tips, title)} $reason".trimIndent())
            .callback(permissionCallback)
            .request()
    }

    fun requestCameraPermission(context: Context, callback: PermissionCallback?) {
        if (PermissionRequester.newInstance(Manifest.permission.CAMERA).has()) {
            callback?.onGranted()
            return
        }

        val permissionCallback: PermissionCallback = object : PermissionCallback() {
            override fun onGranted() {
                callback?.onGranted()
            }

            override fun onDenied() {
                super.onDenied()
                callback?.onDenied()
            }
        }

        val title = context.getString(R.string.tuicallkit_permission_camera)
        val reason = getCameraPermissionHint(context)
        val appName = context.packageManager.getApplicationLabel(context.applicationInfo).toString()

        PermissionRequester.newInstance(Manifest.permission.CAMERA)
            .title(context.getString(R.string.tuicallkit_permission_title, appName, title))
            .description(reason)
            .settingsTip("${context.getString(R.string.tuicallkit_permission_tips, title)} $reason".trimIndent())
            .callback(permissionCallback)
            .request()
    }

    /**
     * Android S(31) need apply for Nearby devices(Bluetooth) permission to support bluetooth headsets.
     * Please refer to: https://developer.android.com/guide/topics/connectivity/bluetooth/permissions
     */
    private fun requestBluetoothPermission(context: Context, callback: PermissionCallback) {
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.S) {
            callback.onGranted()
            return
        }
        if (PermissionRequester.newInstance(Manifest.permission.BLUETOOTH_CONNECT).has()) {
            callback.onGranted()
            return
        }

        val title = context.getString(R.string.tuicallkit_permission_bluetooth)
        val reason = context.getString(R.string.tuicallkit_permission_bluetooth_reason)
        val applicationInfo = context.applicationInfo
        val appName = context.packageManager.getApplicationLabel(applicationInfo).toString()
        PermissionRequester.newInstance(Manifest.permission.BLUETOOTH_CONNECT)
            .title(context.getString(R.string.tuicallkit_permission_title, appName, title))
            .description(reason)
            .settingsTip(reason)
            .callback(object : PermissionCallback() {
                override fun onGranted() {
                    callback.onGranted()
                }

                override fun onDenied() {
                    super.onDenied()
                    //bluetooth is unnecessary permission, return permission granted
                    callback.onGranted()
                }
            })
            .request()
    }

    private fun getMicrophonePermissionHint(context: Context): String {
        val microphonePermissionsDescription = TUICore.createObject(
            TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
            TUIConstants.Privacy.PermissionsFactory.PermissionsName.MICROPHONE_PERMISSIONS, null
        ) as String?
        return if (!microphonePermissionsDescription.isNullOrEmpty()) {
            microphonePermissionsDescription
        } else {
            context.getString(R.string.tuicallkit_permission_mic_reason)
        }
    }

    private fun getCameraPermissionHint(context: Context): String {
        val cameraPermissionsDescription = TUICore.createObject(
            TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
            TUIConstants.Privacy.PermissionsFactory.PermissionsName.CAMERA_PERMISSIONS, null
        ) as String?
        return if (!cameraPermissionsDescription.isNullOrEmpty()) {
            cameraPermissionsDescription
        } else {
            context.getString(R.string.tuicallkit_permission_camera_reason)
        }
    }

    fun isNotificationEnabled(): Boolean {
        val context = TUIConfig.getAppContext()
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O) {
            // For Android Oreo and above
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            return manager.areNotificationsEnabled()
        }
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.KITKAT) {
            // For versions prior to Android Oreo
            var appOps: AppOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val appInfo = context.applicationInfo
            val packageName = context.applicationContext.packageName
            val uid = appInfo.uid
            try {
                var appOpsClass: Class<*> = Class.forName(AppOpsManager::class.java.name)
                val checkOpNoThrowMethod = appOpsClass.getMethod(
                    "checkOpNoThrow", Integer.TYPE, Integer.TYPE, String::class.java
                )
                val opPostNotificationValue = appOpsClass.getDeclaredField("OP_POST_NOTIFICATION")
                val value = opPostNotificationValue[Int::class.java] as Int
                return checkOpNoThrowMethod.invoke(appOps, value, uid, packageName) as Int == AppOpsManager.MODE_ALLOWED
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        return false
    }
}