package com.tencent.qcloud.tuikit.tuicallkit.manager.observer

import android.os.Handler
import android.os.HandlerThread
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallObserver
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.UserManager
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.trtc.tuikit.common.foregroundservice.AudioForegroundService
import com.trtc.tuikit.common.foregroundservice.VideoForegroundService

class CallEngineObserver : TUICallObserver() {
    private var timeHandlerThread: HandlerThread? = null
    private var timeHandler: Handler? = null
    private var timeRunnable: Runnable? = null

    override fun onError(errCode: Int, errMsg: String) {
        Logger.e(TAG, "onError, errCode: $errCode, errMsg: $errMsg")
    }

    override fun onCallReceived(
        callId: String?, callerId: String?, calleeIdList: MutableList<String>?, mediaType: TUICallDefine.MediaType?,
        info: TUICallDefine.CallObserverExtraInfo?
    ) {
        super.onCallReceived(callId, callerId, calleeIdList, mediaType, info)
        Logger.i(
            TAG, "onCallReceived, callId: $callId, callerId: $callerId, calleeIdList: $calleeIdList," +
                    " mediaType: $mediaType, info: $info"
        )
        if (TUICallDefine.MediaType.Unknown == mediaType || calleeIdList.isNullOrEmpty()) {
            Logger.e(TAG, "mediaType is unknown or calleeIdList is empty")
            return
        }

        if (calleeIdList.size >= Constants.MAX_USER) {
            Logger.w(TAG, "The users is limited to 9. For larger conference calls,try using TUIRoomKit")
            return
        }
        val groupId = info?.chatGroupId
        if (!groupId.isNullOrEmpty() || calleeIdList.size > 1) {
            CallManager.instance.callState.scene.set(TUICallDefine.Scene.GROUP_CALL)
        } else {
            CallManager.instance.callState.scene.set(TUICallDefine.Scene.SINGLE_CALL)
        }
        CallManager.instance.callState.callId = callId ?: ""
        CallManager.instance.callState.chatGroupId = groupId
        CallManager.instance.callState.mediaType.set(mediaType)

        if (!callerId.isNullOrEmpty()) {
            val user = UserState.User()
            user.id = callerId
            UserManager.instance.updateUserInfo(user)
            user.callRole = TUICallDefine.Role.Caller
            user.callStatus.set(TUICallDefine.Status.Waiting)
            CallManager.instance.userState.remoteUserList.add(user)
        }

        val userList = ArrayList<UserState.User>()
        for (userId in calleeIdList) {
            if (!userId.isNullOrEmpty() && userId != TUILogin.getLoginUser()) {
                val user = UserState.User()
                user.id = userId
                UserManager.instance.updateUserInfo(user)
                user.callRole = TUICallDefine.Role.Called
                user.callStatus.set(TUICallDefine.Status.Waiting)
                userList.add(user)
            }
        }
        CallManager.instance.userState.remoteUserList.addAll(userList)
        CallManager.instance.userState.selfUser.get().id = TUILogin.getUserId() ?: ""
        CallManager.instance.userState.selfUser.get().avatar.set(TUILogin.getFaceUrl())
        CallManager.instance.userState.selfUser.get().nickname.set(TUILogin.getNickName())
        CallManager.instance.userState.selfUser.get().callRole = TUICallDefine.Role.Called
        CallManager.instance.userState.selfUser.get().callStatus.set(TUICallDefine.Status.Waiting)

        if (TUICallDefine.MediaType.Video == CallManager.instance.callState.mediaType.get()) {
            CallManager.instance.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Speakerphone)
            CallManager.instance.mediaState.isCameraOpened.set(true)
        } else {
            CallManager.instance.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Earpiece)
            CallManager.instance.mediaState.isCameraOpened.set(false)
        }
    }

    override fun onCallNotConnected(
        callId: String?, mediaType: TUICallDefine.MediaType?, reason: TUICallDefine.CallEndReason?, userId: String?,
        info: TUICallDefine.CallObserverExtraInfo?
    ) {
        super.onCallNotConnected(callId, mediaType, reason, userId, info)
        Logger.i(
            TAG, "onCallNotConnected, callId: $callId, mediaType: $mediaType," +
                    " reason: $reason, userId: $userId, info: $info"
        )
        CallManager.instance.reset()
    }

    override fun onCallBegin(
        callId: String?, mediaType: TUICallDefine.MediaType?, info: TUICallDefine.CallObserverExtraInfo?
    ) {
        super.onCallBegin(callId, mediaType, info)
        Logger.i(TAG, "onCallBegin, callId: $callId, mediaType: $mediaType, info: $info")
        CallManager.instance.callState.callId = callId ?: ""
        CallManager.instance.callState.roomId = info?.roomId
        CallManager.instance.callState.chatGroupId = info?.chatGroupId

        val selfUser = CallManager.instance.userState.selfUser.get()
        if (selfUser.callStatus.get() != TUICallDefine.Status.Accept) {
            selfUser.callStatus.set(TUICallDefine.Status.Accept)
        }
        if (CallManager.instance.mediaState.isMicrophoneMuted.get()) {
            CallManager.instance.closeMicrophone()
        } else {
            CallManager.instance.openMicrophone(null)
        }
        startForegroundService()
        startTimeCount()
    }

    override fun onCallEnd(
        callId: String?, mediaType: TUICallDefine.MediaType?, reason: TUICallDefine.CallEndReason?, userId: String?,
        totalTime: Long, info: TUICallDefine.CallObserverExtraInfo?
    ) {
        super.onCallEnd(callId, mediaType, reason, userId, totalTime, info)
        Logger.i(
            TAG, "onCallEnd, callId: $callId, mediaType: $mediaType," +
                    " reason: $reason, userId: $userId, totalTime: $totalTime, info: $info"
        )
        resetCall()
    }

    override fun onCallMediaTypeChanged(oldMediaType: TUICallDefine.MediaType, newMediaType: TUICallDefine.MediaType) {
        if (oldMediaType != newMediaType) {
            CallManager.instance.callState.mediaType.set(newMediaType)
        }
    }

    override fun onUserReject(userId: String?) {
        Logger.i(TAG, "onUserReject, userId: $userId")
        removeUserOnLeave(userId)
    }

    override fun onUserNoResponse(userId: String?) {
        Logger.i(TAG, "onUserNoResponse, userId: $userId")
        removeUserOnLeave(userId)
    }

    override fun onUserLineBusy(userId: String?) {
        Logger.i(TAG, "onUserLineBusy, userId: $userId")
        removeUserOnLeave(userId)
    }

    override fun onUserJoin(userId: String?) {
        Logger.i(TAG, "onUserJoin, userId: $userId")
        if (userId.isNullOrEmpty() || userId.contains(Constants.AI_TRANSLATION_ROBOT)) {
            return
        }

        var user = findUser(userId)
        if (user == null) {
            user = UserState.User()
            user.id = userId
        }

        user.callStatus.set(TUICallDefine.Status.Accept)

        val remoteUserList = CallManager.instance.userState.remoteUserList.get()
        val selfUser = CallManager.instance.userState.selfUser.get()
        if (remoteUserList != null && !remoteUserList.contains(user) && user.id != selfUser.id) {
            CallManager.instance.userState.remoteUserList.add(user)
        }

        if (user.nickname.get().isNullOrEmpty() || user.avatar.get().isNullOrEmpty()) {
            UserManager.instance.updateUserInfo(user)
        }
    }

    override fun onUserLeave(userId: String?) {
        Logger.i(TAG, "onUserLeave, userId: $userId")
        removeUserOnLeave(userId)
    }

    override fun onUserInviting(userId: String?) {
        Logger.i(TAG, "onUserInviting, userId: $userId")

        if (userId.isNullOrEmpty()) {
            return
        }

        var user = findUser(userId)
        if (user == null) {
            user = UserState.User()
            user.id = userId
            user.callRole = TUICallDefine.Role.Called
        }

        val remoteUserList = CallManager.instance.userState.remoteUserList.get()
        if (remoteUserList != null && !remoteUserList.contains(user)) {
            user.callStatus.set(TUICallDefine.Status.Waiting)
            CallManager.instance.userState.remoteUserList.add(user)
        }

        if (user.nickname.get().isNullOrEmpty() || user.avatar.get().isNullOrEmpty()) {
            UserManager.instance.updateUserInfo(user)
        }
    }

    override fun onUserVideoAvailable(userId: String, isVideoAvailable: Boolean) {
        Logger.i(TAG, "onUserVideoAvailable, userId: $userId, isVideoAvailable: $isVideoAvailable")

        val user = findUser(userId)
        if (user != null && user.videoAvailable.get() != isVideoAvailable) {
            user.videoAvailable.set(isVideoAvailable)
        }
    }

    override fun onUserAudioAvailable(userId: String, isAudioAvailable: Boolean) {
        Logger.i(TAG, "onUserAudioAvailable, userId: $userId, isAudioAvailable: $isAudioAvailable")

        val user = findUser(userId)
        if (user != null && user.audioAvailable.get() != isAudioAvailable) {
            user.audioAvailable.set(isAudioAvailable)
        }
    }

    override fun onUserVoiceVolumeChanged(volumeMap: MutableMap<String, Int>?) {
        if (TUICallDefine.Scene.SINGLE_CALL == CallManager.instance.callState.scene.get() || volumeMap.isNullOrEmpty()) {
            return
        }
        for (entry in volumeMap.entries) {
            if (null != entry && !entry.key.isNullOrEmpty()) {
                val user = findUser(entry.key)
                if (user != null && user.playoutVolume.get() != entry.value) {
                    user.playoutVolume.set(entry.value)
                }
            }
        }
    }

    override fun onUserNetworkQualityChanged(networkQualityList: MutableList<TUICommonDefine.NetworkQualityInfo>?) {
        if (networkQualityList.isNullOrEmpty()) {
            return
        }
        val scene = CallManager.instance.callState.scene
        val iterator = networkQualityList.iterator()
        if (scene.get() == TUICallDefine.Scene.GROUP_CALL) {
            while (iterator.hasNext()) {
                val info = iterator.next()
                val user = findUser(info.userId)
                user?.networkQualityReminder?.set(isBadNetwork(info.quality))
            }
            return
        }

        if (scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            var localQuality: TUICommonDefine.NetworkQuality = TUICommonDefine.NetworkQuality.UNKNOWN
            var remoteQuality: TUICommonDefine.NetworkQuality = TUICommonDefine.NetworkQuality.UNKNOWN

            while (iterator.hasNext()) {
                val info = iterator.next()
                if (CallManager.instance.userState.selfUser.get().id == info.userId) {
                    localQuality = info.quality
                } else {
                    remoteQuality = info.quality
                }
            }

            val networkQualityReminder = CallManager.instance.callState.networkQualityReminder
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
        Logger.i(TAG, "onKickedOffline")
        CallManager.instance.hangup(null)
        resetCall()
    }

    override fun onUserSigExpired() {
        Logger.i(TAG, "onUserSigExpired")
        CallManager.instance.hangup(null)
        resetCall()
    }

    private fun resetCall() {
        stopTimeCount()
        stopForegroundService()
        CallManager.instance.reset()
    }

    private fun startTimeCount() {
        if (timeHandlerThread == null) {
            timeHandlerThread = HandlerThread("time-count-thread")
            timeHandlerThread?.start()
            timeHandler = Handler(timeHandlerThread!!.looper)
        }
        timeRunnable = Runnable {
            val count = CallManager.instance.callState.callDurationCount.get() + 1
            CallManager.instance.callState.callDurationCount.set(count)
            timeHandler?.let {
                it.postDelayed(timeRunnable!!, 1000)
            }
        }
        timeHandler?.post(timeRunnable!!)
    }

    private fun stopTimeCount() {
        if (timeHandler != null) {
            timeHandler?.removeCallbacks(timeRunnable!!)
            timeHandler = null
        }
        timeRunnable = null
        if (timeHandlerThread != null) {
            timeHandlerThread?.quitSafely()
            timeHandlerThread = null
        }
        CallManager.instance.callState.callDurationCount.set(0)
    }

    private fun findUser(userId: String?): UserState.User? {
        if (userId.isNullOrEmpty()) {
            return null
        }
        if (userId == CallManager.instance.userState.selfUser.get().id) {
            return CallManager.instance.userState.selfUser.get()
        }
        for (user in CallManager.instance.userState.remoteUserList.get()) {
            if (!user.id.isNullOrEmpty() && userId == user.id) {
                return user
            }
        }
        return null
    }

    private fun removeUserOnLeave(userId: String?) {
        val user = findUser(userId)
        if (user == null || user.id.isNullOrEmpty()) {
            return
        }
        user.reset()
        if (CallManager.instance.userState.remoteUserList.get().contains(user)) {
            CallManager.instance.userState.remoteUserList.remove(user)
        }
        if (TUICallDefine.Scene.SINGLE_CALL == CallManager.instance.callState.scene.get()) {
            resetCall()
        }
    }

    private fun isBadNetwork(quality: TUICommonDefine.NetworkQuality?): Boolean {
        return quality == TUICommonDefine.NetworkQuality.BAD || quality == TUICommonDefine.NetworkQuality.VERY_BAD
                || quality == TUICommonDefine.NetworkQuality.DOWN
    }

    private fun startForegroundService() {
        if (CallManager.instance.callState.scene.get() == TUICallDefine.Scene.GROUP_CALL
            || CallManager.instance.callState.mediaType.get() == TUICallDefine.MediaType.Video) {
            VideoForegroundService.start(TUIConfig.getAppContext(), "", "", 0)
        } else if (CallManager.instance.callState.mediaType.get() == TUICallDefine.MediaType.Audio) {
            AudioForegroundService.start(TUIConfig.getAppContext(), "", "", 0)
        }
    }

    private fun stopForegroundService() {
        VideoForegroundService.stop(TUIConfig.getAppContext())
        AudioForegroundService.stop(TUIConfig.getAppContext())
    }

    companion object {
        private const val TAG = "CallEngineObserver"
    }
}
