package com.tencent.qcloud.tuikit.tuicallkit.manager.hybird

import android.content.Context
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.liteav.base.ThreadUtils
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.interfaces.TUICallback
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.ViewState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatwindow.FloatWindowView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoFactory
import com.trtc.tuikit.common.permission.PermissionRequester
import com.trtc.tuikit.common.ui.floatwindow.FloatWindowManager
import com.trtc.tuikit.common.ui.floatwindow.FloatWindowObserver
import org.json.JSONObject

class CallBridge private constructor(context: Context) {
    private val context = context
    fun login(
        context: Context, sdkAppId: Int, userId: String, userSig: String, frameWork: Int, component: Int, language: Int,
        callback: TUICommonDefine.Callback?

    ) {
        runOnUiThread {
            Constants.framework = frameWork
            Constants.component = component
            Constants.language = language
            val params = JSONObject()
            params.put("framework", frameWork)
            params.put("component", component)
            params.put("language", language)

            val jsonObject = JSONObject()
            jsonObject.put("api", "setFramework")
            jsonObject.put("params", params)
            CallManager.instance.callExperimentalAPI(jsonObject.toString())

            TUILogin.login(context, sdkAppId, userId, userSig, object : TUICallback() {
                override fun onSuccess() {
                    Logger.i(TAG, "login success, sdkAppId: $sdkAppId, userId: $userId")
                    callback?.onSuccess()
                }

                override fun onError(errCode: Int, errMsg: String?) {
                    Logger.e(TAG, "login failed, errCode: $errCode, errMsg: $errMsg")
                    callback?.onError(errCode, errMsg)
                }
            })
        }
    }

    fun logout(callback: TUICommonDefine.Callback?) {
        runOnUiThread {
            TUILogin.logout(object : TUICallback() {
                override fun onSuccess() {
                    Logger.i(TAG, "logout success")
                    callback?.onSuccess()
                }

                override fun onError(errCode: Int, errMsg: String?) {
                    Logger.e(TAG, "logout failed, errCode: $errCode, errMsg: $errMsg")
                    callback?.onError(errCode, errMsg)
                }
            })
        }
    }

    fun calls(
        userIdList: List<String?>?, mediaType: TUICallDefine.MediaType?, params: TUICallDefine.CallParams?,
        callback: TUICommonDefine.Callback?
    ) {
        runOnUiThread {
            CallManager.instance.calls(userIdList, mediaType, params, callback)
        }
    }

    fun join(callId: String?, callback: TUICommonDefine.Callback?) {
        runOnUiThread {
            CallManager.instance.join(callId, callback)
        }
    }

    fun inviteUser(userIdList: List<String?>?, callback: TUICommonDefine.Callback?) {
        runOnUiThread {
            CallManager.instance.inviteUser(userIdList, callback)
        }
    }

    fun accept(callback: TUICommonDefine.Callback?) {
        runOnUiThread {
            CallManager.instance.accept(callback)
        }
    }

    fun reject(callback: TUICommonDefine.Callback?) {
        runOnUiThread {
            CallManager.instance.reject(callback)
        }
    }

    fun hangup(callback: TUICommonDefine.Callback?) {
        runOnUiThread {
            CallManager.instance.hangup(callback)
        }
    }

    fun openCamera(callback: TUICommonDefine.Callback?) {
        runOnUiThread {
            val selfUser = CallManager.instance.userState.selfUser.get()
            val videoView = VideoFactory.instance.createVideoView(context, selfUser)
            val camera = CallManager.instance.mediaState.isFrontCamera.get()
            CallManager.instance.openCamera(camera, videoView, callback)
        }
    }

    fun closeCamera() {
        runOnUiThread {
            CallManager.instance.closeCamera()
        }
    }

    fun switchCamera(camera: TUICommonDefine.Camera) {
        runOnUiThread {
            CallManager.instance.switchCamera(camera)
        }
    }

    fun openMicrophone(callback: TUICommonDefine.Callback?) {
        runOnUiThread {
            CallManager.instance.openMicrophone(callback)
        }
    }

