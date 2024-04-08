package com.tencent.qcloud.tuikit.tuicallkit.manager

import android.content.Context
import android.text.TextUtils
import com.tencent.imsdk.BaseConstants
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter
import com.tencent.qcloud.tuicore.util.SPUtils
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.TUICommonDefine.ValueCallback
import com.tencent.qcloud.tuikit.TUIVideoView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.CallParams
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.data.OfflinePushInfoConfig
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingBellFeature
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest
import com.tencent.qcloud.tuikit.tuicallkit.utils.PermissionRequest.requestPermissions
import com.tencent.qcloud.tuikit.tuicallkit.utils.UserInfoUtils
import java.util.Collections

class EngineManager private constructor(context: Context) {

    public val context: Context

    init {
        this.context = context.applicationContext
    }

    companion object {
        const val TAG = "EngineManager"
        var instance: EngineManager = EngineManager(TUIConfig.getAppContext())
    }

    fun call(
        userId: String?, callMediaType: TUICallDefine.MediaType?, params: TUICallDefine.CallParams?,
        callback: TUICommonDefine.Callback?
    ) {
        TUILog.i(TAG, "call -> {userId: $userId, callMediaType: $callMediaType, params: $params}")
        if (TextUtils.isEmpty(userId)) {
            TUILog.e(TAG, "call failed, userId is empty")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "call failed, userId is empty")
            return
        }
        if (TUICallDefine.MediaType.Unknown == callMediaType) {
            TUILog.e(TAG, "call failed, callMediaType is Unknown")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "call failed, callMediaType is Unknown")
            return
        }
        TUICallState.instance.selfUser.get().avatar.set(TUILogin.getFaceUrl())
        TUICallState.instance.selfUser.get().nickname.set(TUILogin.getNickName())
        TUICallState.instance.selfUser.get().id = TUILogin.getLoginUser()
        requestPermissions(context, callMediaType!!, object : PermissionCallback() {
            override fun onGranted() {
                TUICallEngine.createInstance(context).call(userId, callMediaType, params,
                    object : TUICommonDefine.Callback {
                        override fun onSuccess() {
                            val user = User()
                            user.id = userId
                            user.callRole.set(TUICallDefine.Role.Called)
                            user.callStatus.set(TUICallDefine.Status.Waiting)
                            UserInfoUtils.updateUserInfo(user)
                            TUICallState.instance.remoteUserList.get()?.add(user)
                            TUICallState.instance.mediaType.set(callMediaType)
                            TUICallState.instance.scene.set(TUICallDefine.Scene.SINGLE_CALL)
                            TUICallState.instance.selfUser.get().callRole.set(TUICallDefine.Role.Caller)
                            TUICallState.instance.selfUser.get().callStatus.set(TUICallDefine.Status.Waiting)
                            callback?.onSuccess()
                        }

                        override fun onError(errCode: Int, errMsg: String) {
                            val errMessage: String = convertErrorMsg(errCode, errMsg)
                            ToastUtil.toastLongMessage(errMessage)
                            callback?.onError(errCode, errMessage)
                        }
                    })
            }

            override fun onDenied() {
                callback?.onError(TUICallDefine.ERROR_PERMISSION_DENIED, "request Permissions failed")
            }
        })
    }

    fun groupCall(
        groupId: String?, userIdList: List<String?>?, callMediaType: TUICallDefine.MediaType,
        params: TUICallDefine.CallParams?, callback: TUICommonDefine.Callback?
    ) {
        TUILog.i(
            TAG,
            "call -> {groupId: $groupId, userIdList: $userIdList, callMediaType: $callMediaType, params: $params}"
        )
        if (TextUtils.isEmpty(groupId)) {
            TUILog.e(TAG, "groupCall failed, groupId is empty")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "groupCall failed, groupId is empty")
            return
        }
        if (TUICallDefine.MediaType.Unknown == callMediaType) {
            TUILog.e(TAG, "groupCall failed, callMediaType is Unknown")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "groupCall failed, callMediaType is Unknown")
            return
        }

        val list = userIdList?.toHashSet()?.toMutableList()
        list?.remove(TUILogin.getLoginUser())
        list?.removeAll(Collections.singleton(null))

        if (list == null || list.isEmpty()) {
            TUILog.e(TAG, "groupCall failed, userIdList is empty")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "groupCall failed, userIdList is empty")
            return
        }
        if (list.size >= Constants.MAX_USER) {
            ToastUtil.toastLongMessage(context.getString(R.string.tuicallkit_user_exceed_limit))
            TUILog.e(TAG, "groupCall failed, exceeding max user number: 9")
            callback?.onError(TUICallDefine.ERROR_PARAM_INVALID, "groupCall failed, exceeding max user number")
            return
        }
        TUICallState.instance.selfUser.get().avatar.set(TUILogin.getFaceUrl())
        TUICallState.instance.selfUser.get().nickname.set(TUILogin.getNickName())
        TUICallState.instance.selfUser.get().id = TUILogin.getLoginUser()
        requestPermissions(context, callMediaType, object : PermissionCallback() {
            override fun onGranted() {
                TUICallEngine.createInstance(context).groupCall(
                    groupId, list, callMediaType,
                    params, object : TUICommonDefine.Callback {
                        override fun onSuccess() {
                            for (userId in list) {
                                if (!TextUtils.isEmpty(userId)) {
                                    val model = User()
                                    model.id = userId
                                    model.callRole.set(TUICallDefine.Role.Called)
                                    model.callStatus.set(TUICallDefine.Status.Waiting)
                                    UserInfoUtils.updateUserInfo(model)
                                    TUICallState.instance.remoteUserList.get().add(model)
                                }
                            }
                            TUICallState.instance.mediaType.set(callMediaType)
                            TUICallState.instance.scene.set(TUICallDefine.Scene.GROUP_CALL)
                            TUICallState.instance.groupId.set(groupId)

                            TUICallState.instance.selfUser.get().callRole.set(TUICallDefine.Role.Caller)
                            TUICallState.instance.selfUser.get().callStatus.set(TUICallDefine.Status.Waiting)
                            callback?.onSuccess()
                        }

                        override fun onError(errCode: Int, errMsg: String) {
                            val errMessage: String = convertErrorMsg(errCode, errMsg)
                            ToastUtil.toastLongMessage(errMessage)
                            TUILog.e(TAG, "groupCall errCode:$errCode, errMsg:$errMessage")
                            callback?.onError(errCode, errMessage)
                        }
                    })
            }

            override fun onDenied() {
                callback?.onError(TUICallDefine.ERROR_PERMISSION_DENIED, "request Permissions failed")
            }
        })
    }

    fun joinInGroupCall(roomId: TUICommonDefine.RoomId?, groupId: String?, mediaType: TUICallDefine.MediaType?) {
        val intRoomId = roomId?.intRoomId ?: 0
        val strRoomId = roomId?.strRoomId ?: ""
        if (intRoomId <= 0 && TextUtils.isEmpty(strRoomId)) {
            TUILog.e(TAG, "joinInGroupCall failed, roomId is invalid")
            return
        }
        if (TextUtils.isEmpty(groupId)) {
            TUILog.e(TAG, "joinInGroupCall failed, groupId is empty")
            return
        }
        if (TUICallDefine.MediaType.Unknown == mediaType) {
            TUILog.e(TAG, "joinInGroupCall failed, mediaType is unknown")
            return
        }
        TUICallState.instance.selfUser.get().avatar.set(TUILogin.getFaceUrl())
        TUICallState.instance.selfUser.get().nickname.set(TUILogin.getNickName())
        TUICallState.instance.selfUser.get().id = TUILogin.getLoginUser()
        requestPermissions(context, mediaType!!, object : PermissionCallback() {
            override fun onGranted() {
                TUICallEngine.createInstance(context).joinInGroupCall(roomId, groupId, mediaType,
                    object : TUICommonDefine.Callback {
                        override fun onSuccess() {
                            TUICallState.instance.groupId.set(groupId)
                            TUICallState.instance.roomId.set(roomId)
                            TUICallState.instance.mediaType.set(mediaType)
                            TUICallState.instance.scene.set(TUICallDefine.Scene.GROUP_CALL)
                            TUICallState.instance.selfUser.get().callRole.set(TUICallDefine.Role.Called)
                            TUICallState.instance.selfUser.get().callStatus.set(TUICallDefine.Status.Accept)

                            TUICore.notifyEvent(
                                Constants.EVENT_TUICALLKIT_CHANGED,
                                Constants.EVENT_START_ACTIVITY,
                                HashMap()
                            )
                        }

                        override fun onError(errCode: Int, errMsg: String) {
                            val errMessage = convertErrorMsg(errCode, errMsg)
                            ToastUtil.toastLongMessage(errMessage)
                        }
                    })
            }

            override fun onDenied() {
                TUILog.e(TAG, "requestPermissions failed")
            }
        })
    }

    fun accept(callback: TUICommonDefine.Callback?) {
        TUICallEngine.createInstance(context).accept(object : TUICommonDefine.Callback {
            override fun onSuccess() {
                if (TUICallState.instance.selfUser.get().callStatus.get() != TUICallDefine.Status.Accept) {
                    TUICallState.instance.selfUser.get().callStatus.set(TUICallDefine.Status.Accept)
                }
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String) {
                TUICallState.instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
                callback?.onError(errCode, errMsg)
            }
        })
    }

    fun reject(callback: TUICommonDefine.Callback?) {
        TUICallEngine.createInstance(context).reject(object : TUICommonDefine.Callback {
            override fun onSuccess() {
                TUICallState.instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String) {
                TUICallState.instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
                callback?.onError(errCode, errMsg)
            }
        })
    }

    fun hangup(callback: TUICommonDefine.Callback?) {
        TUICallEngine.createInstance(context).hangup(object : TUICommonDefine.Callback {
            override fun onSuccess() {
                TUICallState.instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String) {
                TUICallState.instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
                callback?.onError(errCode, errMsg)
            }
        })
    }

    fun openCamera(camera: TUICommonDefine.Camera?, videoView: TUIVideoView?, callback: TUICommonDefine.Callback?) {
        PermissionRequest.requestCameraPermission(context, object : PermissionCallback() {
            override fun onGranted() {

                TUICallEngine.createInstance(context).openCamera(camera, videoView, object : TUICommonDefine.Callback {
                    override fun onSuccess() {
                        val status: TUICallDefine.Status = TUICallState.instance.selfUser.get().callStatus.get()
                        if (TUICallDefine.Status.None != status) {
                            val camera: TUICommonDefine.Camera = TUICallState.instance.isFrontCamera.get()
                            TUICallState.instance.isCameraOpen.set(true)
                            TUICallState.instance.isFrontCamera.set(camera)
                            TUICallState.instance.selfUser.get().videoAvailable.set(true)
                        }
                        callback?.onSuccess()
                    }

                    override fun onError(errCode: Int, errMsg: String) {
                        callback?.onError(errCode, errMsg)
                    }
                })
            }

            override fun onDenied() {
                TUILog.w(TAG, "refused to access to the camera")
            }
        })
    }

    fun closeCamera() {
        TUICallEngine.createInstance(context).closeCamera()
        TUICallState.instance.isCameraOpen.set(false)
        TUICallState.instance.selfUser.get().videoAvailable.set(false)
    }

    fun switchCamera(camera: TUICommonDefine.Camera) {
        TUICallEngine.createInstance(context).switchCamera(camera)
        TUICallState.instance.isFrontCamera.set(camera)
    }

    fun openMicrophone(callback: TUICommonDefine.Callback?) {
        TUICallEngine.createInstance(context).openMicrophone(object : TUICommonDefine.Callback {
            override fun onSuccess() {
                val status: TUICallDefine.Status = TUICallState.instance.selfUser.get().callStatus.get()
                if (TUICallDefine.Status.None != status) {
                    TUICallState.instance.isMicrophoneMute.set(false)
                    TUICallState.instance.selfUser.get().audioAvailable.set(true)
                }
                callback?.onSuccess()
            }

            override fun onError(errCode: Int, errMsg: String) {
                callback?.onError(errCode, errMsg)
            }
        })
    }

    fun closeMicrophone() {
        TUICallEngine.createInstance(context).closeMicrophone()
        TUICallState.instance.isMicrophoneMute.set(true)
        TUICallState.instance.selfUser.get().audioAvailable.set(false)
    }

    fun selectAudioPlaybackDevice(device: TUICommonDefine.AudioPlaybackDevice?) {
        TUICallEngine.createInstance(context).selectAudioPlaybackDevice(device)
        TUICallState.instance.audioPlayoutDevice.set(device)
    }

    fun startRemoteView(userId: String?, videoView: TUIVideoView?, callback: TUICommonDefine.PlayCallback?) {
        TUICallEngine.createInstance(context).startRemoteView(userId, videoView, callback)
    }

    fun stopRemoteView(userId: String?) {
        TUICallEngine.createInstance(context).stopRemoteView(userId)
    }

    fun enableFloatWindow(enable: Boolean) {
        TUICallState.instance.enableFloatWindow = enable
    }

    fun enableMuteMode(enable: Boolean) {
        TUICallState.instance.enableMuteMode = enable
        SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT).put(CallingBellFeature.PROFILE_MUTE_MODE, enable)
    }

    fun inviteUser(userIdList: List<String?>?) {
        val params = CallParams()
        params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo(context)
        params.timeout = Constants.SIGNALING_MAX_TIME
        TUICallEngine.createInstance(context)
            .inviteUser(userIdList, params, object : TUICommonDefine.ValueCallback<Any?> {
                override fun onSuccess(data: Any?) {
                    if (data !is List<*>) {
                        return
                    }
                    val userList = data as List<String>
                    TUILog.i(TAG, "inviteUsersToGroupCall success, list:$userList")
                    UserInfoUtils.getUserListInfo(userList, object : ValueCallback<List<User>?> {
                        override fun onSuccess(data: List<User>?) {
                            if (data.isNullOrEmpty()) {
                                TUILog.e(TAG, "getUsersInfo onSuccess list = null")
                                return
                            }
                            for (info in data) {
                                info.callStatus.set(TUICallDefine.Status.Waiting)
                                TUICallState.instance.remoteUserList.add(info)
                            }
                        }

                        override fun onError(errCode: Int, errMsg: String?) {
                            TUILog.e(TAG, "getUsersInfo onError errorCode = $errCode , errorMsg = $errMsg")
                        }
                    })
                }

                override fun onError(errCode: Int, errMsg: String) {}
            })
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

    private fun convertErrorMsg(errorCode: Int, msg: String): String {
        if (errorCode == BaseConstants.ERR_SVR_MSG_IN_PEER_BLACKLIST) {
            return context.getString(R.string.tuicallkit_error_in_peer_blacklist)
        }

        val commonErrorMap = getCommonErrorMap()
        if (commonErrorMap.containsKey(errorCode)) {
            return commonErrorMap[errorCode]!!
        }

        return ErrorMessageConverter.convertIMError(errorCode, msg)
    }
}