package com.tencent.qcloud.tuikit.tuicallkit.state

import android.os.Handler
import android.os.HandlerThread
import android.text.TextUtils
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMUserFullInfo
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.permission.PermissionRequester
import com.tencent.qcloud.tuicore.util.SPUtils
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.TUICommonDefine.AudioPlaybackDevice
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallObserver
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingBellFeature
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallEngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallEvent.Companion.EVENT_KEY_USER_ID
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils

class TUICallState {
    public var selfUser = LiveData<User>()
    public var remoteUserList = LiveData<LinkedHashSet<User>>()

    public var scene = LiveData<TUICallDefine.Scene>()
    public var mediaType = LiveData<TUICallDefine.MediaType>()
    public var timeCount = LiveData<Int>()
    public var roomId = LiveData<TUICommonDefine.RoomId>()
    public var groupId = LiveData<String?>()
    public var event = LiveData<TUICallEvent>()

    public var isCameraOpen = LiveData<Boolean>()
    public var isFrontCamera = LiveData<TUICommonDefine.Camera>()
    public var isMicrophoneMute = LiveData<Boolean>()
    public var audioPlayoutDevice = LiveData<AudioPlaybackDevice>()

    public var enableMuteMode = false
    public var enableFloatWindow = false
    public var reverse1v1CallRenderView = false

    private var timeHandler: Handler? = null
    private var timeHandlerThread: HandlerThread? = null
    private var timeRunnable: Runnable? = null

    init {
        selfUser.set(User())
        remoteUserList.set(LinkedHashSet())
        scene.set(null)
        mediaType.set(TUICallDefine.MediaType.Unknown)
        timeCount.set(0)
        roomId.set(null)
        groupId.set(null)
        isCameraOpen.set(false)
        isFrontCamera.set(TUICommonDefine.Camera.Front)
        isMicrophoneMute.set(false)
        audioPlayoutDevice.set(AudioPlaybackDevice.Earpiece)
        enableMuteMode = SPUtils.getInstance(CallingBellFeature.PROFILE_TUICALLKIT)
            .getBoolean(CallingBellFeature.PROFILE_MUTE_MODE, false)
    }