    fun closeMicrophone() {
        runOnUiThread {
            CallManager.instance.closeMicrophone()
        }
    }

    fun selectAudioPlaybackDevice(device: TUICommonDefine.AudioPlaybackDevice) {
        runOnUiThread {
            CallManager.instance.selectAudioPlaybackDevice(device)
        }
    }

    fun enableMultiDeviceAbility(enable: Boolean, callback: TUICommonDefine.Callback?) {
        runOnUiThread {
            CallManager.instance.enableMultiDeviceAbility(enable, callback)
        }
    }

    fun setSelfInfo(nickname: String?, avatar: String?, callback: TUICommonDefine.Callback?) {
        runOnUiThread {
            CallManager.instance.setSelfInfo(nickname, avatar, callback)
        }
    }

    fun setCallingBell(filePath: String?) {
        runOnUiThread {
            CallManager.instance.setCallingBell(filePath)
        }
    }

    fun enableMuteMode(enable: Boolean) {
        runOnUiThread {
            CallManager.instance.enableMuteMode(enable)
        }
    }

    fun enableFloatWindow(enable: Boolean) {
        runOnUiThread {
            CallManager.instance.enableFloatWindow(enable)
        }
    }

    fun enableVirtualBackground(enable: Boolean) {
        runOnUiThread {
            CallManager.instance.enableVirtualBackground(enable)
        }
    }

    fun setScreenOrientation(orientation: Int) {
        runOnUiThread {
            CallManager.instance.setScreenOrientation(orientation)
        }
    }

    //TODO: only support 0-close 3-high
    fun setBlurBackground(level: Int) {
        runOnUiThread {
            CallManager.instance.setBlurBackground(level > 0)
        }
    }

    fun addFloatWindowObserver(observer: FloatWindowObserver) {
        runOnUiThread {
            Logger.i(TAG, "addFloatWindowObserver, observer: $observer")
            FloatWindowManager.sharedInstance().addObserver(observer)
        }
    }

    fun removeFloatWindowObserver(observer: FloatWindowObserver) {
        runOnUiThread {
            Logger.i(TAG, "removeFloatWindowObserver, observer: $observer")
            FloatWindowManager.sharedInstance().removeObserver(observer)
        }
    }

    fun startFloatWindow() {
        runOnUiThread {
            if (FloatWindowManager.sharedInstance().isShowing) {
                Logger.w(TAG, "There is already a floatWindow on display, do not open it again.")
                return@runOnUiThread
            }

            if (PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).has()) {
                CallManager.instance.viewState.router.set(ViewState.ViewRouter.FloatView)
                FloatWindowManager.sharedInstance().show(FloatWindowView(context.applicationContext))
            } else {
                PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION).request()
            }
        }
    }

    fun stopFloatWindow() {
        runOnUiThread {
            FloatWindowManager.sharedInstance().dismiss()
        }
    }

    fun callExperimentalAPI(jsonStr: String) {
        runOnUiThread {
            CallManager.instance.callExperimentalAPI(jsonStr)
        }
    }

    fun hasPermission(mediaType: TUICallDefine.MediaType?, callback: TUICommonDefine.Callback?) {
        runOnUiThread {
            if (mediaType == null) {
                callback?.onError(TUICommonDefine.Error.FAILED.value, "mediaType is null")
                return@runOnUiThread
            }
            PermissionRequest.requestPermissions(context, mediaType, object : PermissionCallback() {
                override fun onGranted() {
                    callback?.onSuccess()
                }

                override fun onDenied() {
                    callback?.onError(TUICommonDefine.Error.PERMISSION_DENIED.value, "Permission denied")
                }
            })
        }
    }

    private fun runOnUiThread(r: Runnable) {
        if (ThreadUtils.runningOnUiThread()) {
            r.run()
        } else {
            ThreadUtils.getUiThreadHandler().post(r)
        }
    }

    companion object {
        private const val TAG = "CallBridge"
        val instance: CallBridge = CallBridge(TUIConfig.getAppContext())
    }
}