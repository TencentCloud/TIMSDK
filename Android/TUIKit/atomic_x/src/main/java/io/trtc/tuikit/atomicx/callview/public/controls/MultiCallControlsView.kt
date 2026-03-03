package io.trtc.tuikit.atomicx.callview.public.controls

import android.content.Context
import android.widget.RelativeLayout
import androidx.constraintlayout.widget.ConstraintLayout
import io.trtc.tuikit.atomicx.callview.core.common.utils.CallUtils
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantStatus
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.supervisorScope

class MultiCallControlsView(context: Context) : ConstraintLayout(context) {
    private var subscribeStateJob: Job? = null
    private var functionLayout: RelativeLayout? = null
    private var callStatus = CallParticipantStatus.None

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        updateLayout()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        subscribeStateJob?.cancel()
    }

    private fun registerObserver() {
        subscribeStateJob = CoroutineScope(Dispatchers.Main).launch {
            supervisorScope {
                launch { observeSelfInfo() }
                launch { observeAllParticipants() }
            }
        }
    }

    private suspend fun observeSelfInfo() {
        CallStore.shared.observerState.selfInfo.collect { selfInfo ->
            if (callStatus != selfInfo.status && selfInfo.status == CallParticipantStatus.Accept) {
                callStatus = selfInfo.status
                updateLayout()
            }
        }
    }

    private suspend fun observeAllParticipants() {
        CallStore.shared.observerState.allParticipants.collect { participants ->
            if (participants.size > 2) {
                if (functionLayout is VideoCallerAndCalleeAcceptedView) {
                    return@collect
                }
                updateLayout()
            }
        }
    }

    private fun updateLayout() {
        val selfInfo = CallStore.shared.observerState.selfInfo.value
        val newLayout = if (selfInfo.status == CallParticipantStatus.Waiting && !CallUtils.isCaller(selfInfo.id)) {
                AudioAndVideoCalleeWaitingView(context)
            } else {
                VideoCallerAndCalleeAcceptedView(context)
            }

        functionLayout?.takeIf { it.javaClass == newLayout.javaClass }?.let {
            return
        }

        functionLayout = newLayout
        removeAllViews()
        addView(functionLayout)
    }
}