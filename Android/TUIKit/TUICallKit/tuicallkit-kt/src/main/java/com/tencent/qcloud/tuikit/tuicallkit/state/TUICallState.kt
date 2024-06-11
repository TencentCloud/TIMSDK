package com.tencent.qcloud.tuikit.tuicallkit.state

import android.os.Handler
import android.os.HandlerThread
import android.text.TextUtils
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.SPUtils
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.TUICommonDefine.AudioPlaybackDevice
import com.tencent.qcloud.tuikit.TUICommonDefine.NetworkQuality
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallObserver
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.extensions.CallingBellFeature
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.utils.UserInfoUtils

class TUICallState {
    public var selfUser = LiveData<User>()
    public var remoteUserList = LiveData<LinkedHashSet<User>>()

    public var scene = LiveData<TUICallDefine.Scene>()
    public var mediaType = LiveData<TUICallDefine.MediaType>()
    public var timeCount = LiveData<Int>()
    public var roomId = LiveData<TUICommonDefine.RoomId>()
    public var groupId = LiveData<String?>()

    public var isCameraOpen = LiveData<Boolean>()
    public var isFrontCamera = LiveData<TUICommonDefine.Camera>()
    public var isMicrophoneMute = LiveData<Boolean>()
    public var audioPlayoutDevice = LiveData<AudioPlaybackDevice>()

