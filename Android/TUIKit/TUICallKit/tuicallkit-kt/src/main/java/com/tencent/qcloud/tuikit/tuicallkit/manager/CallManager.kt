package com.tencent.qcloud.tuikit.tuicallkit.manager

import android.content.Context
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallEngine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.imsdk.BaseConstants
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.interfaces.ITUINotification
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter
import com.tencent.qcloud.tuicore.util.SPUtils
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.config.OfflinePushInfoConfig
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.common.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.manager.feature.CallingBellFeature
import com.tencent.qcloud.tuikit.tuicallkit.manager.feature.CallingVibratorFeature
import com.tencent.qcloud.tuikit.tuicallkit.manager.feature.NotificationFeature
import com.tencent.qcloud.tuikit.tuicallkit.manager.observer.CallEngineObserver
import com.tencent.qcloud.tuikit.tuicallkit.state.CallState
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.state.MediaState
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.tencent.qcloud.tuikit.tuicallkit.state.ViewState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoFactory
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoView
import com.tencent.trtc.TRTCCloud
import com.tencent.trtc.TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE
import com.tencent.trtc.TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER
import org.json.JSONObject
import java.util.Collections

class CallManager private constructor(context: Context) : ITUINotification {
    private val context: Context = context.applicationContext
    private val callEngineObserver: CallEngineObserver = CallEngineObserver()

    val callState: CallState = CallState()
    val mediaState: MediaState = MediaState()
    val viewState: ViewState = ViewState()
    val userState: UserState = UserState()

    init {
        registerCallEvent()
    }

    fun reset() {
        userState.reset()
        callState.reset()
        mediaState.reset()
        viewState.reset()
        VideoFactory.instance.clearVideoView()
    }

    fun call(
        userId: String, mediaType: TUICallDefine.MediaType, params: TUICallDefine.CallParams?,
        callback: TUICommonDefine.Callback?
    ) {
        Logger.i(TAG, "call, userId: $userId, mediaType: $mediaType, params: $params}")
        if (userId.isNullOrEmpty()) {
            Logger.e(TAG, "call failed, userId is empty")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "call failed, userId is empty")
            return
        }

        userState.selfUser.get().id = TUILogin.getLoginUser() ?: ""
        userState.selfUser.get().avatar.set(TUILogin.getFaceUrl())
        userState.selfUser.get().nickname.set(TUILogin.getNickName())

