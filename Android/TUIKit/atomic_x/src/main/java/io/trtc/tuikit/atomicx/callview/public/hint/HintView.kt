package io.trtc.tuikit.atomicx.callview.public.hint

import android.content.Context
import android.view.Gravity
import android.view.View
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicxcore.api.call.CallMediaType
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantStatus
import io.trtc.tuikit.atomicxcore.api.device.NetworkQuality
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class HintView(context: Context) : AppCompatTextView(context) {
    private var subscribeStateJob: Job? = null
    private var isFirstShowAccept = true
    private var callStatus = CallParticipantStatus.None

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        initView()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        subscribeStateJob?.cancel()
    }

    private fun registerObserver() {
        subscribeStateJob = CoroutineScope(Dispatchers.Main).launch {
            launch { observeCallStatus() }
            launch { observeNetworkQualities() }
        }
    }

    private suspend fun observeCallStatus() {
        CallStore.shared.observerState.selfInfo.collect { selfInfo ->
            if (callStatus != selfInfo.status) {
                callStatus = selfInfo.status
                updateStatusText()
            }
        }
    }

    private suspend fun observeNetworkQualities() {
        val selfId = CallStore.shared.observerState.selfInfo.value.id
        CallStore.shared.observerState.networkQualities.collect { networkQualities ->
            networkQualities.forEach { (userId, quality) ->
                if (isBadNetwork(quality)) {
                    text = if (userId == selfId) {
                        context.getString(R.string.callview_self_network_low_quality)
                    } else {
                        context.getString(R.string.callview_other_party_network_low_quality)
                    }
                    return@collect
                }
                updateStatusText()
            }
        }
    }

    private fun isBadNetwork(quality: NetworkQuality?): Boolean {
        return quality == NetworkQuality.BAD || quality == NetworkQuality.VERY_BAD
                || quality == NetworkQuality.DOWN
    }

    private fun initView() {
        setTextColor(ContextCompat.getColor(context, R.color.callview_color_white))
        gravity = Gravity.CENTER

        val activeCall = CallStore.shared.observerState.activeCall.value
        val isGroupCall = activeCall.inviteeIds.size >= 2
        text = if (isGroupCall) {
            if (selfIsCaller()) {
                context.getString(R.string.callview_wait_response)
            } else {
                context.getString(R.string.callview_wait_accept_group)
            }
        } else {
            updateStatusText()
        }
    }

    private fun updateSingleCallWaitingText(): String {
        val mediaType = CallStore.shared.observerState.activeCall.value.mediaType
        return if (selfIsCaller()) {
            context.getString(R.string.callview_waiting_accept)
        } else {
            if (CallMediaType.Video == mediaType) {
                context.getString(R.string.callview_invite_video_call)
            } else {
                context.getString(R.string.callview_invite_audio_call)
            }
        }
    }

    private fun updateStatusText(): String {
        val isGroupCall = CallStore.shared.observerState.allParticipants.value.size >= 2
        val self = CallStore.shared.observerState.selfInfo.value.copy()
        if (isGroupCall && CallParticipantStatus.Accept == self.status) {
            visibility = View.GONE
            return ""
        }

        if (self.status == CallParticipantStatus.Waiting) {
            return updateSingleCallWaitingText()
        }

        text = ""
        if (self.status == CallParticipantStatus.Accept && selfIsCaller() && isFirstShowAccept) {
            text = context.getString(R.string.callview_accept_single)
            postDelayed({
                isFirstShowAccept = false
            }, 2000)
        }
        return text.toString()
    }

    private fun selfIsCaller(): Boolean {
        val selfId = CallStore.shared.observerState.selfInfo.value.id
        val callerId = CallStore.shared.observerState.activeCall.value.inviterId
        return selfId == callerId
    }
}