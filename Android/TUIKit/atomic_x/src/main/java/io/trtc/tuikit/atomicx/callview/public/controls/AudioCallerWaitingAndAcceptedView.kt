package io.trtc.tuikit.atomicx.callview.public.controls

import android.content.Context
import android.view.LayoutInflater
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import com.trtc.tuikit.common.imageloader.ImageLoader
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.callview.core.common.widget.ControlButton
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.device.AudioRoute
import io.trtc.tuikit.atomicxcore.api.device.DeviceStatus
import io.trtc.tuikit.atomicxcore.api.device.DeviceStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class AudioCallerWaitingAndAcceptedView(context: Context) : RelativeLayout(context) {
    private var subscribeStateJob: Job? = null

    private lateinit var buttonMicrophone: ControlButton
    private lateinit var buttonAudioDevice: ControlButton
    private lateinit var buttonHangup: ControlButton

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        this.layoutParams?.width = LayoutParams.MATCH_PARENT
        this.layoutParams?.height = LayoutParams.MATCH_PARENT
        initView()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        subscribeStateJob?.cancel()
    }

    private fun registerObserver() {
        subscribeStateJob = CoroutineScope(Dispatchers.Main).launch {
            launch { observeDeviceStatus() }
            launch { observeAudioRoute() }
        }
    }

    private suspend fun observeDeviceStatus() {
        DeviceStore.shared().deviceState.microphoneStatus.collect {
            updateMicrophoneButtonView()
        }
    }

    private suspend fun observeAudioRoute() {
        DeviceStore.shared().deviceState.currentAudioRoute.collect { audioRoute ->
            updateAudioRouteButton(audioRoute)
        }
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.callview_function_view_audio, this)
        buttonMicrophone = findViewById(R.id.cb_mic)
        buttonHangup = findViewById(R.id.cb_hangup)
        buttonAudioDevice = findViewById(R.id.cb_audio_device)
        buttonMicrophone.visibility = VISIBLE
        buttonAudioDevice.visibility = VISIBLE
        updateMicrophoneButtonView()

        val currentAudioRoute = DeviceStore.shared().deviceState.currentAudioRoute.value
        updateAudioRouteButton(currentAudioRoute)
        initViewListener()
    }

    private fun updateAudioRouteButton(audioRoute: AudioRoute) {
        val isSpeaker = audioRoute == AudioRoute.SPEAKERPHONE
        val resId = if (isSpeaker) R.string.callview_text_speaker else R.string.callview_text_use_earpiece
        buttonAudioDevice.textView.text = context.getString(resId)
        buttonAudioDevice.imageView.isActivated = isSpeaker
        buttonAudioDevice.imageView.setImageResource(R.drawable.callview_bg_audio_device)
    }

    private fun initViewListener() {
        buttonMicrophone.setOnClickListener {
            if (!buttonMicrophone.isEnabled) {
                return@setOnClickListener
            }
            val currentMicrophoneStatus = DeviceStore.shared().deviceState.microphoneStatus.value
            if (currentMicrophoneStatus == DeviceStatus.ON) {
                DeviceStore.shared().closeLocalMicrophone()
            } else {
                DeviceStore.shared().openLocalMicrophone(null)
            }
        }
        buttonHangup.setOnClickListener {
            buttonHangup.imageView.roundPercent = 1.0f
            buttonHangup.imageView.setBackgroundColor(ContextCompat.getColor(context, R.color.callview_button_bg_red))
            ImageLoader.loadGif(context, buttonHangup.imageView, R.drawable.callview_hangup_loading)
            disableButton(buttonMicrophone)
            disableButton(buttonAudioDevice)
            CallStore.shared.hangup(null)
        }
        buttonAudioDevice.setOnClickListener {
            val currentAudioRoute = DeviceStore.shared().deviceState.currentAudioRoute.value
            if (currentAudioRoute == AudioRoute.SPEAKERPHONE) {
                DeviceStore.shared().setAudioRoute(AudioRoute.EARPIECE)
            } else {
                DeviceStore.shared().setAudioRoute(AudioRoute.SPEAKERPHONE)
            }
        }
    }

    private fun disableButton(button: ControlButton) {
        button.isEnabled = false
        button.alpha = 0.8f
    }

    private fun updateMicrophoneButtonView() {
        val microphoneStatus = DeviceStore.shared().deviceState.microphoneStatus.value
        buttonMicrophone.imageView.isActivated = (microphoneStatus == DeviceStatus.OFF)
        buttonMicrophone.textView.text = if (microphoneStatus == DeviceStatus.OFF) {
            context.getString(R.string.callview_toast_enable_mute)
        } else {
            context.getString(R.string.callview_toast_disable_mute)
        }
    }
}
