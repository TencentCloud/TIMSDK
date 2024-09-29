package com.tencent.qcloud.tuikit.tuicallkit.internal

import android.app.Activity
import android.app.Application
import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKitImpl
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils
import com.tencent.qcloud.tuikit.tuicallkit.view.CallKitActivity
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview.FloatWindowService
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview.FloatingWindowGroupView
import com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow.FloatingWindowView

/**
 * `TUICallKit` uses `ContentProvider` to be registered with `TUICore`.
 * (`TUICore` is the connection and communication class of each component)
 */
class ServiceInitializer : ContentProvider() {
    fun init(context: Context?) {
        val callingService: TUICallKitService = TUICallKitService.sharedInstance(context!!)
        TUICore.registerService(TUIConstants.TUICalling.SERVICE_NAME, callingService)

        val audioRecordService = TUIAudioMessageRecordService(context)
        TUICore.registerService(TUIConstants.TUICalling.SERVICE_NAME_AUDIO_RECORD, audioRecordService)

        if (context is Application) {
            context.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
                private var foregroundActivities = 0
                private var isChangingConfiguration = false
                override fun onActivityCreated(activity: Activity, bundle: Bundle?) {}
                override fun onActivityStarted(activity: Activity) {
                    if (isMiPushActivity(activity)) {
                        return
                    }

                    foregroundActivities++
                    if (foregroundActivities == 1 && !isChangingConfiguration) {
                        //  The Call page exits the background and re-enters without repeatedly pulling up the page.
                        if (TUILogin.isUserLogined()
                            && activity !is CallKitActivity
                            && !DeviceUtils.isServiceRunning(context, FloatWindowService::class.java.name)
                        ) {
                            TUICallKitImpl.createInstance(context).queryOfflineCall()
                        }
                    }
                    isChangingConfiguration = false
                }

                override fun onActivityResumed(activity: Activity) {}
                override fun onActivityPaused(activity: Activity) {}
                override fun onActivityStopped(activity: Activity) {
                    if (isMiPushActivity(activity)) {
                        return
                    }
                    foregroundActivities--
                    isChangingConfiguration = activity.isChangingConfigurations

                    if (foregroundActivities == 0 && !isChangingConfiguration) {
                        checkToShowFloatWindow(context)
                    }
                }

                override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
                override fun onActivityDestroyed(activity: Activity) {}
            })
        }
    }

    private fun isMiPushActivity(activity: Activity): Boolean {
        try {
            val clazzName = activity.componentName.className
            return clazzName.contains("mipush.sdk")
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return false
    }

    private fun checkToShowFloatWindow(context: Context) {
        if (TUICallDefine.Status.None == TUICallState.instance.selfUser.get().callStatus.get()) {
            return
        }

        if (!PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()) {
            return
        }

        if (DeviceUtils.isServiceRunning(context, FloatWindowService::class.java.name)) {
            return
        }

        if (TUICallState.instance.scene.get() == TUICallDefine.Scene.GROUP_CALL) {
            FloatWindowService.startFloatService(FloatingWindowGroupView(context.applicationContext))
        } else {
            FloatWindowService.startFloatService(FloatingWindowView(context.applicationContext))
        }
        CallKitActivity.finishActivity()
    }

    override fun onCreate(): Boolean {
        val appContext = context!!.applicationContext
        init(appContext)
        return false
    }

    override fun query(
        uri: Uri, projection: Array<String>?, selection: String?,
        selectionArgs: Array<String>?, sortOrder: String?
    ): Cursor? {
        return null
    }

    override fun getType(uri: Uri): String? {
        return null
    }

    override fun insert(uri: Uri, values: ContentValues?): Uri? {
        return null
    }

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int {
        return 0
    }

    override fun update(
        uri: Uri, values: ContentValues?, selection: String?,
        selectionArgs: Array<String>?
    ): Int {
        return 0
    }
}