    val mTUICallObserver: TUICallObserver = object : TUICallObserver() {
        override fun onError(code: Int, msg: String?) {
        }

        override fun onCallReceived(
            callerId: String?,
            calleeIdList: List<String?>?,
            group: String?,
            callMediaType: TUICallDefine.MediaType?
        ) {
            TUILog.i(
                TAG, "onCallReceived -> {callerId: $callerId, calleeIdList: $calleeIdList, group: $group,"
                        + "callMediaType: $callMediaType}"
            )
            if (TUICallDefine.MediaType.Unknown == callMediaType || calleeIdList.isNullOrEmpty()) {
                return
            }

            if (calleeIdList.size >= Constants.MAX_USER) {
                var callEvent = TUICallEvent(TUICallEvent.EventType.TIP, TUICallEvent.Event.USER_EXCEED_LIMIT, null)
                event.set(callEvent)
                return
            }

            TUICore.notifyEvent(Constants.EVENT_TUICALLKIT_CHANGED, Constants.EVENT_START_FEATURE, HashMap())

            groupId.set(group)
            mediaType.set(callMediaType)
            if (!TextUtils.isEmpty(group)) {
                scene.set(TUICallDefine.Scene.GROUP_CALL)
            } else if (calleeIdList.size > 1) {
                scene.set(TUICallDefine.Scene.MULTI_CALL)
            } else {
                scene.set(TUICallDefine.Scene.SINGLE_CALL)
            }

            if (!callerId.isNullOrEmpty()) {
                val user = User()
                user.id = callerId
                user.callRole.set(TUICallDefine.Role.Caller)
                user.callStatus.set(TUICallDefine.Status.Waiting)
                updateUserAvatarAndNickname(user)
                remoteUserList.add(user)
            }

            for (userId in calleeIdList) {
                if (!TextUtils.isEmpty(userId) && userId != TUILogin.getLoginUser()) {
                    val user = User()
                    user.id = userId
                    user.callRole.set(TUICallDefine.Role.Called)
                    user.callStatus.set(TUICallDefine.Status.Waiting)
                    updateUserAvatarAndNickname(user)
                    remoteUserList.add(user)
                }
            }

            selfUser.get().id = TUILogin.getUserId()
            selfUser.get().avatar.set(TUILogin.getFaceUrl())
            selfUser.get().nickname.set(TUILogin.getNickName())
            selfUser.get().callRole.set(TUICallDefine.Role.Called)
            selfUser.get().callStatus.set(TUICallDefine.Status.Waiting)

            val hasBgPermission = PermissionRequester.newInstance(PermissionRequester.BG_START_PERMISSION).has()
            val isAppInBackground: Boolean = !DeviceUtils.isAppRunningForeground(TUIConfig.getAppContext())

            if (isAppInBackground && !hasBgPermission) {
                TUILog.w(TAG, "App is in background")
                return
            }
            TUICore.notifyEvent(Constants.EVENT_TUICALLKIT_CHANGED, Constants.EVENT_START_ACTIVITY, HashMap())
        }

        override fun onCallCancelled(callerId: String?) {
            TUILog.i(TAG, "onCallCancelled -> {callerId: $callerId}")
            resetCall()
        }

        override fun onCallBegin(
            room: TUICommonDefine.RoomId?,
            callMediaType: TUICallDefine.MediaType?,
            callRole: TUICallDefine.Role?
        ) {
            TUILog.i(TAG, "onCallBegin -> {room: $room, callMediaType: $callMediaType, callRole: $callRole}")
            CallEngineManager.instance.selectAudioPlaybackDevice(instance.audioPlayoutDevice.get())
            roomId.set(room)
            selfUser.get().callStatus.set(TUICallDefine.Status.Accept)
            instance.reverse1v1CallRenderView = true
            if (isMicrophoneMute.get()) {
                CallEngineManager.instance.closeMicrophone()
            } else {
                CallEngineManager.instance.openMicrophone(null)
            }
            startTimeCount()
        }

        override fun onCallEnd(
            room: TUICommonDefine.RoomId?,
            callMediaType: TUICallDefine.MediaType?,
            callRole: TUICallDefine.Role?,
            totalTime: Long
        ) {
            TUILog.i(TAG, "onCallEnd -> {room: $room, callMediaType: $callMediaType, callRole: $callRole")
            roomId.set(room)
            resetCall()
        }

        override fun onCallMediaTypeChanged(
            oldCallMediaType: TUICallDefine.MediaType?,
            newCallMediaType: TUICallDefine.MediaType?
        ) {
            TUILog.i(
                TAG, "onCallMediaTypeChanged -> {oldCallMediaType: $oldCallMediaType"
                        + ", newCallMediaType: $newCallMediaType}"
            )
            if (oldCallMediaType != newCallMediaType) {
                mediaType.set(newCallMediaType)
                if (newCallMediaType == TUICallDefine.MediaType.Audio) {
                    if (TUICallDefine.Status.Accept == instance.selfUser.get().callStatus.get()) {
                        CallEngineManager.instance.selectAudioPlaybackDevice(AudioPlaybackDevice.Earpiece)
                    } else {
                        instance.audioPlayoutDevice.set(AudioPlaybackDevice.Earpiece)
                    }
                } else {
                    CallEngineManager.instance.selectAudioPlaybackDevice(AudioPlaybackDevice.Speakerphone)
                }
            }
        }

        override fun onUserReject(userId: String?) {
            TUILog.i(TAG, "onUserReject -> {userId: $userId}")
            if (userId.isNullOrEmpty()) {
                return
            }
            var param = HashMap<String, Any?>()
            param[EVENT_KEY_USER_ID] = userId
            var callEvent = TUICallEvent(TUICallEvent.EventType.TIP, TUICallEvent.Event.USER_REJECT, param)
            event.set(callEvent)
            removeUserOnLeave(userId)
            if (TUICallDefine.Scene.SINGLE_CALL == instance.scene.get()) {
                instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
            } else if (remoteUserList.get().isEmpty()) {
                instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
            }
        }

        override fun onUserNoResponse(userId: String?) {
            TUILog.i(TAG, "onUserNoResponse -> {userId: $userId}")
            if (userId.isNullOrEmpty()) {
                return
            }
            var param = HashMap<String, Any?>()
            param[EVENT_KEY_USER_ID] = userId
            var callEvent = TUICallEvent(TUICallEvent.EventType.TIP, TUICallEvent.Event.USER_NO_RESPONSE, param)
            event.set(callEvent)
            removeUserOnLeave(userId)
            if (TUICallDefine.Scene.SINGLE_CALL == instance.scene.get()) {
                instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
            } else if (remoteUserList.get().isEmpty()) {
                instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
            }
        }

        override fun onUserLineBusy(userId: String?) {
            TUILog.i(TAG, "onUserLineBusy -> {userId: $userId}")
            if (userId.isNullOrEmpty()) {
                return
            }
            var param = HashMap<String, Any?>()
            param[EVENT_KEY_USER_ID] = userId
            var callEvent = TUICallEvent(TUICallEvent.EventType.TIP, TUICallEvent.Event.USER_LINE_BUSY, param)
            event.set(callEvent)
            removeUserOnLeave(userId)
            if (TUICallDefine.Scene.SINGLE_CALL == instance.scene.get()) {
                instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
            } else if (remoteUserList.get().isEmpty()) {
                instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
            }
        }

        override fun onUserJoin(userId: String?) {
            TUILog.i(TAG, "onUserJoin -> {userId: $userId}")
            if (userId.isNullOrEmpty()) {
                return
            }
            updateUserOnEnter(userId)
        }

        override fun onUserLeave(userId: String?) {
            TUILog.i(TAG, "onUserLeave -> {userId: $userId}")
            if (userId.isNullOrEmpty()) {
                return
            }
            var param = HashMap<String, Any?>()
            param[EVENT_KEY_USER_ID] = userId
            var callEvent = TUICallEvent(TUICallEvent.EventType.TIP, TUICallEvent.Event.USER_LEAVE, param)
            event.set(callEvent)
            removeUserOnLeave(userId)
            if (TUICallDefine.Scene.SINGLE_CALL == instance.scene.get()) {
                instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
            } else if (remoteUserList.get().isEmpty()) {
                instance.selfUser.get().callStatus.set(TUICallDefine.Status.None)
            }
        }

        override fun onUserVideoAvailable(userId: String?, isVideoAvailable: Boolean) {
            TUILog.i(TAG, "onUserVideoAvailable -> {userId: $userId, isVideoAvailable: $isVideoAvailable}")
            if (userId.isNullOrEmpty()) {
                return
            }
            val user = findUser(userId)
            if (user != null && user.videoAvailable.get() != isVideoAvailable) {
                user.videoAvailable.set(isVideoAvailable)
            }
        }

        override fun onUserAudioAvailable(userId: String?, isAudioAvailable: Boolean) {
            TUILog.i(TAG, "onUserAudioAvailable -> {userId: $userId, isAudioAvailable: $isAudioAvailable}")
            if (userId.isNullOrEmpty()) {
                return
            }
            val user = findUser(userId)
            if (user != null && user.audioAvailable.get() != isAudioAvailable) {
                user.audioAvailable.set(isAudioAvailable)
            }
        }

        override fun onUserVoiceVolumeChanged(volumeMap: Map<String?, Int?>?) {
            if (TUICallDefine.Scene.SINGLE_CALL == scene.get() || volumeMap.isNullOrEmpty()) {
                return
            }
            for (entry in volumeMap.entries) {
                if (null != entry && !TextUtils.isEmpty(entry.key)) {
                    val user = findUser(entry.key)
                    if (user != null && user.playoutVolume.get() != entry.value) {
                        user.playoutVolume.set(entry.value)
                    }
                }
            }
        }

        override fun onUserNetworkQualityChanged(networkQualityList: List<TUICommonDefine.NetworkQualityInfo?>?) {

        }

        override fun onKickedOffline() {
            CallEngineManager.instance.hangup(null)
            resetCall()
        }

        override fun onUserSigExpired() {
            CallEngineManager.instance.hangup(null)
            resetCall()
        }
    }

