package com.tencent.qcloud.tuikit.tuicallkit.manager.bridge

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKitImpl
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.view.CallMainActivity

/**
 * `TUICallKit` uses `ContentProvider` to be registered with `TUICore`.
 * (`TUICore` is the connection and communication class of each component)
 */
class Initializer : ServiceInitializer() {
    override fun init(context: Context?) {
        val callingService: CallKitService = CallKitService.sharedInstance(context!!)
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
                        if (Constants.CALL_FRAMEWORK_NATIVE == Constants.framework &&
                            TUILogin.isUserLogined() && activity !is CallMainActivity) {
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
                        checkToShowFloatWindow()
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

    private fun checkToShowFloatWindow() {
        if (TUICallDefine.Status.None == CallManager.instance.userState.selfUser.get().callStatus.get()) {
            return
        }
        if (!PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()) {
            return
        }
        TUICore.notifyEvent(Constants.KEY_TUI_CALLKIT, Constants.SUB_KEY_SHOW_FLOAT_WINDOW, null)
    }
}