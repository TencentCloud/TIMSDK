package io.trtc.tuikit.atomicx.callview.public.controls

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.RelativeLayout
import androidx.constraintlayout.utils.widget.ImageFilterView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import androidx.transition.ChangeBounds
import androidx.transition.TransitionManager
import com.trtc.tuikit.common.imageloader.ImageLoader
import android.graphics.drawable.Drawable
import android.view.MotionEvent
import com.tencent.cloud.tuikit.engine.call.TUICallEngine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import io.trtc.tuikit.atomicx.callview.core.common.Constants
import com.trtc.tuikit.common.util.ScreenUtil
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.callview.core.common.Constants.BLUR_LEVEL_CLOSE
import io.trtc.tuikit.atomicx.callview.core.common.Constants.BLUR_LEVEL_HIGH
import io.trtc.tuikit.atomicx.callview.core.common.utils.Logger
import io.trtc.tuikit.atomicx.callview.core.common.utils.PermissionRequest
import io.trtc.tuikit.atomicx.callview.core.common.widget.ControlButton
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantStatus
import io.trtc.tuikit.atomicxcore.api.device.AudioRoute
import io.trtc.tuikit.atomicxcore.api.device.DeviceStatus
import io.trtc.tuikit.atomicxcore.api.device.DeviceStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.supervisorScope
import java.util.concurrent.CopyOnWriteArraySet

class VideoCallerAndCalleeAcceptedView(context: Context) : RelativeLayout(context) {
    private var subscribeStateJob: Job? = null

    private lateinit var rootView: ConstraintLayout
    private lateinit var imageHangup: ImageFilterView
    private lateinit var imageSwitchCamera: ImageView
    private lateinit var imageExpandView: ImageView
    private lateinit var imageBlurBackground: ImageView

    private lateinit var buttonMicrophone: ControlButton
    private lateinit var buttonAudioDevice: ControlButton
    private lateinit var buttonCamera: ControlButton

    private var defaultAudioButtonDrawable: Drawable? = null

    private var isBottomViewExpand: Boolean = false
    private var enableTransition: Boolean = false
    private val originalSet = ConstraintSet()
    private val rowSet = ConstraintSet()

