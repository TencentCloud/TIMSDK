package com.tencent.qcloud.tuikit.tuicallkit.utils

import android.Manifest
import android.content.Context
import android.os.Build
import android.text.TextUtils
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.R

object PermissionRequest {
    fun requestPermissions(context: Context, type: TUICallDefine.MediaType, callback: PermissionCallback?) {
        val title = StringBuilder().append(context.getString(R.string.tuicalling_permission_microphone))
        val reason = StringBuilder()
        var microphonePermissionsDescription = TUICore.createObject(
            TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
            TUIConstants.Privacy.PermissionsFactory.PermissionsName.MICROPHONE_PERMISSIONS, null
        ) as String?
        if (!TextUtils.isEmpty(microphonePermissionsDescription)) {
            reason.append(microphonePermissionsDescription)
        } else {
            reason.append(context.getString(R.string.tuicalling_permission_mic_reason))
        }
        val permissionList: MutableList<String> = ArrayList()
        permissionList.add(Manifest.permission.RECORD_AUDIO)
        if (TUICallDefine.MediaType.Video == type) {
            title.append(context.getString(R.string.tuicalling_permission_separator))
            title.append(context.getString(R.string.tuicalling_permission_camera))
            val cameraPermissionsDescription = TUICore.createObject(
                TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
                TUIConstants.Privacy.PermissionsFactory.PermissionsName.CAMERA_PERMISSIONS, null
            ) as String?
            if (!TextUtils.isEmpty(cameraPermissionsDescription)) {
                reason.append(cameraPermissionsDescription)
            } else {
                reason.append(context.getString(R.string.tuicalling_permission_camera_reason))
            }
            permissionList.add(Manifest.permission.CAMERA)
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
        val permissions = permissionList.toTypedArray()
        PermissionRequester.newInstance(*permissions)
            .title(context.getString(R.string.tuicalling_permission_title, appName, title))
            .description(reason.toString())
            .settingsTip(
                """
    ${context.getString(R.string.tuicalling_permission_tips, title)}
    $reason
    """.trimIndent()
            )
            .callback(permissionCallback)
            .request()
    }

    /**
     * Android S(31) need apply for Nearby devices(Bluetooth) permission to support bluetooth headsets.
     * Please refer to: https://developer.android.com/guide/topics/connectivity/bluetooth/permissions
     */
    private fun requestBluetoothPermission(context: Context, callback: PermissionCallback) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            callback.onGranted()
            return
        }
        val title = context.getString(R.string.tuicalling_permission_bluetooth)
        val reason = context.getString(R.string.tuicalling_permission_bluetooth_reason)
        val applicationInfo = context.applicationInfo
        val appName = context.packageManager.getApplicationLabel(applicationInfo).toString()
        PermissionRequester.newInstance(Manifest.permission.BLUETOOTH_CONNECT)
            .title(context.getString(R.string.tuicalling_permission_title, appName, title))
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

    fun requestFloatPermission(context: Context?) {
        if (PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()) {
            return
        }
        //In TUICallKit,Please open both OverlayWindows and Background pop-ups permission.
        PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION, PermissionRequester.BG_START_PERMISSION)
            .request()
    }
}