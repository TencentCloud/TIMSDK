package com.tencent.qcloud.tuikit.tuicallkit.common.utils

import android.Manifest
import android.app.AppOpsManager
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import io.trtc.tuikit.atomicx.common.permission.PermissionCallback
import io.trtc.tuikit.atomicx.common.permission.PermissionRequester
import com.tencent.qcloud.tuicore.util.TUIBuild
import com.tencent.qcloud.tuikit.tuicallkit.R
import io.trtc.tuikit.atomicxcore.api.call.CallMediaType

object PermissionRequest {
    fun requestPermissions(context: Context, type: CallMediaType?, callback: PermissionCallback?) {
        val title = StringBuilder().append(context.getString(R.string.callkit_permission_microphone))
        val applicationInfo = context.applicationInfo
        val appName = context.packageManager.getApplicationLabel(applicationInfo).toString()
        val reason = StringBuilder()
        reason.append(getMicrophonePermissionHint(context, appName))

        val permissionList: MutableList<String> = ArrayList()
        permissionList.add(Manifest.permission.RECORD_AUDIO)
        if (CallMediaType.Video == type) {
            title.append(context.getString(R.string.callkit_permission_separator))
            title.append(context.getString(R.string.callkit_permission_camera))
            reason.append(getCameraPermissionHint(context, appName))
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
        PermissionRequester.newInstance(*permissionList.toTypedArray())
            .title(context.getString(R.string.callkit_permission_title, appName, title))
            .description("${context.getString(R.string.callkit_permission_tips, title)} $reason".trimIndent())
            .settingsTip("${context.getString(R.string.callkit_permission_tips, title)} $reason".trimIndent())
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

        val title = context.getString(R.string.callkit_permission_bluetooth)
        val reason = context.getString(R.string.callkit_permission_bluetooth_reason)
        val applicationInfo = context.applicationInfo
        val appName = context.packageManager.getApplicationLabel(applicationInfo).toString()
        PermissionRequester.newInstance(Manifest.permission.BLUETOOTH_CONNECT)
            .title(context.getString(R.string.callkit_permission_title, appName, title))
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

    private fun getMicrophonePermissionHint(context: Context, appName: String): String {
        val microphonePermissionsDescription = TUICore.createObject(
            TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
            TUIConstants.Privacy.PermissionsFactory.PermissionsName.MICROPHONE_PERMISSIONS, null
        ) as String?
        return if (!microphonePermissionsDescription.isNullOrEmpty()) {
            microphonePermissionsDescription
        } else {
            context.getString(R.string.callkit_permission_mic_reason, appName)
        }
    }

    private fun getCameraPermissionHint(context: Context, appName: String): String {
        val cameraPermissionsDescription = TUICore.createObject(
            TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
            TUIConstants.Privacy.PermissionsFactory.PermissionsName.CAMERA_PERMISSIONS, null
        ) as String?
        return if (!cameraPermissionsDescription.isNullOrEmpty()) {
            cameraPermissionsDescription
        } else {
            context.getString(R.string.callkit_permission_camera_reason, appName)
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