    private var hasTriggeredSlideAnimation: Boolean = false
    private var isEnableBlurBackground:Boolean = false

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        this.layoutParams?.width = LayoutParams.MATCH_PARENT
        this.layoutParams?.height = LayoutParams.MATCH_PARENT
        enableTransition = true
        initView()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        subscribeStateJob?.cancel()
    }

    private fun registerObserver() {
        subscribeStateJob = CoroutineScope(Dispatchers.Main).launch {
            supervisorScope {
                launch { observeCameraStatus() }
                launch { observeMicrophoneStatus() }
                launch { observeAudioRoute() }
            }
        }
    }

    private suspend fun observeCameraStatus() {
        DeviceStore.shared().deviceState.cameraStatus.collect { cameraStatus ->
            val cameraIsOpened = (cameraStatus == DeviceStatus.ON)
            buttonCamera.imageView.isActivated = cameraIsOpened
            buttonCamera.textView.text = when {
                cameraIsOpened -> context.getString(R.string.callview_toast_enable_camera)
                else -> context.getString(R.string.callview_toast_disable_camera)
            }
            updateSwitchCameraAndBlurBackgroundButton(cameraIsOpened)
        }
    }

    private suspend fun observeMicrophoneStatus() {
        DeviceStore.shared().deviceState.microphoneStatus.collect { microphoneStatus ->
            val isMute = microphoneStatus == DeviceStatus.OFF
            val resId = if (isMute) {
                R.string.callview_toast_enable_mute
            } else {
                R.string.callview_toast_disable_mute
            }
            buttonMicrophone.textView.text = context.getString(resId)
            buttonMicrophone.imageView.isActivated = isMute
        }
    }

    private suspend fun observeAudioRoute() {
        DeviceStore.shared().deviceState.currentAudioRoute.collect { audioRoute ->
            updateAudioRouteButton(audioRoute)
        }
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.callview_function_view_video, this)
        rootView = findViewById(R.id.cl_view_video)
        buttonMicrophone = findViewById(R.id.cb_microphone)
        buttonAudioDevice = findViewById(R.id.cb_speaker)
        buttonCamera = findViewById(R.id.cb_open_camera)

        imageHangup = findViewById(R.id.iv_hang_up)
        imageSwitchCamera = findViewById(R.id.iv_function_switch_camera)
        imageBlurBackground = findViewById(R.id.img_blur_background)
        imageExpandView = findViewById(R.id.iv_expanded)

        val isMute = DeviceStore.shared().deviceState.microphoneStatus.value == DeviceStatus.OFF
        buttonMicrophone.imageView.isActivated = isMute
        val micResId = if (isMute) R.string.callview_toast_disable_mute else R.string.callview_toast_enable_mute
        buttonMicrophone.textView.text = context.getString(micResId)
        val currentRoute = DeviceStore.shared().deviceState.currentAudioRoute.value
        updateAudioRouteButton(currentRoute)
        defaultAudioButtonDrawable = buttonAudioDevice.imageView.drawable
        buttonMicrophone.visibility = VISIBLE
        buttonAudioDevice.visibility = VISIBLE
        buttonCamera.visibility = VISIBLE
        imageExpandView.visibility = if (isMultiCall()) View.VISIBLE else View.GONE

        val isCameraOpened = (DeviceStore.shared().deviceState.cameraStatus.value == DeviceStatus.ON)
        updateSwitchCameraAndBlurBackgroundButton(isCameraOpened)
        originalSet.clone(rootView)
        rowSet.clone(rootView)
        buildRowConstraint(rowSet)
        startAnimation(true)

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
            val isMicrophoneOpen = (DeviceStore.shared().deviceState.microphoneStatus.value == DeviceStatus.ON)
            if (isMicrophoneOpen) {
                DeviceStore.shared().closeLocalMicrophone()
            } else {
                DeviceStore.shared().openLocalMicrophone(null)
            }
        }
        buttonAudioDevice.setOnClickListener {
            val currentAudioRoute = DeviceStore.shared().deviceState.currentAudioRoute.value
            if (currentAudioRoute == AudioRoute.SPEAKERPHONE) {
                DeviceStore.shared().setAudioRoute(AudioRoute.EARPIECE)
            } else {
                DeviceStore.shared().setAudioRoute(AudioRoute.SPEAKERPHONE)
            }
        }
        buttonCamera.setOnClickListener {
            if (!buttonCamera.isEnabled) {
                return@setOnClickListener
            }
            if (DeviceStore.shared().deviceState.cameraStatus.value == DeviceStatus.ON) {
                DeviceStore.shared().closeLocalCamera()
            } else {
                openLocalCamera()
            }
        }

        imageHangup.setOnClickListener {
            imageHangup.roundPercent = 1.0f
            imageHangup.setBackgroundColor(ContextCompat.getColor(context, R.color.callview_button_bg_red))
            ImageLoader.loadGif(context, imageHangup, R.drawable.callview_hangup_loading)

            disableButton(buttonMicrophone)
            disableButton(buttonAudioDevice)
            disableButton(buttonCamera)
            disableButton(imageSwitchCamera)
            disableButton(imageBlurBackground)

            CallStore.shared.hangup(null)
        }

        imageExpandView.setOnClickListener() {
            startAnimation(!isBottomViewExpand)
        }

        imageBlurBackground.setOnClickListener {
            if (!imageBlurBackground.isEnabled) {
                return@setOnClickListener
            }
            enableBlurBackground(!isEnableBlurBackground)
        }

        imageSwitchCamera.setOnClickListener() {
            if (!imageSwitchCamera.isEnabled) {
                return@setOnClickListener
            }
            val isFront = DeviceStore.shared().deviceState.isFrontCamera.value
            DeviceStore.shared().switchCamera(!isFront)
        }
    }

    private fun disableButton(button: View) {
        button.isEnabled = false
        button.alpha = 0.8f
    }

    private fun startAnimation(isExpand: Boolean) {
        if (!isMultiCall()) {
            return
        }
        if (!enableTransition) {
            return
        }
        if (isExpand == isBottomViewExpand) {
            return
        }
        rootView.background = ContextCompat.getDrawable(context, R.drawable.callview_bg_group_call_bottom)
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
        val isCameraOpen = DeviceStore.shared().deviceState.cameraStatus.value == DeviceStatus.ON
        updateSwitchCameraAndBlurBackgroundButton(isCameraOpen)
        imageExpandView.visibility = if (enableTransition) View.VISIBLE else View.GONE
        setControlButtonTextVisible(isExpand)
    }

    private fun setControlButtonTextVisible(visible: Boolean) {
        buttonMicrophone.textView.visibility = if (visible) View.VISIBLE else View.GONE
        buttonAudioDevice.textView.visibility = if (visible) View.VISIBLE else View.GONE
        buttonCamera.textView.visibility = if (visible) View.VISIBLE else View.GONE
    }

    private fun updateButtonSize(isExpand: Boolean) {
        val size = if (isExpand) ScreenUtil.dip2px(60f) else ScreenUtil.dip2px(48f)
        buttonMicrophone.imageView.layoutParams?.let { it.width = size; it.height = size }
        buttonAudioDevice.imageView.layoutParams?.let { it.width = size; it.height = size }
        buttonCamera.imageView.layoutParams?.let { it.width = size; it.height = size }
    }

    private fun buildRowConstraint(set: ConstraintSet) {
        val disableButtonSet: MutableSet<Constants.ControlButton> = CopyOnWriteArraySet()

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

    override fun onTouchEvent(event: MotionEvent): Boolean {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                touchStartY = event.y
                hasTriggeredSlideAnimation = false
            }

            MotionEvent.ACTION_MOVE -> {
                val selfUser = CallStore.shared.observerState.selfInfo.value.copy()
                if (selfUser.status != CallParticipantStatus.Accept) {
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

    private fun enableBlurBackground(enable: Boolean) {
        Logger.i("setBlurBackground, enable: $enable")
        val level = if (enable) BLUR_LEVEL_HIGH else BLUR_LEVEL_CLOSE
        isEnableBlurBackground = enable
        TUICallEngine.createInstance(context).setBlurBackground(level, object : TUICommonDefine.Callback {
            override fun onSuccess() {
                Logger.i("setBlurBackground success.")
            }

            override fun onError(errCode: Int, errMsg: String?) {
                isEnableBlurBackground = false
                Logger.e("setBlurBackground failed, errCode: $errCode, errMsg: $errMsg")
            }
        })
    }

    private fun openLocalCamera() {
        PermissionRequest.requestCameraPermission(context, object : PermissionCallback() {
            override fun onGranted() {
                val isFrontCamera = DeviceStore.shared().deviceState.isFrontCamera.value
                DeviceStore.shared().openLocalCamera(isFrontCamera, null)
            }

            override fun onDenied() {
                Logger.e("openCamera failed, errMsg: camera permission denied")
            }
        })
    }

    private fun isMultiCall(): Boolean {
        val inviteeIdListSize = CallStore.shared.observerState.activeCall.value.inviteeIds.size
        val chatGroupId = CallStore.shared.observerState.activeCall.value.chatGroupId
        return chatGroupId.isNotEmpty() || inviteeIdListSize > 1
    }

    private fun updateSwitchCameraAndBlurBackgroundButton(cameraIsOpened: Boolean) {
        val visibility = if (cameraIsOpened && (!isMultiCall() || isBottomViewExpand)) VISIBLE else GONE
        imageSwitchCamera.visibility = visibility
        imageBlurBackground.visibility = visibility
    }
}