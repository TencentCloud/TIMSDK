package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.widget.ImageView
import androidx.constraintlayout.utils.widget.ImageFilterView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import androidx.transition.ChangeBounds
import androidx.transition.TransitionManager
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.AudioPlaybackDevice
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.feature.AudioRouteFeature
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoFactory
import com.tencent.trtc.TRTCCloudDef
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.livedata.Observer
import com.trtc.tuikit.common.util.ScreenUtil

class VideoCallerAndCalleeAcceptedView(context: Context) : ConstraintLayout(context) {
    private lateinit var rootView: ConstraintLayout
    private lateinit var imageHangup: ImageFilterView
    private lateinit var imageSwitchCamera: ImageView
    private lateinit var imageExpandView: ImageView
    private lateinit var imageBlurBackground: ImageView

    private lateinit var buttonMicrophone: ControlButton
    private lateinit var buttonAudioDevice: ControlButton
    private lateinit var buttonCamera: ControlButton

    private lateinit var audioRouteFeature: AudioRouteFeature
    private var audioDevicePopupWindow: AudioPlayoutDevicePopupView? = null
    private var defaultAudioButtonDrawable: Drawable? = null
    private val handler = Handler(Looper.getMainLooper())

    private var isBottomViewExpand: Boolean = true
    private var enableTransition: Boolean = false
    private val originalSet = ConstraintSet()
    private val rowSet = ConstraintSet()

    private var hasTriggeredSlideAnimation: Boolean = false

    private var isCameraOpenObserver = Observer<Boolean> {
        buttonCamera.imageView.isActivated = it
        buttonCamera.textView.text = when {
            it -> context.getString(R.string.tuicallkit_toast_enable_camera)
            else -> context.getString(R.string.tuicallkit_toast_disable_camera)
        }

        showSwitchCamera(it)
        showBlurBackground(it)
    }

    private fun showSwitchCamera(show: Boolean) {
        if (GlobalState.instance.disableControlButtonSet.contains(Constants.ControlButton.SwitchCamera)
            || CallManager.instance.callState.scene.get() != TUICallDefine.Scene.SINGLE_CALL) {
            imageSwitchCamera.visibility = GONE
            return
        }
        imageSwitchCamera.visibility = if (show) VISIBLE else GONE
    }

    private fun showBlurBackground(show: Boolean) {
        if (!GlobalState.instance.enableVirtualBackground
            || CallManager.instance.callState.scene.get() != TUICallDefine.Scene.SINGLE_CALL) {
            imageBlurBackground.visibility = GONE
            return
        }
        imageBlurBackground.visibility = if (show) VISIBLE else GONE
    }

    private var isMicOpenObserver = Observer<Boolean> {
        val resId = if (it) {
            R.string.tuicallkit_toast_enable_mute
        } else {
            R.string.tuicallkit_toast_disable_mute
        }
        buttonMicrophone.textView.text = context.getString(resId)
        buttonMicrophone.imageView.isActivated = it
    }

