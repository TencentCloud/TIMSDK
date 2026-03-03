package io.trtc.tuikit.atomicx.callview.core.common.utils

import io.trtc.tuikit.atomicxcore.api.call.CallStore

object CallUtils {
    fun isCaller(userId: String): Boolean {
        val callerId = CallStore.shared.observerState.activeCall.value.inviterId
        return callerId == userId
    }
}