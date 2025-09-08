package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.os.Build
import android.view.LayoutInflater
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.feature.AudioRouteFeature
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.trtc.TRTCCloudDef
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.livedata.Observer

class AudioCallerWaitingAndAcceptedView(context: Context) : ConstraintLayout(context) {
    private lateinit var buttonMicrophone: ControlButton
    private lateinit var buttonAudioDevice: ControlButton
    private lateinit var buttonHangup: ControlButton
    private var audioDevicePopupWindow: AudioPlayoutDevicePopupView? = null

    private var audioRouteFeature: AudioRouteFeature = AudioRouteFeature(context)

    private var isMicMuteObserver = Observer<Boolean> {
        buttonMicrophone.imageView.isActivated = it
        buttonMicrophone.textView.text = getMicText()
    }

    private val audioPlayoutDeviceObserver = Observer<TUICommonDefine.AudioPlaybackDevice> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            updateAudioDeviceButtonForLegacy(it)
        }
    }

    private val selectedAudioDeviceObserver = Observer<Int> {
        updateAudioDeviceButton(it)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        this.layoutParams?.width = LayoutParams.MATCH_PARENT
        this.layoutParams?.height = LayoutParams.MATCH_PARENT
        initView()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
        audioDevicePopupWindow?.dismiss()
    }

    private fun registerObserver() {
        CallManager.instance.mediaState.isMicrophoneMuted.observe(isMicMuteObserver)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            audioRouteFeature.register()
            CallManager.instance.mediaState.selectedAudioDevice.observe(selectedAudioDeviceObserver)
        } else {
            CallManager.instance.mediaState.audioPlayoutDevice.observe(audioPlayoutDeviceObserver)
        }
    }

    private fun unregisterObserver() {
        CallManager.instance.mediaState.isMicrophoneMuted.removeObserver(isMicMuteObserver)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            audioRouteFeature.unregister()
            CallManager.instance.mediaState.selectedAudioDevice.removeObserver(selectedAudioDeviceObserver)
        } else {
            CallManager.instance.mediaState.audioPlayoutDevice.removeObserver(audioPlayoutDeviceObserver)
        }
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_audio, this)
        buttonMicrophone = findViewById(R.id.cb_mic)
        buttonHangup = findViewById(R.id.cb_hangup)
        buttonAudioDevice = findViewById(R.id.cb_audio_device)

        val buttonSet = GlobalState.instance.disableControlButtonSet
        buttonMicrophone.visibility = if (buttonSet.contains(Constants.ControlButton.Microphone)) GONE else VISIBLE
        buttonAudioDevice.visibility =
            if (buttonSet.contains(Constants.ControlButton.AudioPlaybackDevice)) GONE else VISIBLE
        buttonMicrophone.imageView.isActivated = CallManager.instance.mediaState.isMicrophoneMuted.get()
        buttonMicrophone.textView.text = getMicText()


        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            updateAudioDeviceButton(CallManager.instance.mediaState.selectedAudioDevice.get())
        } else {
            updateAudioDeviceButtonForLegacy(CallManager.instance.mediaState.audioPlayoutDevice.get())
        }

        initViewListener()
    }

    private fun initViewListener() {
        buttonMicrophone.setOnClickListener {
            if (!buttonMicrophone.isEnabled) {
                return@setOnClickListener
            }
            if (CallManager.instance.mediaState.isMicrophoneMuted.get()) {
                CallManager.instance.openMicrophone(null)
            } else {
                CallManager.instance.closeMicrophone()
            }
        }
        buttonHangup.setOnClickListener {
            buttonHangup.imageView.roundPercent = 1.0f
            buttonHangup.imageView.setBackgroundColor(ContextCompat.getColor(context, R.color.tuicallkit_button_bg_red))
            ImageLoader.loadGif(context, buttonHangup.imageView, R.drawable.tuicallkit_hangup_loading)
            disableButton(buttonMicrophone)
            disableButton(buttonAudioDevice)

            CallManager.instance.hangup(null)
        }
        buttonAudioDevice.setOnClickListener {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val availableAudioDevices = CallManager.instance.mediaState.availableAudioDevices.get()
                val hasOnlyBuiltInDevices = availableAudioDevices.all {
                    it == TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE || it == TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER
                }
                if (hasOnlyBuiltInDevices) {
                    val selectedRoute = CallManager.instance.mediaState.selectedAudioDevice.get()
                    val targetRoute = if (selectedRoute == TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER) {
                        TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE
                    } else {
                        TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER
                    }
                    audioRouteFeature.setAudioRoute(targetRoute)
                } else {
                    showAudioDevicePopup()
                }
            } else {
                val currentDevice = CallManager.instance.mediaState.audioPlayoutDevice.get()
                val device = if (currentDevice == TUICommonDefine.AudioPlaybackDevice.Speakerphone) {
                    TUICommonDefine.AudioPlaybackDevice.Earpiece
                } else {
                    TUICommonDefine.AudioPlaybackDevice.Speakerphone
                }
                CallManager.instance.selectAudioPlaybackDevice(device)
            }
        }
    }

    private fun disableButton(button: ControlButton) {
        button.isEnabled = false
        button.alpha = 0.8f
    }

    private fun updateAudioDeviceButton(selectedRoute: Int) {
        buttonAudioDevice.textView.text = audioRouteFeature.getAudioDeviceName(selectedRoute)

        val availableAudioDevices = CallManager.instance.mediaState.availableAudioDevices.get()
        val hasExternalDevice = availableAudioDevices.any {
            it == TRTCCloudDef.TRTC_AUDIO_ROUTE_BLUETOOTH_HEADSET || it == TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET
        }

        if (hasExternalDevice) {
            buttonAudioDevice.imageView.setImageResource(R.drawable.tuicallkit_ic_audio_route_picker)
            return
        }
        val device = if (selectedRoute == TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER)
            TUICommonDefine.AudioPlaybackDevice.Speakerphone else TUICommonDefine.AudioPlaybackDevice.Earpiece
        updateAudioDeviceButtonForLegacy(device)
    }

    private fun updateAudioDeviceButtonForLegacy(device: TUICommonDefine.AudioPlaybackDevice) {
        val isSpeaker = device == TUICommonDefine.AudioPlaybackDevice.Speakerphone
        buttonAudioDevice.imageView.isActivated = isSpeaker
        buttonAudioDevice.imageView.setImageResource(R.drawable.tuicallkit_bg_audio_device)

        val resId = if (isSpeaker) R.string.tuicallkit_toast_speaker else R.string.tuicallkit_toast_use_earpiece
        buttonAudioDevice.textView.text = context.getString(resId)
    }

    private fun showAudioDevicePopup() {
        if (audioDevicePopupWindow == null) {
            audioDevicePopupWindow = AudioPlayoutDevicePopupView(audioRouteFeature)
        }
        audioDevicePopupWindow?.show(buttonAudioDevice, CallManager.instance.mediaState.selectedAudioDevice.get())
    }

    private fun getMicText(): String {
        return if (CallManager.instance.mediaState.isMicrophoneMuted.get()) {
            context.getString(R.string.tuicallkit_toast_enable_mute)
        } else {
            context.getString(R.string.tuicallkit_toast_disable_mute)
        }
    }
}