    private val audioPlayoutDeviceObserver = Observer<TUICommonDefine.AudioPlaybackDevice> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            updateAudioDeviceButtonForLegacy(it)
        }
    }

    private val selectedAudioDeviceObserver = Observer<Int> {
        updateAudioDeviceButton(it)
    }

    private val showLargeViewUserObserver = Observer<String> {
        startAnimation(it.isNullOrEmpty())
        enableTransition = true
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        this.layoutParams?.width = LayoutParams.MATCH_PARENT
        this.layoutParams?.height = LayoutParams.MATCH_PARENT
        enableTransition = false
        initView()
        registerObserver()
        initViewListener()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
        audioDevicePopupWindow?.dismiss()
        handler.removeCallbacksAndMessages(null)
    }

    private fun registerObserver() {
        CallManager.instance.mediaState.isCameraOpened.observe(isCameraOpenObserver)
        CallManager.instance.mediaState.isMicrophoneMuted.observe(isMicOpenObserver)
        CallManager.instance.viewState.showLargeViewUserId.observe(showLargeViewUserObserver)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            audioRouteFeature.register()
            CallManager.instance.mediaState.selectedAudioDevice.observe(selectedAudioDeviceObserver)
        } else {
            CallManager.instance.mediaState.audioPlayoutDevice.observe(audioPlayoutDeviceObserver)
        }
    }

    private fun unregisterObserver() {
        CallManager.instance.mediaState.isCameraOpened.removeObserver(isCameraOpenObserver)
        CallManager.instance.mediaState.isMicrophoneMuted.removeObserver(isMicOpenObserver)
        CallManager.instance.viewState.showLargeViewUserId.removeObserver(showLargeViewUserObserver)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                audioRouteFeature.unregister()
            } catch (e: Exception) {
                Logger.e("VideoCallerAndCalleeAcceptedView", "unregisterObserver: ${e.message}")
            }
            CallManager.instance.mediaState.selectedAudioDevice.removeObserver(selectedAudioDeviceObserver)
        } else {
            CallManager.instance.mediaState.audioPlayoutDevice.removeObserver(audioPlayoutDeviceObserver)
        }
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_video, this)
        rootView = findViewById(R.id.cl_view_video)
        audioRouteFeature = AudioRouteFeature(context)
        buttonMicrophone = findViewById(R.id.cb_microphone)
        buttonAudioDevice = findViewById(R.id.cb_speaker)
        buttonCamera = findViewById(R.id.cb_open_camera)

        imageHangup = findViewById(R.id.iv_hang_up)
        imageSwitchCamera = findViewById(R.id.iv_function_switch_camera)
        imageBlurBackground = findViewById(R.id.img_blur_background)
        imageExpandView = findViewById(R.id.iv_expanded)

        val isMute = CallManager.instance.mediaState.isMicrophoneMuted.get()
        buttonMicrophone.imageView.isActivated = isMute
        val micResId = if (isMute) R.string.tuicallkit_toast_disable_mute else R.string.tuicallkit_toast_enable_mute
        buttonMicrophone.textView.text = context.getString(micResId)

        defaultAudioButtonDrawable = buttonAudioDevice.imageView.drawable

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            updateAudioDeviceButton(CallManager.instance.mediaState.selectedAudioDevice.get())
        } else {
            updateAudioDeviceButtonForLegacy(CallManager.instance.mediaState.audioPlayoutDevice.get())
        }

        val buttonSet = GlobalState.instance.disableControlButtonSet
        buttonMicrophone.visibility = if (buttonSet.contains(Constants.ControlButton.Microphone)) GONE else VISIBLE
        buttonAudioDevice.visibility =
            if (buttonSet.contains(Constants.ControlButton.AudioPlaybackDevice)) GONE else VISIBLE
        buttonCamera.visibility = if (buttonSet.contains(Constants.ControlButton.Camera)) GONE else VISIBLE

        val isCameraOpened = CallManager.instance.mediaState.isCameraOpened.get()
        showSwitchCamera(isCameraOpened)
        showBlurBackground(isCameraOpened)

        imageExpandView.visibility = if (enableTransition) View.VISIBLE else View.GONE

        originalSet.clone(rootView)
        rowSet.clone(rootView)
        buildRowConstraint(rowSet)

        if (!CallManager.instance.viewState.showLargeViewUserId.get().isNullOrEmpty()) {
            startAnimation(false)
        }
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
        buttonAudioDevice.setOnClickListener {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val availableAudioDevices = CallManager.instance.mediaState.availableAudioDevices.get()
                val hasOnlyBuiltInDevices = availableAudioDevices.all {
                    it == TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE || it == TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER
                }

                if (hasOnlyBuiltInDevices) {
                    val selectedDevice = CallManager.instance.mediaState.selectedAudioDevice.get()
                    val targetDevice = if (selectedDevice == TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER) {
                        TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE
                    } else {
                        TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER
                    }
                    audioRouteFeature.setAudioRoute(targetDevice)
                } else {
                    showAudioDevicePopup()
                }
            } else {
                val currentDevice = CallManager.instance.mediaState.audioPlayoutDevice.get()
                val device = if (currentDevice == AudioPlaybackDevice.Speakerphone) {
                    AudioPlaybackDevice.Earpiece
                } else {
                    AudioPlaybackDevice.Speakerphone
                }
                CallManager.instance.selectAudioPlaybackDevice(device)
            }
        }
        buttonCamera.setOnClickListener {
            if (!buttonCamera.isEnabled) {
                return@setOnClickListener
            }
            if (CallManager.instance.mediaState.isCameraOpened.get()) {
                CallManager.instance.closeCamera()
            } else {
                val selfUser = CallManager.instance.userState.selfUser.get()
                val camera: TUICommonDefine.Camera = CallManager.instance.mediaState.isFrontCamera.get()
                val videoView = VideoFactory.instance.findVideoView(selfUser.id)

                CallManager.instance.openCamera(camera, videoView, null)
                if (CallManager.instance.callState.scene.get() != TUICallDefine.Scene.SINGLE_CALL) {
                    if (CallManager.instance.viewState.showLargeViewUserId.get() != selfUser.id) {
                        CallManager.instance.viewState.showLargeViewUserId.set(selfUser.id)
                    }
                }
            }
        }

        imageHangup.setOnClickListener {
            imageHangup.roundPercent = 1.0f
            imageHangup.setBackgroundColor(ContextCompat.getColor(context, R.color.tuicallkit_button_bg_red))
            ImageLoader.loadGif(context, imageHangup, R.drawable.tuicallkit_hangup_loading)

            disableButton(buttonMicrophone)
            disableButton(buttonAudioDevice)
            disableButton(buttonCamera)
            disableButton(imageSwitchCamera)
            disableButton(imageBlurBackground)

            CallManager.instance.hangup(null)
        }

        imageExpandView.setOnClickListener() {
            startAnimation(!isBottomViewExpand)
        }

        imageBlurBackground.setOnClickListener {
            if (!imageBlurBackground.isEnabled) {
                return@setOnClickListener
            }
            CallManager.instance.setBlurBackground(!CallManager.instance.viewState.isVirtualBackgroundOpened.get())
        }

        imageSwitchCamera.setOnClickListener() {
            if (!imageSwitchCamera.isEnabled) {
                return@setOnClickListener
            }
            var camera = TUICommonDefine.Camera.Back
            if (CallManager.instance.mediaState.isFrontCamera.get() == TUICommonDefine.Camera.Back) {
                camera = TUICommonDefine.Camera.Front
            }
            CallManager.instance.switchCamera(camera)
        }
    }

    private fun disableButton(button: View) {
        button.isEnabled = false
        button.alpha = 0.8f
    }

    private fun startAnimation(isExpand: Boolean) {
        if (CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            return
        }

        if (!enableTransition) {
            return
        }
        if (isExpand == isBottomViewExpand) {
            return
        }
        rootView.background = ContextCompat.getDrawable(context, R.drawable.tuicallkit_bg_group_call_bottom)
        isBottomViewExpand = isExpand

        val transition = ChangeBounds().apply { duration = 300 }
        TransitionManager.beginDelayedTransition(rootView, transition)
        updateButtonSize(isExpand)
        if (isExpand) {
            originalSet.applyTo(rootView)
        } else {
            rowSet.applyTo(rootView)
            imageExpandView.rotation = 180f
        }
        imageExpandView.visibility = if (enableTransition) View.VISIBLE else View.GONE
        setControlButtonTextVisible(isExpand)
    }

    private fun setControlButtonTextVisible(visible: Boolean) {
        val buttonSet = GlobalState.instance.disableControlButtonSet
        buttonMicrophone.textView.visibility =
            if (visible && !buttonSet.contains(Constants.ControlButton.Microphone)) View.VISIBLE else View.GONE
        buttonAudioDevice.textView.visibility =
            if (visible && !buttonSet.contains(Constants.ControlButton.AudioPlaybackDevice)) View.VISIBLE else View.GONE
        buttonCamera.textView.visibility =
            if (visible && !buttonSet.contains(Constants.ControlButton.Camera)) View.VISIBLE else View.GONE
    }

    private fun buildRowConstraint(set: ConstraintSet) {
        val disableButtonSet = GlobalState.instance.disableControlButtonSet

        val buttonIds = mutableListOf(imageExpandView.id).apply {
            if (!disableButtonSet.contains(Constants.ControlButton.Microphone)) {
                add(buttonMicrophone.id)
            }
            if (!disableButtonSet.contains(Constants.ControlButton.AudioPlaybackDevice)) {
                add(buttonAudioDevice.id)
            }
            if (!disableButtonSet.contains(Constants.ControlButton.Camera)) {
                add(buttonCamera.id)
            }
            add(imageHangup.id)
        }

        buttonIds.forEach {
            set.clear(it)
            set.setVisibility(it, View.VISIBLE)
            val size = if (it == imageHangup.id) ScreenUtil.dip2px(48f) else ConstraintSet.WRAP_CONTENT
            set.constrainWidth(it, size)
            set.constrainHeight(it, size)
        }
        set.createHorizontalChainRtl(
            ConstraintSet.PARENT_ID, ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.END,
            buttonIds.toIntArray(), null, ConstraintSet.CHAIN_SPREAD
        )
        val margin = ScreenUtil.dip2px(20f)
        buttonIds.forEach {
            set.connect(it, ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP, margin)
            set.connect(it, ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM, margin)
        }
        set.setMargin(imageExpandView.id, ConstraintSet.START, margin)
        set.setMargin(imageHangup.id, ConstraintSet.END, margin)
    }

    private fun updateButtonSize(isExpand: Boolean) {
        val size = if (isExpand) ScreenUtil.dip2px(60f) else ScreenUtil.dip2px(48f)
        buttonMicrophone.imageView.layoutParams?.let { it.width = size; it.height = size }
        buttonAudioDevice.imageView.layoutParams?.let { it.width = size; it.height = size }
        buttonCamera.imageView.layoutParams?.let { it.width = size; it.height = size }
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
            AudioPlaybackDevice.Speakerphone else AudioPlaybackDevice.Earpiece
        updateAudioDeviceButtonForLegacy(device)
    }

    private fun showAudioDevicePopup() {
        if (audioDevicePopupWindow == null) {
            audioDevicePopupWindow = AudioPlayoutDevicePopupView(audioRouteFeature)
        }
        audioDevicePopupWindow?.show(buttonAudioDevice, CallManager.instance.mediaState.selectedAudioDevice.get())
    }

    private fun updateAudioDeviceButtonForLegacy(device: AudioPlaybackDevice) {
        val isSpeaker = device == TUICommonDefine.AudioPlaybackDevice.Speakerphone
        buttonAudioDevice.imageView.isActivated = isSpeaker
        buttonAudioDevice.imageView.setImageResource(R.drawable.tuicallkit_bg_audio_device)

        val resId = if (isSpeaker) R.string.tuicallkit_toast_speaker else R.string.tuicallkit_toast_use_earpiece
        buttonAudioDevice.textView.text = context.getString(resId)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                touchStartY = event.y
                hasTriggeredSlideAnimation = false
            }
            MotionEvent.ACTION_MOVE -> {
                if (CallManager.instance.userState.selfUser.get().callStatus.get() != TUICallDefine.Status.Accept) {
                    return true
                }
                if (!enableTransition || hasTriggeredSlideAnimation) {
                    return true
                }
                val deltaY = event.y - touchStartY
                val threshold = 50
                if (deltaY < -threshold && !isBottomViewExpand) {
                    startAnimation(true)
                    hasTriggeredSlideAnimation = true
                } else if (deltaY > threshold && isBottomViewExpand) {
                    startAnimation(false)
                    hasTriggeredSlideAnimation = true
                }
            }
        }
        return true
    }

    private var touchStartY: Float = 0f
}