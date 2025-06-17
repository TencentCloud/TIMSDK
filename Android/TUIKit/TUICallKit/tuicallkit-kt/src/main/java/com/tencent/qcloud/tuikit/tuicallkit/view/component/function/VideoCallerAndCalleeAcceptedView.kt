package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.constraintlayout.motion.widget.MotionLayout
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.AudioPlaybackDevice
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoFactory
import com.trtc.tuikit.common.livedata.Observer

class VideoCallerAndCalleeAcceptedView(context: Context) : RelativeLayout(context) {
    lateinit var rootView: MotionLayout
    private lateinit var imageHangup: ImageView
    private lateinit var imageSwitchCamera: ImageView
    private lateinit var imageExpandView: ImageView
    private lateinit var imageBlurBackground: ImageView
    private lateinit var imageMic: ImageView
    private lateinit var imageSpeaker: ImageView
    private lateinit var imageCamera: ImageView
    private lateinit var textMic: TextView
    private lateinit var textSpeaker: TextView
    private lateinit var textCamera: TextView

    private var isBottomViewExpand: Boolean = true

    private var isCameraOpenObserver = Observer<Boolean> {
        imageCamera.isActivated = it
        textCamera.text = getCameraHint(it)

        if (it && CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            imageSwitchCamera.visibility = VISIBLE
            imageBlurBackground.visibility = if (GlobalState.instance.enableVirtualBackground) VISIBLE else GONE
        } else {
            imageSwitchCamera.visibility = GONE
            imageBlurBackground.visibility = GONE
        }
    }

    private val isMicOpenObserver = Observer<Boolean> {
        val resId = if (it) {
            R.string.tuicallkit_toast_enable_mute
        } else {
            R.string.tuicallkit_toast_disable_mute
        }
        textMic.text = context.getString(resId)
        imageMic.isActivated = it
    }

    private val showLargeViewUserObserver = Observer<String> {
        startAnimation(it.isNullOrEmpty())
        enableSwipeFunctionView(true)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        this.layoutParams?.width = LayoutParams.MATCH_PARENT
        this.layoutParams?.height = LayoutParams.MATCH_PARENT
        initView()
        enableSwipeFunctionView(false)
        registerObserver()
        initViewListener()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
    }