    fun clear() {
        TUILog.i(TAG, "clear")
        reverse1v1CallRenderView = false
        selfUser.get().callStatus.set(TUICallDefine.Status.None)
        selfUser.get().clear()
        selfUser.set(User())
        remoteUserList.set(LinkedHashSet())
        scene.set(null)
        mediaType.set(TUICallDefine.MediaType.Unknown)
        timeCount.set(0)
        roomId.set(null)
        groupId.set(null)
        isCameraOpen.set(false)
        isFrontCamera.set(TUICommonDefine.Camera.Front)
        isMicrophoneMute.set(false)
        audioPlayoutDevice.set(AudioPlaybackDevice.Speakerphone)

        selfUser.removeAll()
        remoteUserList.removeAll()
        scene.removeAll()
        mediaType.removeAll()
        timeCount.removeAll()
        roomId.removeAll()
        groupId.removeAll()
        isCameraOpen.removeAll()
        isFrontCamera.removeAll()
        isMicrophoneMute.removeAll()
        audioPlayoutDevice.removeAll()
    }

    private fun resetCall() {
        stopTimeCount()
        clear()
    }

    private fun startTimeCount() {
        timeHandlerThread = HandlerThread("time-count-thread")
        timeHandlerThread?.start()
        timeHandler = Handler(timeHandlerThread!!.looper)

        if (timeRunnable != null) {
            return
        }
        timeCount.set(0)
        timeRunnable = Runnable {
            var count = timeCount.get() + 1
            timeCount.set(count)
            timeHandler?.postDelayed(timeRunnable!!, 1000)
        }
        timeHandler?.post(timeRunnable!!)
    }

