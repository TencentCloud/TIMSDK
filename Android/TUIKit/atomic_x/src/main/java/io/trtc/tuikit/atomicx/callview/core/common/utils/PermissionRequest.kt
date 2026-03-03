package io.trtc.tuikit.atomicx.callview.core.common.utils

import android.Manifest
import android.content.Context
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import io.trtc.tuikit.atomicx.R

object PermissionRequest {
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

        val title = context.getString(R.string.callview_permission_camera)
        val reason = getCameraPermissionHint(context)
        val appName = context.packageManager.getApplicationLabel(context.applicationInfo).toString()

        PermissionRequester.newInstance(Manifest.permission.CAMERA)
            .title(context.getString(R.string.callview_permission_title, appName, title))
            .description(reason)
            .settingsTip("${context.getString(R.string.callview_permission_tips, title)} $reason".trimIndent())
            .callback(permissionCallback)
            .request()
    }

    private fun getCameraPermissionHint(context: Context): String {
        val cameraPermissionsDescription = TUICore.createObject(
            TUIConstants.Privacy.PermissionsFactory.FACTORY_NAME,
            TUIConstants.Privacy.PermissionsFactory.PermissionsName.CAMERA_PERMISSIONS, null
        ) as String?
        return if (!cameraPermissionsDescription.isNullOrEmpty()) {
            cameraPermissionsDescription
        } else {
            context.getString(R.string.callview_permission_camera_reason)
        }
    }
}