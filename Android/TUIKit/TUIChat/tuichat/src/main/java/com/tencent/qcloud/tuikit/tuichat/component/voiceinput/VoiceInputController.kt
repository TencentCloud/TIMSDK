package com.tencent.qcloud.tuikit.tuichat.component.voiceinput

import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuichat.R
import com.tencent.qcloud.tuikit.tuichat.TUIChatService
import com.tencent.qcloud.tuikit.tuichat.component.audio.AudioRecorder

class VoiceInputController @JvmOverloads constructor(
    private val anchorView: View,
    private val listener: Listener,
    private val maxDurationMs: Int = DEFAULT_MAX_DURATION_MS,
    private val minDurationMs: Int = DEFAULT_MIN_DURATION_MS,
) {
    interface Listener {
        fun canStartRecordFromTextInput(): Boolean
        fun onTextInputTap()
        fun onBeforeRecordFromTextInput()
        fun onSendAudio(filePath: String, durationMs: Int)
        fun onSendText(text: String)
        fun onRecordStart()
        fun onRecordReadyToCancel()
        fun onRecordContinue()
        fun onRecordReadyToTranscribe()
        fun onRecordCancel()
        fun onRecordTooShort()
        fun onRecordStop()
        fun onRecordFailed()
    }

    enum class RecordUiState {
        IDLE,
        RECORDING,
        READY_TO_CANCEL,
        READY_TO_TRANSCRIBE,
    }

    private val transcriber = VoiceInputAudioTranscriber()
    private var recordOverlay: VoiceInputRecordOverlay? = null
    private var recordOverlayAnchorView: View = anchorView
    private var transcriptionOverlay: VoiceInputTranscriptionOverlay? = null
    private var isWaitingForLongPress = false
    private var isRecording = false
    private var canTextInputRecordOnDown = false
    private var pendingReleaseAction = VoiceInputReleaseAction.SEND_AUDIO
    private var currentUiState = RecordUiState.IDLE
    private var recordStartTimeMs = 0L
    private var hasAutoStopped = false
    private var smoothedPowerLevel: Float? = null
    private val longPressRunnable = Runnable {
        isWaitingForLongPress = false
        if (canTextInputRecordOnDown) {
            listener.onBeforeRecordFromTextInput()
        }
        beginRecord()
    }

    @JvmOverloads
    fun onTextInputTouch(event: MotionEvent, overlayAnchorView: View = anchorView): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                canTextInputRecordOnDown = listener.canStartRecordFromTextInput()
                if (canTextInputRecordOnDown) {
                    scheduleLongPress(overlayAnchorView)
                    return true
                }
                return false
            }
            MotionEvent.ACTION_MOVE -> {
                if (isRecording) {
                    updateReleaseAction(event.rawX, event.rawY)
                    return true
                }
                return isWaitingForLongPress
            }
            MotionEvent.ACTION_UP -> {
                val shouldOpenTextInput = isWaitingForLongPress && canTextInputRecordOnDown
                removeLongPress()
                if (shouldOpenTextInput && !isRecording) {
                    canTextInputRecordOnDown = false
                    listener.onTextInputTap()
                    return true
                }
                if (isRecording) {
                    finishRecord(event.rawX, event.rawY)
                    return true
                }
                canTextInputRecordOnDown = false
                return false
            }
            MotionEvent.ACTION_CANCEL -> {
                val shouldConsumeCancel = isWaitingForLongPress || isRecording
                removeLongPress()
                if (isRecording) {
                    AudioRecorder.cancelRecord()
                    return true
                }
                canTextInputRecordOnDown = false
                return shouldConsumeCancel
            }
            else -> return false
        }
    }

    @JvmOverloads
    fun onPressToTalkTouch(event: MotionEvent, overlayAnchorView: View = anchorView): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                canTextInputRecordOnDown = false
                scheduleLongPress(overlayAnchorView)
                return true
            }
            MotionEvent.ACTION_MOVE -> {
                if (isRecording) {
                    updateReleaseAction(event.rawX, event.rawY)
                }
                return true
            }
            MotionEvent.ACTION_UP -> {
                removeLongPress()
                if (isRecording) {
                    finishRecord(event.rawX, event.rawY)
                } else {
                    anchorView.performClick()
                }
                return true
            }
            MotionEvent.ACTION_CANCEL -> {
                removeLongPress()
                if (isRecording) {
                    AudioRecorder.cancelRecord()
                }
                return true
            }
            else -> return false
        }
    }

    fun dismiss() {
        removeLongPress()
        if (isRecording) {
            AudioRecorder.cancelRecord()
        }
        recordOverlay?.dismiss()
        recordOverlay = null
        transcriptionOverlay?.dismiss()
        transcriptionOverlay = null
    }

    private fun scheduleLongPress(overlayAnchorView: View) {
        recordOverlayAnchorView = overlayAnchorView
        pendingReleaseAction = VoiceInputReleaseAction.SEND_AUDIO
        isWaitingForLongPress = true
        anchorView.postDelayed(longPressRunnable, ViewConfiguration.getLongPressTimeout().toLong())
    }

    private fun removeLongPress() {
        isWaitingForLongPress = false
        anchorView.removeCallbacks(longPressRunnable)
    }

    private fun beginRecord() {
        if (isRecording) {
            return
        }
        isRecording = true
        recordStartTimeMs = SystemClock.uptimeMillis()
        hasAutoStopped = false
        pendingReleaseAction = VoiceInputReleaseAction.SEND_AUDIO
        currentUiState = RecordUiState.RECORDING
        smoothedPowerLevel = null
        val overlay = obtainRecordOverlay()
        overlay.show()
        overlay.update(currentUiState, 0, 0, maxDurationMs)
        AudioRecorder.startRecord(object : AudioRecorder.AudioRecorderCallback {
            override fun onStarted() {
                isRecording = true
                    listener.onRecordStart()
                    obtainRecordOverlay(recordOverlayAnchorView).show()
            }

            override fun onFinished(outputPath: String) {
                val duration = AudioRecorder.getDuration(outputPath)
                val releaseAction = pendingReleaseAction
                resetRecordOverlay()
                if (duration < minDurationMs) {
                    listener.onRecordTooShort()
                    return
                }
                listener.onRecordStop()
                when (releaseAction) {
                    VoiceInputReleaseAction.TRANSCRIBE -> showTranscription(outputPath, duration)
                    VoiceInputReleaseAction.SEND_AUDIO -> listener.onSendAudio(outputPath, duration)
                    VoiceInputReleaseAction.CANCEL -> listener.onRecordCancel()
                }
            }

            override fun onFailed(errorCode: Int, errorMessage: String?) {
                resetRecordOverlay()
                if (errorCode == AudioRecorder.ERROR_CODE_MIC_IS_BEING_USED ||
                    errorCode == TUIConstants.TUICalling.ERROR_STATUS_IN_CALL
                ) {
                    ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.chat_mic_is_being_used_cant_record))
                } else {
                    ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.chat_record_audio_failed))
                }
                listener.onRecordFailed()
            }

            override fun onCanceled() {
                resetRecordOverlay()
                listener.onRecordCancel()
            }

            override fun onVoiceDb(db: Double) {
                val durationMs = (SystemClock.uptimeMillis() - recordStartTimeMs).toInt().coerceAtLeast(0)
                smoothedPowerLevel = VoiceInputPowerLevelPolicy.smooth(smoothedPowerLevel, db.toInt())
                val powerLevel = smoothedPowerLevel?.toInt() ?: 0
                obtainRecordOverlay(recordOverlayAnchorView).update(currentUiState, durationMs, powerLevel, maxDurationMs)
                if (!hasAutoStopped && maxDurationMs > 0 && durationMs >= maxDurationMs) {
                    hasAutoStopped = true
                    AudioRecorder.stopRecord()
                }
            }
        })
    }

    private fun updateReleaseAction(rawX: Float, rawY: Float) {
        val overlay = obtainRecordOverlay()
        val nextAction = overlay.releaseActionFor(rawX, rawY)
        val nextState = when (nextAction) {
            VoiceInputReleaseAction.CANCEL -> RecordUiState.READY_TO_CANCEL
            VoiceInputReleaseAction.TRANSCRIBE -> RecordUiState.READY_TO_TRANSCRIBE
            else -> RecordUiState.RECORDING
        }
        if (pendingReleaseAction != nextAction) {
            pendingReleaseAction = nextAction
            when (nextAction) {
                VoiceInputReleaseAction.CANCEL -> listener.onRecordReadyToCancel()
                VoiceInputReleaseAction.TRANSCRIBE -> listener.onRecordReadyToTranscribe()
                VoiceInputReleaseAction.SEND_AUDIO -> listener.onRecordContinue()
            }
        }
        if (currentUiState == nextState) {
            return
        }
        currentUiState = nextState
        val durationMs = (SystemClock.uptimeMillis() - recordStartTimeMs).toInt().coerceAtLeast(0)
        overlay.update(nextState, durationMs, 0, maxDurationMs)
    }

    private fun finishRecord(rawX: Float, rawY: Float) {
        pendingReleaseAction = obtainRecordOverlay().releaseActionFor(rawX, rawY)
        if (pendingReleaseAction == VoiceInputReleaseAction.CANCEL) {
            AudioRecorder.cancelRecord()
        } else {
            AudioRecorder.stopRecord()
        }
    }

    private fun showTranscription(audioPath: String, durationMs: Int) {
        val durationSecond = (durationMs / 1000).coerceAtLeast(1)
        transcriptionOverlay?.dismiss()
        transcriptionOverlay = VoiceInputTranscriptionOverlay(
            anchorView = anchorView,
            audioPath = audioPath,
            audioDurationSecond = durationSecond,
            initialText = null,
            onCancel = { transcriptionOverlay = null },
            onSendAudio = { path, seconds ->
                listener.onSendAudio(path, seconds * 1000)
                transcriptionOverlay?.dismiss()
                transcriptionOverlay = null
            },
            onSendText = { text ->
                listener.onSendText(text)
                transcriptionOverlay?.dismiss()
                transcriptionOverlay = null
            },
            onDismissed = { transcriptionOverlay = null },
        ).also { it.show() }
        transcriber.convert(
            filePath = audioPath,
            onFailure = { _, _ ->
                ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.voice_input_convert_failed))
            },
            onCompleted = { text ->
                transcriptionOverlay?.updateResult(text)
            },
        )
    }

    private fun obtainRecordOverlay(overlayAnchorView: View = recordOverlayAnchorView): VoiceInputRecordOverlay {
        if (recordOverlay != null && recordOverlayAnchorView !== overlayAnchorView) {
            recordOverlay?.dismiss()
            recordOverlay = null
        }
        recordOverlayAnchorView = overlayAnchorView
        return recordOverlay ?: VoiceInputRecordOverlay(overlayAnchorView).also { recordOverlay = it }
    }

    private fun resetRecordOverlay() {
        isRecording = false
        canTextInputRecordOnDown = false
        pendingReleaseAction = VoiceInputReleaseAction.SEND_AUDIO
        currentUiState = RecordUiState.IDLE
        hasAutoStopped = false
        smoothedPowerLevel = null
        recordOverlay?.dismiss()
        recordOverlay = null
        recordOverlayAnchorView = anchorView
    }

    companion object {
        const val DEFAULT_MIN_DURATION_MS = 1000
        const val DEFAULT_MAX_DURATION_MS = 60_000
    }
}

internal object VoiceInputPowerLevelPolicy {
    private const val SMOOTHING_FACTOR = 0.25f

    fun smooth(previous: Float?, rawPowerLevel: Int): Float {
        val target = rawPowerLevel.coerceIn(0, 100).toFloat()
        return previous?.let { it + (target - it) * SMOOTHING_FACTOR } ?: target
    }
}