    private fun stopTimeCount() {
        if (timeHandler != null) {
            timeHandler?.removeCallbacks(timeRunnable!!)
            timeHandler = null
        }
        timeRunnable = null
        timeCount.set(0)
        if (timeHandlerThread != null) {
            timeHandlerThread?.quitSafely()
            timeHandlerThread = null
        }
    }

    private fun findUser(userId: String?): User? {
        if (TextUtils.isEmpty(userId)) {
            return null
        }
        if (userId == selfUser.get().id) {
            return selfUser.get()
        } else {
            for (user in remoteUserList.get()) {
                if (null != user && !TextUtils.isEmpty(user.id) && userId == user.id) {
                    return user
                }
            }
        }
        return null
    }

    private fun removeUserOnLeave(userId: String) {
        val user = findUser(userId)
        if (user == null || TextUtils.isEmpty(user.id)) {
            return
        }
        user.callStatus.set(TUICallDefine.Status.None)
        user.videoAvailable.set(false)
        user.audioAvailable.set(false)
        if (selfUser != null && selfUser.get() != null && user.id == selfUser.get().id) {
            selfUser.get().callStatus.set(TUICallDefine.Status.None)
        }
        if (remoteUserList != null && remoteUserList.get() != null && remoteUserList.get().contains(user)) {
            remoteUserList.remove(user)
        }
    }

    private fun updateUserOnEnter(userId: String) {
        var user = findUser(userId)
        if (user == null) {
            user = User()
            user.id = userId
        }
        user.callStatus.set(TUICallDefine.Status.Accept)
        if (!remoteUserList.get().contains(user) && !userId.equals(selfUser.get().id)) {
            remoteUserList.add(user)
        }
        if (TextUtils.isEmpty(user.nickname.get()) || TextUtils.isEmpty(user.avatar.get())) {
            updateUserAvatarAndNickname(user)
        }
    }

    private fun updateUserAvatarAndNickname(user: User) {
        if (TextUtils.isEmpty(user.id)) {
            TUILog.e(TAG, "getUsersInfo -> user.userId isEmpty")
            return
        }
        if (!TextUtils.isEmpty(user.nickname.get()) && !TextUtils.isEmpty(user.avatar.get())) {
            TUILog.i(TAG, "getUsersInfo -> user.userName = ${user.nickname}, avatar = ${user.avatar}")
            return
        }
        val userList: MutableList<String> = ArrayList()
        userList.add(user.id!!)
        V2TIMManager.getInstance().getUsersInfo(userList, object : V2TIMValueCallback<List<V2TIMUserFullInfo?>?> {
            override fun onError(errorCode: Int, errorMsg: String?) {
                TUILog.e(TAG, "getUsersInfo -> userId:${user.id} onError errorCode = $errorCode , errorMsg = $errorMsg")
            }

            override fun onSuccess(list: List<V2TIMUserFullInfo?>?) {
                if (list.isNullOrEmpty() || null == list[0] || TextUtils.isEmpty(list[0]?.userID)) {
                    TUILog.i(TAG, "getUsersInfo -> userId:${user.id} onSuccess list = null")
                    return
                }
                TUILog.i(
                    TAG,
                    "getUsersInfo -> userId:${user.id} onSuccess nickname:${list[0]?.nickName}, avatar:${list[0]?.faceUrl}"
                )
                user.nickname.set(list[0]?.nickName)
                user.avatar.set(list[0]?.faceUrl)
            }
        })
    }

    companion object {
        const val TAG = "TUICallState"
        val instance: TUICallState = TUICallState()
    }
}