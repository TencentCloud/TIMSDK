package com.tencent.qcloud.tuikit.tuicallkit.utils

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import androidx.annotation.IntDef
import com.tencent.qcloud.tuicore.interfaces.TUICallback
import com.tencent.qcloud.tuicore.util.PermissionRequester
import com.tencent.qcloud.tuicore.util.PermissionRequester.PermissionDialogCallback
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallengine.utils.BrandUtils
import com.tencent.qcloud.tuikit.tuicallengine.utils.PermissionUtils
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallEngineManager
import com.tencent.qcloud.tuikit.tuicallkit.R

object PermissionRequest {
    const val PERMISSION_MICROPHONE = 1
    const val PERMISSION_CAMERA = 2

    private fun requestPermission(
        context: Context, @PermissionType type1: Int, @PermissionType type2: Int,
        callback: PermissionCallback?
    ) {
        requestPermission(context, type2, object : PermissionCallback() {
            override fun onGranted() {
                requestPermission(context, type1, object : PermissionCallback() {
                    override fun onGranted() {
                        callback?.onGranted()
                    }

                    override fun onDenied() {
                        callback?.onDenied()
                    }

                    override fun onDialogApproved() {
                        callback?.onDialogApproved()
                    }

                    override fun onDialogRefused() {
                        callback?.onDialogRefused()
                    }
                })
            }

            override fun onDenied() {
                callback?.onDenied()
            }

            override fun onDialogApproved() {
                callback?.onDialogApproved()
            }

            override fun onDialogRefused() {
                callback?.onDialogRefused()
            }
        })
    }

    fun requestPermission(context: Context, @PermissionType type: Int, callback: PermissionCallback?) {
        var permission: String? = null
        var reason: String? = null
        var reasonTitle: String? = null
        var deniedAlert: String? = null
        val applicationInfo = context.applicationInfo
        val appName = context.packageManager.getApplicationLabel(applicationInfo).toString()
        when (type) {
            PERMISSION_MICROPHONE -> {
                permission = PermissionRequester.PermissionConstants.MICROPHONE
                reasonTitle = context.getString(R.string.tuicalling_permission_mic_reason_title, appName)
                reason = context.getString(R.string.tuicalling_permission_mic_reason)
                deniedAlert = context.getString(R.string.tuicalling_tips_start_audio)
            }
            PERMISSION_CAMERA -> {
                permission = PermissionRequester.PermissionConstants.CAMERA
                reasonTitle = context.getString(R.string.tuicalling_permission_camera_reason_title, appName)
                reason = context.getString(R.string.tuicalling_permission_camera_reason)
                deniedAlert = context.getString(R.string.tuicalling_tips_start_camera)
            }
            else -> {}
        }
        val simpleCallback: PermissionRequester.SimpleCallback = object : PermissionRequester.SimpleCallback {
            override fun onGranted() {
                callback?.onGranted()
            }

            override fun onDenied() {
                callback?.onDenied()
            }
        }
        if (!TextUtils.isEmpty(permission)) {
            PermissionRequester.permission(permission)
                .reason(reason)
                .reasonTitle(reasonTitle)
                .deniedAlert(deniedAlert)
                .callback(simpleCallback)
                .permissionDialogCallback(object : PermissionDialogCallback {
                    override fun onApproved() {
                        callback?.onDialogApproved()
                    }

                    override fun onRefused() {
                        callback?.onDialogRefused()
                    }
                })
                .request()
        }
    }

    fun checkCallingPermission(mediaType: TUICallDefine.MediaType, callback: TUICallback?) {
        val permissionCallback: PermissionCallback = object : PermissionCallback() {
            override fun onGranted() {
                super.onGranted()
                callback?.onSuccess()
            }

            override fun onDialogRefused() {
                super.onDialogRefused()
                callback?.onError(TUICallDefine.ERROR_PERMISSION_DENIED, "permission denied")
            }
        }
        if (TUICallDefine.MediaType.Video == mediaType) {
            requestPermission(CallEngineManager.instance.context, PERMISSION_MICROPHONE, PERMISSION_CAMERA, permissionCallback)
        } else {
            requestPermission(CallEngineManager.instance.context, PERMISSION_MICROPHONE, permissionCallback)
        }
    }

    fun requestFloatPermission(context: Context) {
        if (PermissionUtils.hasPermission(context)) {
            return
        }
        if (BrandUtils.isBrandVivo()) {
            requestVivoFloatPermission(context)
        } else {
            startCommonSettings(context)
        }
    }

    private fun startCommonSettings(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            intent.data = Uri.parse("package:" + context.packageName)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
        }
    }

    private fun requestVivoFloatPermission(context: Context) {
        val vivoIntent = Intent()
        val model = BrandUtils.getModel()
        var isVivoY85 = false
        if (!TextUtils.isEmpty(model)) {
            isVivoY85 = model.contains("Y85") && !model.contains("Y85A")
        }
        if (!TextUtils.isEmpty(model) && (isVivoY85 || model.contains("vivo Y53L"))) {
            vivoIntent.setClassName(
                "com.vivo.permissionmanager",
                "com.vivo.permissionmanager.activity.PurviewTabActivity"
            )
            vivoIntent.putExtra("tabId", "1")
        } else {
            vivoIntent.setClassName(
                "com.vivo.permissionmanager",
                "com.vivo.permissionmanager.activity.SoftPermissionDetailActivity"
            )
            vivoIntent.action = "secure.intent.action.softPermissionDetail"
        }
        vivoIntent.putExtra("packagename", context.packageName)
        vivoIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(vivoIntent)
    }

    @IntDef(PERMISSION_MICROPHONE, PERMISSION_CAMERA)
    annotation class PermissionType
    abstract class PermissionCallback {
        open fun onGranted() {}
        open fun onDenied() {}
        open fun onDialogApproved() {}
        open fun onDialogRefused() {}
    }
}