    private fun registerObserver() {
        CallManager.instance.mediaState.isCameraOpened.observe(isCameraOpenObserver)
        CallManager.instance.mediaState.isMicrophoneMuted.observe(isMicOpenObserver)
        CallManager.instance.viewState.showLargeViewUserId.observe(showLargeViewUserObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.mediaState.isCameraOpened.removeObserver(isCameraOpenObserver)
        CallManager.instance.mediaState.isMicrophoneMuted.removeObserver(isMicOpenObserver)
        CallManager.instance.viewState.showLargeViewUserId.removeObserver(showLargeViewUserObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_video, this)
        rootView = findViewById(R.id.cl_view_video)
        imageMic = findViewById(R.id.iv_mic)
        textMic = findViewById(R.id.tv_mic)
        imageSpeaker = findViewById(R.id.iv_speaker)
        textSpeaker = findViewById(R.id.tv_speaker)
        imageCamera = findViewById(R.id.iv_camera)
        textCamera = findViewById(R.id.tv_video_camera)

        imageHangup = findViewById(R.id.iv_hang_up)
        imageSwitchCamera = findViewById(R.id.iv_function_switch_camera)
        imageBlurBackground = findViewById(R.id.img_blur_background)
        imageExpandView = findViewById(R.id.iv_expanded)

        val isMute = CallManager.instance.mediaState.isMicrophoneMuted.get()
        imageMic.isActivated = isMute
        val micResId = if (isMute) R.string.tuicallkit_toast_disable_mute else R.string.tuicallkit_toast_enable_mute
        textMic.text = context.getString(micResId)

        val isSpeaker = CallManager.instance.mediaState.audioPlayoutDevice.get() == AudioPlaybackDevice.Speakerphone
        val speakerResId = if (isSpeaker) R.string.tuicallkit_toast_speaker else R.string.tuicallkit_toast_use_earpiece
        imageSpeaker.isActivated = isSpeaker
        textSpeaker.text = context.getString(speakerResId)

        val isCameraOpened = CallManager.instance.mediaState.isCameraOpened.get()
        if (CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL && isCameraOpened
        ) {
            imageSwitchCamera.visibility = VISIBLE
            imageBlurBackground.visibility = if (GlobalState.instance.enableVirtualBackground) VISIBLE else GONE
        } else {
            imageSwitchCamera.visibility = GONE
            imageBlurBackground.visibility = GONE
        }

        if (!CallManager.instance.viewState.showLargeViewUserId.get().isNullOrEmpty()) {
            startAnimation(false)
        }
    }

    private fun getCameraHint(isCameraOpened: Boolean): String {
        return when {
            isCameraOpened -> context.getString(R.string.tuicallkit_toast_enable_camera)
            else -> context.getString(R.string.tuicallkit_toast_disable_camera)
        }
    }

    private fun initViewListener() {
        imageMic.setOnClickListener {
            if (CallManager.instance.mediaState.isMicrophoneMuted.get()) {
                CallManager.instance.openMicrophone(null)
            } else {
                CallManager.instance.closeMicrophone()
            }
        }
        imageSpeaker.setOnClickListener {
            val device =
                if (CallManager.instance.mediaState.audioPlayoutDevice.get() == AudioPlaybackDevice.Speakerphone) {
                    AudioPlaybackDevice.Earpiece
                } else {
                    AudioPlaybackDevice.Speakerphone
                }
            val resId = if (device == AudioPlaybackDevice.Speakerphone) {
                R.string.tuicallkit_toast_speaker
            } else {
                R.string.tuicallkit_toast_use_earpiece
            }

            CallManager.instance.selectAudioPlaybackDevice(device)
            textSpeaker.text = context.getString(resId)
            imageSpeaker.isActivated = device == AudioPlaybackDevice.Speakerphone
        }
        imageCamera.setOnClickListener {
            if (CallManager.instance.mediaState.isCameraOpened.get()) {
                CallManager.instance.closeCamera()
            } else {
                val selfUser = CallManager.instance.userState.selfUser.get()
                val camera: TUICommonDefine.Camera = CallManager.instance.mediaState.isFrontCamera.get()
                val videoView = VideoFactory.instance.findVideoView(selfUser.id)

                CallManager.instance.openCamera(camera, videoView, null)
                if (CallManager.instance.callState.scene.get() == TUICallDefine.Scene.GROUP_CALL) {
                    if (CallManager.instance.viewState.showLargeViewUserId.get() != selfUser.id) {
                        CallManager.instance.viewState.showLargeViewUserId.set(selfUser.id)
                    }
                }
            }
        }

        imageHangup.setOnClickListener {
            CallManager.instance.hangup(null)
        }

        imageExpandView.setOnClickListener() {
            startAnimation(!isBottomViewExpand)
        }

        imageBlurBackground.setOnClickListener {
            CallManager.instance.setBlurBackground(!CallManager.instance.viewState.isVirtualBackgroundOpened.get())
        }

        imageSwitchCamera.setOnClickListener() {
            var camera = TUICommonDefine.Camera.Back
            if (CallManager.instance.mediaState.isFrontCamera.get() == TUICommonDefine.Camera.Back) {
                camera = TUICommonDefine.Camera.Front
            }
            CallManager.instance.switchCamera(camera)
        }
    }

    private fun startAnimation(isExpand: Boolean) {
        if (CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            return
        }
        if (rootView.getTransition(R.id.video_function_view_transition)?.isEnabled == false) {
            return
        }

        if (isExpand) {
            rootView.transitionToStart()
            rootView.getConstraintSet(R.id.start)?.getConstraint(R.id.iv_expanded)?.propertySet?.visibility = VISIBLE
        } else {
            rootView.transitionToEnd()
        }
        rootView.background = ContextCompat.getDrawable(context, R.drawable.tuicallkit_bg_group_call_bottom)
        isBottomViewExpand = isExpand
    }

    private fun enableSwipeFunctionView(enable: Boolean) {
        val enableSwipe = (CallManager.instance.callState.scene.get() != TUICallDefine.Scene.SINGLE_CALL) && enable
        rootView.enableTransition(R.id.video_function_view_transition, enableSwipe)
    }
}