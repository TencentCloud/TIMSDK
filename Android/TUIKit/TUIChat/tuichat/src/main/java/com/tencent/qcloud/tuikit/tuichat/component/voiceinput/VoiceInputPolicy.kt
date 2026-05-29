package com.tencent.qcloud.tuikit.tuichat.component.voiceinput

import kotlin.math.ceil

data class VoiceInputGestureTarget(
    val left: Float,
    val top: Float,
    val width: Float,
    val height: Float,
) {
    fun contains(x: Float, y: Float): Boolean {
        return x >= left && x <= left + width && y >= top && y <= top + height
    }
}

enum class VoiceInputReleaseAction {
    SEND_AUDIO,
    CANCEL,
    TRANSCRIBE,
}

object VoiceInputGesturePolicy {
    private const val COUNTDOWN_WINDOW_MS = 10_000

    @JvmStatic
    fun decideReleaseAction(
        fingerX: Float,
        fingerY: Float,
        cancelTarget: VoiceInputGestureTarget,
        transcribeTarget: VoiceInputGestureTarget,
    ): VoiceInputReleaseAction {
        return when {
            cancelTarget.contains(fingerX, fingerY) -> VoiceInputReleaseAction.CANCEL
            transcribeTarget.contains(fingerX, fingerY) -> VoiceInputReleaseAction.TRANSCRIBE
            else -> VoiceInputReleaseAction.SEND_AUDIO
        }
    }

    @JvmStatic
    fun remainingSecondsBeforeAutoStop(durationMs: Int, maxDurationMs: Int): Int? {
        if (maxDurationMs <= 0) {
            return null
        }
        val remainingMs = (maxDurationMs - durationMs).coerceAtLeast(0)
        if (remainingMs > COUNTDOWN_WINDOW_MS) {
            return null
        }
        return ceil(remainingMs / 1000f).toInt().coerceAtLeast(1)
    }
}

object VoiceInputStartPolicy {
    @JvmStatic
    fun canStartFromTextInput(
        isKeyboardShowing: Boolean,
        isFacePanelShowing: Boolean,
        isMorePanelShowing: Boolean,
        hasInputText: Boolean,
    ): Boolean {
        return !hasInputText && !isKeyboardShowing && !isFacePanelShowing && !isMorePanelShowing
    }
}