    public var enableMuteMode = false
    public var enableFloatWindow = false
    public var enableIncomingBanner = false
    public var showVirtualBackgroundButton = false
    public var enableBlurBackground = LiveData<Boolean>()
    public var reverse1v1CallRenderView = false
    public var isShowFullScreen = LiveData<Boolean>()
    public var isBottomViewExpand = LiveData<Boolean>()
    public var showLargeViewUserId = LiveData<String>()
    public var networkQualityReminder = LiveData<Constants.NetworkQualityHint>()

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
        isShowFullScreen.set(false)
        isBottomViewExpand.set(true)
        showLargeViewUserId.set(null)
        enableBlurBackground.set(false)
        networkQualityReminder.set(Constants.NetworkQualityHint.None)
    }

    val mTUICallObserver: TUICallObserver = object : TUICallObserver() {
        override fun onError(code: Int, msg: String?) {
        }

        override fun onCallReceived(
            callerId: String?, calleeIdList: List<String?>?, group: String?,
            callMediaType: TUICallDefine.MediaType?, userData: String?
        ) {
            TUILog.i(
                TAG, "onCallReceived -> {callerId: $callerId, calleeIdList: $calleeIdList, group: $group,"
                        + "callMediaType: $callMediaType}"
            )
            if (TUICallDefine.MediaType.Unknown == callMediaType || calleeIdList.isNullOrEmpty()) {
                return
            }

            if (calleeIdList.size >= Constants.MAX_USER) {
                ToastUtil.toastLongMessage(TUILogin.getAppContext().getString(R.string.tuicallkit_user_exceed_limit))
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
                UserInfoUtils.updateUserInfo(user)
                remoteUserList.add(user)
            }

            for (userId in calleeIdList) {
                if (!TextUtils.isEmpty(userId) && userId != TUILogin.getLoginUser()) {
                    val user = User()
                    user.id = userId
                    user.callRole.set(TUICallDefine.Role.Called)
                    user.callStatus.set(TUICallDefine.Status.Waiting)
                    UserInfoUtils.updateUserInfo(user)
                    remoteUserList.add(user)
                }
            }

            selfUser.get().id = TUILogin.getUserId()
            selfUser.get().avatar.set(TUILogin.getFaceUrl())
            selfUser.get().nickname.set(TUILogin.getNickName())
            selfUser.get().callRole.set(TUICallDefine.Role.Called)
            selfUser.get().callStatus.set(TUICallDefine.Status.Waiting)

            TUICore.notifyEvent(Constants.EVENT_TUICALLKIT_CHANGED, Constants.EVENT_SHOW_INCOMING_VIEW, HashMap())
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
            if (TUICallDefine.Role.Called == instance.selfUser.get().callRole.get()
                && TUICallDefine.MediaType.Audio == instance.mediaType.get()
                && TUICallDefine.Scene.SINGLE_CALL == instance.scene.get()
            ) {
                EngineManager.instance.selectAudioPlaybackDevice(AudioPlaybackDevice.Earpiece)
            } else {
                EngineManager.instance.selectAudioPlaybackDevice(instance.audioPlayoutDevice.get())
            }
            roomId.set(room)
            if (selfUser.get().callStatus.get() != TUICallDefine.Status.Accept) {
                selfUser.get().callStatus.set(TUICallDefine.Status.Accept)
            }
            instance.reverse1v1CallRenderView = true
            if (isMicrophoneMute.get()) {
                EngineManager.instance.closeMicrophone()
            } else {
                EngineManager.instance.openMicrophone(null)
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
                        EngineManager.instance.selectAudioPlaybackDevice(AudioPlaybackDevice.Earpiece)
                    } else {
                        if (TUICallDefine.Role.Caller == instance.selfUser.get().callRole.get()) {
                            EngineManager.instance.selectAudioPlaybackDevice(AudioPlaybackDevice.Earpiece)
                        } else {
                            EngineManager.instance.selectAudioPlaybackDevice(AudioPlaybackDevice.Speakerphone)
                        }
                    }
                } else {
                    EngineManager.instance.selectAudioPlaybackDevice(AudioPlaybackDevice.Speakerphone)
                }
            }
        }

        override fun onUserReject(userId: String?) {
            TUILog.i(TAG, "onUserReject -> {userId: $userId}")
            if (userId.isNullOrEmpty()) {
                return
            }

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
            ToastUtil.toastShortMessage(TUIConfig.getAppContext().getString(R.string.tuicallkit_text_line_busy))
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
            if (networkQualityList.isNullOrEmpty()) {
                return
            }
            val iterator = networkQualityList.iterator()
            if (scene.get() == TUICallDefine.Scene.GROUP_CALL) {
                while (iterator.hasNext()) {
                    val info = iterator.next()
                    val user = findUser(info?.userId)
                    user?.networkQualityReminder?.set(isBadNetwork(info?.quality))
                }
            } else if (scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
                var localQuality: NetworkQuality? = NetworkQuality.Unknown
                var remoteQuality: NetworkQuality? = NetworkQuality.Unknown

                while (iterator.hasNext()) {
                    val info = iterator.next()
                    if (selfUser.get().id == info?.userId) {
                        localQuality = info?.quality
                    } else {
                        remoteQuality = info?.quality
                    }
                }

                if (isBadNetwork(localQuality)) {
                    networkQualityReminder.set(Constants.NetworkQualityHint.Local)
                } else if (isBadNetwork(remoteQuality)) {
                    networkQualityReminder.set(Constants.NetworkQualityHint.Remote)
                } else {
                    networkQualityReminder.set(Constants.NetworkQualityHint.None)
                }
            }
        }

        override fun onKickedOffline() {
            EngineManager.instance.hangup(null)
            resetCall()
        }

        override fun onUserSigExpired() {
            EngineManager.instance.hangup(null)
            resetCall()
        }
    }

    private fun isBadNetwork(quality: NetworkQuality?): Boolean {
        return quality == NetworkQuality.Bad || quality == NetworkQuality.Vbad || quality == NetworkQuality.Down
    }

    fun clear() {
        TUILog.i(TAG, "clear")
        reverse1v1CallRenderView = false
        isShowFullScreen.set(false)
        isBottomViewExpand.set(true)
        showLargeViewUserId.set(null)
        enableBlurBackground.set(false)
        networkQualityReminder.set(Constants.NetworkQualityHint.None)
        selfUser.get().callStatus.set(TUICallDefine.Status.None)
        selfUser.get().clear()
        selfUser.set(User())
        for (user in remoteUserList.get()) {
            user.clear()
        }
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
        isShowFullScreen.removeAll()
        isBottomViewExpand.removeAll()
        showLargeViewUserId.removeAll()
        enableBlurBackground.removeAll()
        networkQualityReminder.removeAll()
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
        user.clear()
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
        if (selfUser.get().callStatus.get() != TUICallDefine.Status.Accept) {
            selfUser.get().callStatus.set(TUICallDefine.Status.Accept)
        }
        user.callStatus.set(TUICallDefine.Status.Accept)
        if (!remoteUserList.get().contains(user) && !userId.equals(selfUser.get().id)) {
            remoteUserList.add(user)
        }
        if (TextUtils.isEmpty(user.nickname.get()) || TextUtils.isEmpty(user.avatar.get())) {
            UserInfoUtils.updateUserInfo(user)
        }
    }

    companion object {
        const val TAG = "TUICallState"
        val instance: TUICallState = TUICallState()
    }
}