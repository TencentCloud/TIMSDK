package io.trtc.tuikit.atomicx.callview

import io.trtc.tuikit.atomicxcore.api.call.CallParticipantStatus
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

object CallViewStore {

    private const val DEFAULT_SHOW_TRANSCRIBER_PANEL = true

    private val _isShowTranscriberPanel = MutableStateFlow(DEFAULT_SHOW_TRANSCRIBER_PANEL)
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    init {
        scope.launch {
            CallStore.shared.observerState.selfInfo.collect { selfInfo ->
                if (selfInfo.status != CallParticipantStatus.Accept) {
                    reset()
                }
            }
        }
    }

    val isShowTranscriberPanel: StateFlow<Boolean> = _isShowTranscriberPanel

    fun setShowTranscriberPanel(show: Boolean) {
        _isShowTranscriberPanel.value = show
    }

    private fun reset() {
        _isShowTranscriberPanel.value = DEFAULT_SHOW_TRANSCRIBER_PANEL
    }
}