        TUICallEngine.createInstance(context).call(userId, mediaType, params, object : TUICommonDefine.Callback {
            override fun onSuccess() {
                val user = UserState.User()
                user.id = userId
                UserManager.instance.updateUserInfo(user)
                user.callRole = TUICallDefine.Role.Called
                user.callStatus.set(TUICallDefine.Status.Waiting)
                userState.remoteUserList.add(user)

                userState.selfUser.get().callRole = TUICallDefine.Role.Caller
                userState.selfUser.get().callStatus.set(TUICallDefine.Status.Waiting)
                callState.scene.set(TUICallDefine.Scene.SINGLE_CALL)
                callState.mediaType.set(mediaType)

                initCameraAndAudioDeviceState()
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String) {
                val errMessage: String = convertErrorMsg(errCode, errMsg)
                ToastUtil.toastLongMessage(errMessage)
                callback?.onError(errCode, errMessage)
            }
        })
    }

    fun groupCall(
        groupId: String?, userIdList: List<String?>?, mediaType: TUICallDefine.MediaType,
        params: TUICallDefine.CallParams?, callback: TUICommonDefine.Callback?
    ) {
        Logger.i(TAG, "groupCall, groupId: $groupId, userIdList: $userIdList, mediaType: $mediaType, params: $params")

        if (groupId.isNullOrEmpty()) {
            Logger.e(TAG, "groupCall failed, groupId is empty")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "groupCall failed, groupId is empty")
            return
        }

        val list = userIdList?.toHashSet()?.toMutableList()
        list?.remove(TUILogin.getLoginUser())
        list?.removeAll(Collections.singleton(null))

        if (list.isNullOrEmpty()) {
            Logger.e(TAG, "groupCall failed, userIdList is empty")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "groupCall failed, userIdList is empty")
            return
        }
        if (list.size >= Constants.MAX_USER) {
            ToastUtil.toastLongMessage(context.getString(R.string.tuicallkit_user_exceed_limit))
            Logger.e(TAG, "groupCall failed, exceeding max user number: 9")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "groupCall failed, exceeding max user number")
            return
        }
        userState.selfUser.get().id = TUILogin.getLoginUser() ?: ""
        userState.selfUser.get().avatar.set(TUILogin.getFaceUrl())
        userState.selfUser.get().nickname.set(TUILogin.getNickName())

        TUICallEngine.createInstance(context).groupCall(
            groupId, list, mediaType, params, object : TUICommonDefine.Callback {
                override fun onSuccess() {
                    val userList = ArrayList<UserState.User>()
                    for (userId in list) {
                        if (userId.isNullOrEmpty()) {
                            continue
                        }
                        val user = UserState.User()
                        user.id = userId
                        UserManager.instance.updateUserInfo(user)
                        user.callRole = TUICallDefine.Role.Called
                        user.callStatus.set(TUICallDefine.Status.Waiting)
                        userList.add(user)
                    }
                    userState.remoteUserList.addAll(userList)
                    UserManager.instance.updateUserListInfo(list, null)

                    userState.selfUser.get().callRole = TUICallDefine.Role.Caller
                    userState.selfUser.get().callStatus.set(TUICallDefine.Status.Waiting)

                    callState.scene.set(TUICallDefine.Scene.GROUP_CALL)
                    callState.chatGroupId = groupId
                    callState.mediaType.set(mediaType)

                    initCameraAndAudioDeviceState()
                    callback?.onSuccess()
                }

                override fun onError(errCode: Int, errMsg: String) {
                    val errMessage: String = convertErrorMsg(errCode, errMsg)
                    ToastUtil.toastLongMessage(errMessage)
                    callback?.onError(errCode, errMessage)
                }
            })
    }

    fun calls(
        userIdList: List<String?>?, mediaType: TUICallDefine.MediaType?, params: TUICallDefine.CallParams?,
        callback: TUICommonDefine.Callback?
    ) {
        Logger.i(TAG, "calls, userIdList: $userIdList, mediaType: $mediaType, params: $params")
        val list = userIdList?.toHashSet()?.toMutableList()
        list?.remove(TUILogin.getLoginUser())
        list?.removeAll(Collections.singleton(null))

        if (list.isNullOrEmpty()) {
            Logger.e(TAG, "calls failed, userIdList is empty")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "calls failed, userIdList is empty")
            return
        }
        if (list.size >= Constants.MAX_USER) {
            ToastUtil.toastLongMessage(context.getString(R.string.tuicallkit_user_exceed_limit))
            Logger.e(TAG, "calls failed, exceeding max user number: 9")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "calls failed, exceeding max user number")
            return
        }

        userState.selfUser.get().id = TUILogin.getLoginUser() ?: ""
        userState.selfUser.get().avatar.set(TUILogin.getFaceUrl())
        userState.selfUser.get().nickname.set(TUILogin.getNickName())
        callState.chatGroupId = params?.chatGroupId

        TUICallEngine.createInstance(context).calls(list, mediaType, params, object : TUICommonDefine.Callback {
            override fun onSuccess() {
                Logger.i(TAG, "calls success. list: $list")
                if (userState.remoteUserList.get().isNullOrEmpty()) {
                    val userList = ArrayList<UserState.User>()
                    for (userId in list) {
                        if (userId.isNullOrEmpty()) {
                            continue
                        }
                        val user = UserState.User()
                        user.id = userId
                        UserManager.instance.updateUserInfo(user)
                        user.callRole = TUICallDefine.Role.Called
                        user.callStatus.set(TUICallDefine.Status.Waiting)
                        userList.add(user)
                    }
                    userState.remoteUserList.addAll(userList)
                }
                UserManager.instance.updateUserListInfo(list, null)

                userState.selfUser.get().callRole = TUICallDefine.Role.Caller
                if (userState.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
                    userState.selfUser.get().callStatus.set(TUICallDefine.Status.Waiting)
                }

                if (callState.scene.get() == TUICallDefine.Scene.NONE) {
                    var scene = TUICallDefine.Scene.SINGLE_CALL
                    if (params != null && !params.chatGroupId.isNullOrEmpty()) {
                        scene = TUICallDefine.Scene.GROUP_CALL
                    } else if (list.size >= 2) {
                        scene = TUICallDefine.Scene.MULTI_CALL
                    }
                    callState.scene.set(scene)
                }
                callState.chatGroupId = params?.chatGroupId
                callState.mediaType.set(mediaType)
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String) {
                Logger.e(TAG, "calls failed, errCode: $errCode, errMsg: $errMsg")
                val errMessage: String = convertErrorMsg(errCode, errMsg)
                ToastUtil.toastLongMessage(errMessage)
                callback?.onError(errCode, errMessage)
            }
        })
    }

    fun join(callId: String?, callback: TUICommonDefine.Callback?) {
        Logger.i(TAG, "join, callId: $callId")
        if (callId.isNullOrEmpty()) {
            Logger.e(TAG, "join failed, callId is empty")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "join failed, callId is empty")
            return
        }

        userState.selfUser.get().id = TUILogin.getLoginUser() ?: ""
        userState.selfUser.get().avatar.set(TUILogin.getFaceUrl())
        userState.selfUser.get().nickname.set(TUILogin.getNickName())

        TUICallEngine.createInstance(context).join(callId, object : TUICommonDefine.Callback {
            override fun onSuccess() {
                userState.selfUser.get().callRole = TUICallDefine.Role.Called
                callState.mediaType.set(TUICallDefine.MediaType.Audio)

                if (callState.scene.get() == TUICallDefine.Scene.NONE) {
                    callState.scene.set(TUICallDefine.Scene.MULTI_CALL)
                }
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String) {
                Logger.e(TAG, "join failed callId: $callId, errCode: $errCode, errMsg: $errMsg")
                ToastUtil.toastLongMessage(convertErrorMsg(errCode, errMsg))
                callback?.onError(errCode, errMsg)
            }
        })
    }

    fun joinInGroupCall(
        roomId: TUICommonDefine.RoomId?, groupId: String?, mediaType: TUICallDefine.MediaType?,
        callback: TUICommonDefine.Callback?
    ) {
        Logger.i(TAG, "joinInGroupCall, roomId: $roomId, groupId: $groupId, mediaType: $mediaType")

        val intRoomId = roomId?.intRoomId ?: 0
        val strRoomId = roomId?.strRoomId ?: ""
        if (intRoomId <= 0 && strRoomId.isNullOrEmpty()) {
            Logger.e(TAG, "joinInGroupCall failed, roomId is invalid")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "joinInGroupCall failed, roomId is invalid")
            return
        }
        if (groupId.isNullOrEmpty()) {
            Logger.e(TAG, "joinInGroupCall failed, groupId is empty")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "joinInGroupCall failed, groupId is invalid")
            return
        }
        if (TUICallDefine.MediaType.Unknown == mediaType) {
            Logger.e(TAG, "joinInGroupCall failed, mediaType is unknown")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "joinInGroupCall failed, mediaType is unknown")
            return
        }
        userState.selfUser.get().id = TUILogin.getLoginUser() ?: ""
        userState.selfUser.get().avatar.set(TUILogin.getFaceUrl())
        userState.selfUser.get().nickname.set(TUILogin.getNickName())

        TUICallEngine.createInstance(context).joinInGroupCall(roomId, groupId, mediaType,
            object : TUICommonDefine.Callback {
                override fun onSuccess() {
                    userState.selfUser.get().callRole = TUICallDefine.Role.Called
                    userState.selfUser.get().callStatus.set(TUICallDefine.Status.Accept)

                    callState.scene.set(TUICallDefine.Scene.GROUP_CALL)
                    callState.chatGroupId = groupId
                    callState.roomId = roomId
                    callState.mediaType.set(mediaType)

                    initCameraAndAudioDeviceState()
                    callback?.onSuccess()
                }

                override fun onError(errCode: Int, errMsg: String) {
                    ToastUtil.toastLongMessage(convertErrorMsg(errCode, errMsg))
                    callback?.onError(errCode, errMsg)
                }
            })
    }

    fun inviteUser(userIdList: List<String?>?, callback: TUICommonDefine.Callback?) {
        Logger.i(TAG, "inviteUser, userIdList: $userIdList")
        val params = TUICallDefine.CallParams()
        params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(context)
        params.timeout = Constants.CALL_WAITING_MAX_TIME
        TUICallEngine.createInstance(context)
            .inviteUser(userIdList, params, object : TUICommonDefine.ValueCallback<List<String>> {
                override fun onSuccess(data: List<String>?) {
                    if (data.isNullOrEmpty()) {
                        Logger.e(TAG, "inviteUser failed, list: $data")
                        callback?.onError(TUICommonDefine.Error.FAILED.value, "inviteUser failed, userList is empty")
                        return
                    }
                    Logger.i(TAG, "inviteUser success, userList: $data")
                    callState.scene.set(TUICallDefine.Scene.GROUP_CALL)
                    callback?.onSuccess()
                }

                override fun onError(errCode: Int, errMsg: String) {
                    Logger.e(TAG, "inviteUser failed, errCode: $errCode, errMsg: $errMsg")
                    callback?.onError(errCode, errMsg)
                }
            })
    }

    fun accept(callback: TUICommonDefine.Callback?) {
        Logger.i(TAG, "accept")
        TUICallEngine.createInstance(context).accept(object : TUICommonDefine.Callback {
            override fun onSuccess() {
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String) {
                Logger.e(TAG, "accept failed, errorCode: $errCode, errMsg: $errMsg ")
                reset()
                callback?.onError(errCode, errMsg)
            }
        })
    }

    fun reject(callback: TUICommonDefine.Callback?) {
        Logger.i(TAG, "reject")
        TUICallEngine.createInstance(context).reject(object : TUICommonDefine.Callback {
            override fun onSuccess() {
                reset()
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String) {
                Logger.e(TAG, "reject failed, errorCode: $errCode, errMsg: $errMsg ")
                reset()
                callback?.onError(errCode, errMsg)
            }
        })
    }

    fun hangup(callback: TUICommonDefine.Callback?) {
        Logger.i(TAG, "hangup")
        TUICallEngine.createInstance(context).hangup(object : TUICommonDefine.Callback {
            override fun onSuccess() {
                reset()
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String) {
                Logger.e(TAG, "hangup failed, errorCode: $errCode, errMsg: $errMsg ")
                reset()
                callback?.onError(errCode, errMsg)
            }
        })
    }

    fun openCamera(camera: TUICommonDefine.Camera, videoView: VideoView?, callback: TUICommonDefine.Callback?) {
        Logger.i(TAG, "openCamera, camera: $camera, videoView: $videoView")
        PermissionRequest.requestCameraPermission(context, object : PermissionCallback() {
            override fun onGranted() {
                TUICallEngine.createInstance(context)
                    .openCamera(camera, videoView?.getVideoView(), object : TUICommonDefine.Callback {
                        override fun onSuccess() {
                            val status: TUICallDefine.Status = userState.selfUser.get().callStatus.get()
                            Logger.i(TAG, "openCamera success, current callStatus: $status")
                            if (TUICallDefine.Status.None != status) {
                                userState.selfUser.get().videoAvailable.set(true)
                                mediaState.isCameraOpened.set(true)
                                mediaState.isFrontCamera.set(camera)
                            }
                            callback?.onSuccess()
                        }

                        override fun onError(errCode: Int, errMsg: String) {
                            Logger.e(TAG, "openCamera failed, errorCode: $errCode, errMsg: $errMsg")
                            callback?.onError(errCode, errMsg)
                        }
                    })
            }

            override fun onDenied() {
                super.onDenied()
                Logger.e(TAG, "openCamera failed, errMsg: camera permission denied")
                callback?.onError(TUICallDefine.ERROR_PERMISSION_DENIED, "camera permission denied")
            }
        })
    }

    fun closeCamera() {
        Logger.i(TAG, "closeCamera")
        TUICallEngine.createInstance(context).closeCamera()
        userState.selfUser.get().videoAvailable.set(false)
        mediaState.isCameraOpened.set(false)
    }

    fun switchCamera(camera: TUICommonDefine.Camera) {
        Logger.i(TAG, "switchCamera, camera: $camera")
        TUICallEngine.createInstance(context).switchCamera(camera)
        mediaState.isFrontCamera.set(camera)
    }

    fun openMicrophone(callback: TUICommonDefine.Callback?) {
        TUICallEngine.createInstance(context).openMicrophone(object : TUICommonDefine.Callback {
            override fun onSuccess() {
                Logger.i(TAG, "openMicrophone success")
                mediaState.isMicrophoneMuted.set(false)
                userState.selfUser.get().audioAvailable.set(true)
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String) {
                Logger.e(TAG, "openMicrophone failed, errCode: $errCode, errorMsg: $errMsg")
                callback?.onError(errCode, errMsg)
            }
        })
    }

    fun closeMicrophone() {
        TUICallEngine.createInstance(context).closeMicrophone()
        mediaState.isMicrophoneMuted.set(true)
        userState.selfUser.get().audioAvailable.set(false)
    }

    fun selectAudioPlaybackDevice(device: TUICommonDefine.AudioPlaybackDevice) {
        TUICallEngine.createInstance(context).selectAudioPlaybackDevice(device)
        mediaState.audioPlayoutDevice.set(device)
        val currentAudioRoute = if (device == TUICommonDefine.AudioPlaybackDevice.Speakerphone) TRTC_AUDIO_ROUTE_SPEAKER else TRTC_AUDIO_ROUTE_EARPIECE
        mediaState.selectedAudioDevice.set(currentAudioRoute)
    }

    fun startRemoteView(userId: String, videoView: VideoView?, callback: TUICommonDefine.PlayCallback?) {
        Logger.i(TAG, "startRemoteView, userId: $userId, videoView: $videoView")
        TUICallEngine.createInstance(context).startRemoteView(userId, videoView?.getVideoView(), callback)
    }

    fun stopRemoteView(userId: String) {
        TUICallEngine.createInstance(context).stopRemoteView(userId)
    }

    fun enableMultiDeviceAbility(enable: Boolean, callback: TUICommonDefine.Callback?) {
        Logger.i(TAG, "enableMultiDeviceAbility, enable: $enable")
        TUICallEngine.createInstance(context).enableMultiDeviceAbility(enable, callback)
    }

    fun setSelfInfo(nickname: String?, avatar: String?, callback: TUICommonDefine.Callback?) {
        Logger.i(TAG, "setSelfInfo, nickname: $nickname, avatar: $avatar")
        TUICallEngine.createInstance(context).setSelfInfo(nickname, avatar, callback)
    }

    fun setCallingBell(filePath: String?) {
        Logger.i(TAG, "setCallingBell, filePath: $filePath")
        SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT).put(CallingBellFeature.PROFILE_CALL_BELL, filePath)
    }

    fun enableMuteMode(enable: Boolean) {
        Logger.i(TAG, "enableMuteMode, enable: $enable")
        GlobalState.instance.enableMuteMode = enable
        SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT).put(CallingBellFeature.PROFILE_MUTE_MODE, enable)
    }

    fun enableFloatWindow(enable: Boolean) {
        Logger.i(TAG, "enableFloatWindow, enable: $enable")
        GlobalState.instance.enableFloatWindow = enable
    }

    fun enableVirtualBackground(enable: Boolean) {
        Logger.i(TAG, "enableVirtualBackground, enable: $enable")
        GlobalState.instance.enableVirtualBackground = enable
    }

    fun enableIncomingBanner(enable: Boolean) {
        Logger.i(TAG, "enableIncomingBanner, enable: $enable")
        GlobalState.instance.enableIncomingBanner = enable
    }

    fun setScreenOrientation(orientation: Int) {
        Logger.i(TAG, "setScreenOrientation, orientation: $orientation")
        if (orientation in 0..2) {
            GlobalState.instance.orientation = Constants.Orientation.values()[orientation]
        }

        if (orientation == Constants.Orientation.LandScape.ordinal) {
            val videoEncoderParams = TUICommonDefine.VideoEncoderParams()
            videoEncoderParams.resolutionMode = TUICommonDefine.VideoEncoderParams.ResolutionMode.Landscape
            TUICallEngine.createInstance(context).setVideoEncoderParams(videoEncoderParams, null)
        }
    }

    fun setBlurBackground(enable: Boolean) {
        Logger.i(TAG, "setBlurBackground, enable: $enable")
        val level = if (enable) BLUR_LEVEL_HIGH else BLUR_LEVEL_CLOSE
        viewState.isVirtualBackgroundOpened.set(enable)

        TUICallEngine.createInstance(context).setBlurBackground(level, object : TUICommonDefine.Callback {
            override fun onSuccess() {
                Logger.i(TAG, "setBlurBackground success.")
            }

            override fun onError(errCode: Int, errMsg: String?) {
                viewState.isVirtualBackgroundOpened.set(false)
                Logger.e(TAG, "setBlurBackground failed, errCode: $errCode, errMsg: $errMsg")
            }
        })
    }

    fun disableControlButton(button: Constants.ControlButton?) {
        Logger.i(TAG, "disableControlButton, button: $button")
        button?.let { GlobalState.instance.disableControlButtonSet.add(it) }
    }

    fun reverse1v1CallRenderView(reverse: Boolean) {
        viewState.reverse1v1CallRenderView = reverse
    }

    fun setGroupLargeViewUserId(userId: String?) {
        viewState.showLargeViewUserId.set(userId)
    }

    fun getTRTCCloudInstance(): TRTCCloud {
        return TUICallEngine.createInstance(context).trtcCloudInstance
    }

    fun callExperimentalAPI(jsonStr: String) {
        if (jsonStr.isNullOrEmpty()) {
            Logger.w(TAG, "callExperimentalAPI, jsonStr is empty");
            return
        }
        try {
            val json = JSONObject(jsonStr)
            if (!json.has("api") || !json.has("params")) {
                Logger.e(TAG, "callExperimentalAPI[lack api or illegal params]: $jsonStr")
                return
            }
            val api = json.getString("api")
            val params = json.getJSONObject("params")
            Logger.i(TAG, "callExperimentalAPI, api: $api, params: $params")
            if (api == "forceUseV2API") {
                if (params.has("enable")) {
                    GlobalState.instance.enableForceUseV2API = params.getBoolean("enable")
                }
            }
            if (api == "setFramework") {
                if (params.has("framework")) {
                    Constants.framework = params.getInt("framework")
                }
                if (params.has("component")) {
                    Constants.component = params.getInt("component")
                }
                if (params.has("language")) {
                    Constants.language = params.getInt("language")
                }
                val params = JSONObject()
                params.put("framework", Constants.framework)
                params.put("component", Constants.component)
                params.put("language", Constants.language)

                val jsonObject = JSONObject()
                jsonObject.put("api", "setFramework")
                jsonObject.put("params", params)
                TUICallEngine.createInstance(context).callExperimentalAPI(jsonObject.toString())
            }
        } catch (e: Exception) {
            Logger.e(TAG, "callExperimentalAPI json parse fail，json: $jsonStr, error: $e")
        }
    }

    private fun registerCallEvent() {
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this
        )
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS, this
        )
    }

    override fun onNotifyEvent(key: String?, subKey: String?, param: MutableMap<String, Any>?) {
        if (TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED == key) {
            if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGOUT_SUCCESS == subKey) {
                TUICallEngine.createInstance(context).hangup(null)
                TUICallEngine.destroyInstance()
                reset()
            } else if (TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS == subKey) {
                TUICallEngine.createInstance(context).addObserver(callEngineObserver)
                initCallEngine()
            }
        }
    }

    private fun initCallEngine() {
        TUICallEngine.createInstance(context).init(TUILogin.getSdkAppId(), TUILogin.getLoginUser(),
            TUILogin.getUserSig(), object : TUICommonDefine.Callback {
                override fun onSuccess() {
                    TUICallEngine.createInstance(context).addObserver(callEngineObserver)

                    if (GlobalState.instance.enableMultiDevice) {
                        TUICallEngine.createInstance(context).enableMultiDeviceAbility(true, null)
                    }

                    val notificationFeature = NotificationFeature(context)
                    notificationFeature.registerNotificationBannerChannel()
                    CallingBellFeature(context)
                    CallingVibratorFeature(context)
                }

                override fun onError(errCode: Int, errMsg: String) {
                    Logger.e(TAG, "callEngine init failed, errCode: $errCode, errMsg: $errMsg")
                }
            })
    }

    private fun initCameraAndAudioDeviceState() {
        if (TUICallDefine.MediaType.Video == callState.mediaType.get()) {
            selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Speakerphone)
            mediaState.isCameraOpened.set(true)
        } else {
            selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Earpiece)
            mediaState.isCameraOpened.set(false)
        }
        mediaState.isMicrophoneMuted.set(false)
        userState.selfUser.get().audioAvailable.set(true)
    }

    private fun convertErrorMsg(errorCode: Int, errMsg: String): String {
        if (errorCode == BaseConstants.ERR_SVR_MSG_IN_PEER_BLACKLIST) {
            return context.getString(R.string.tuicallkit_error_in_peer_blacklist)
        }

        val commonErrorMap = getCommonErrorMap()
        if (commonErrorMap.containsKey(errorCode)) {
            return commonErrorMap[errorCode]!!
        }
        return ErrorMessageConverter.convertIMError(errorCode, errMsg)
    }

    private fun getCommonErrorMap(): Map<Int, String> {
        val map = HashMap<Int, String>()
        map[TUICallDefine.ERROR_PACKAGE_NOT_PURCHASED] = context.getString(R.string.tuicallkit_package_not_purchased)
        map[TUICallDefine.ERROR_PACKAGE_NOT_SUPPORTED] = context.getString(R.string.tuicallkit_package_not_support)
        map[TUICallDefine.ERROR_INIT_FAIL] = context.getString(R.string.tuicallkit_error_invalid_login)
        map[TUICallDefine.ERROR_PARAM_INVALID] = context.getString(R.string.tuicallkit_error_parameter_invalid)
        map[TUICallDefine.ERROR_REQUEST_REFUSED] = context.getString(R.string.tuicallkit_error_request_refused)
        map[TUICallDefine.ERROR_REQUEST_REPEATED] = context.getString(R.string.tuicallkit_error_request_repeated)
        map[TUICallDefine.ERROR_SCENE_NOT_SUPPORTED] = context.getString(R.string.tuicallkit_error_scene_not_support)
        return map
    }

    companion object {
        private const val TAG = "CallManager"
        val instance: CallManager = CallManager(TUIConfig.getAppContext())
        private const val BLUR_LEVEL_HIGH = 3
        private const val BLUR_LEVEL_CLOSE = 0
    }
}