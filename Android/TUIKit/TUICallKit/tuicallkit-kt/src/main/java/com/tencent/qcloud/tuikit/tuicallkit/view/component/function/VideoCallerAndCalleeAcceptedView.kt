package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.motion.widget.MotionLayout
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView

class VideoCallerAndCalleeAcceptedView(context: Context) : BaseCallView(context) {
    private var rootLayout: MotionLayout? = null
    private var imageOpenCamera: ImageView? = null
    private var imageMute: ImageView? = null
    private var imageAudioDevice: ImageView? = null
    private var imageHangup: ImageView? = null
    private var imageSwitchCamera: ImageView? = null
    private var imageExpandView: ImageView? = null
    private var imageBlurBackground: ImageView? = null
    private var textMute: TextView? = null
    private var textAudioDevice: TextView? = null
    private var textCamera: TextView? = null

    private var isCameraOpenObserver = Observer<Boolean> {
        imageOpenCamera?.isActivated = it
        textCamera?.text = if (it) {
            context.getString(R.string.tuicallkit_toast_enable_camera)
        } else {
            context.getString(R.string.tuicallkit_toast_disable_camera)
        }

        if (it && TUICallState.instance.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            refreshButton(R.id.iv_function_switch_camera, VISIBLE)
            refreshButton(
                R.id.img_blur_background, if (TUICallState.instance.showVirtualBackgroundButton) VISIBLE else GONE
            )
        } else {
            refreshButton(R.id.iv_function_switch_camera, GONE)
            refreshButton(R.id.img_blur_background, GONE)
        }
    }

    private fun refreshButton(resId: Int, enable: Int) {
        rootLayout?.getConstraintSet(R.id.start)?.getConstraint(resId)?.propertySet?.visibility = enable
        rootLayout?.getConstraintSet(R.id.end)?.getConstraint(resId)?.propertySet?.visibility = enable
    }

    private var isMicMuteObserver = Observer<Boolean> {
        imageMute?.isActivated = it
    }

    private var isSpeakerObserver = Observer<TUICommonDefine.AudioPlaybackDevice> {
        imageAudioDevice?.isActivated = it == TUICommonDefine.AudioPlaybackDevice.Speakerphone
    }

    private val isBottomViewExpandedObserver = Observer<Boolean> {
        updateView(it)
        enableSwipeFunctionView(true)
    }

    init {
        initView()

        addObserver()
    }

    override fun clear() {
        removeObserver()
    }

    private fun addObserver() {
        TUICallState.instance.isCameraOpen.observe(isCameraOpenObserver)
        TUICallState.instance.isMicrophoneMute.observe(isMicMuteObserver)
        TUICallState.instance.audioPlayoutDevice.observe(isSpeakerObserver)
        TUICallState.instance.isBottomViewExpand.observe(isBottomViewExpandedObserver)
    }

    private fun removeObserver() {
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
        TUICallState.instance.isMicrophoneMute.removeObserver(isMicMuteObserver)
        TUICallState.instance.audioPlayoutDevice.removeObserver(isSpeakerObserver)
        TUICallState.instance.isBottomViewExpand.removeObserver(isBottomViewExpandedObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_video, this)
        rootLayout = findViewById(R.id.cl_view_video)
        imageMute = findViewById(R.id.iv_mute)
        textMute = findViewById(R.id.tv_mic)
        imageAudioDevice = findViewById(R.id.iv_speaker)
        textAudioDevice = findViewById(R.id.tv_speaker)
        imageOpenCamera = findViewById(R.id.iv_camera)
        imageHangup = findViewById(R.id.iv_hang_up)
        textCamera = findViewById(R.id.tv_video_camera)
        imageSwitchCamera = findViewById(R.id.iv_function_switch_camera)
        imageBlurBackground = findViewById(R.id.img_blur_background)
        imageExpandView = findViewById(R.id.iv_expanded)
        imageExpandView?.visibility = INVISIBLE

        imageOpenCamera?.isActivated = TUICallState.instance.isCameraOpen.get() == true
        imageMute?.isActivated = TUICallState.instance.isMicrophoneMute.get() == true
        imageAudioDevice?.isActivated =
            TUICallState.instance.audioPlayoutDevice.get() == TUICommonDefine.AudioPlaybackDevice.Speakerphone

        textCamera?.text = if (TUICallState.instance.isCameraOpen.get()) {
            context.getString(R.string.tuicallkit_toast_enable_camera)
        } else {
            context.getString(R.string.tuicallkit_toast_disable_camera)
        }

        if (TUICallState.instance.audioPlayoutDevice.get() == TUICommonDefine.AudioPlaybackDevice.Speakerphone) {
            textAudioDevice?.text = context.getString(R.string.tuicallkit_toast_speaker)
        } else {
            textAudioDevice?.text = context.getString(R.string.tuicallkit_toast_use_earpiece)
        }

        if (TUICallState.instance.scene.get() == TUICallDefine.Scene.SINGLE_CALL
            && TUICallState.instance.isCameraOpen.get()
        ) {
            imageSwitchCamera?.visibility = VISIBLE
            imageBlurBackground?.visibility = if (TUICallState.instance.showVirtualBackgroundButton) VISIBLE else GONE
        } else {
            imageSwitchCamera?.visibility = GONE
            imageBlurBackground?.visibility = GONE
        }

        if (!TUICallState.instance.isBottomViewExpand.get() && TUICallState.instance.showLargeViewUserId.get() != null) {
            TUICallState.instance.isBottomViewExpand.set(!TUICallState.instance.isBottomViewExpand.get())
        }
        initViewListener()
        enableSwipeFunctionView(false)
    }

    private fun enableSwipeFunctionView(enable: Boolean) {
        if (TUICallState.instance.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            rootLayout?.enableTransition(R.id.video_function_view_transition, false)
            return
        }
        rootLayout?.enableTransition(R.id.video_function_view_transition, enable)
    }

    private fun initViewListener() {
        imageMute?.setOnClickListener {
            val resId = if (TUICallState.instance.isMicrophoneMute.get() == true) {
                EngineManager.instance.openMicrophone(null)
                R.string.tuicallkit_toast_disable_mute
            } else {
                EngineManager.instance.closeMicrophone()
                R.string.tuicallkit_toast_enable_mute
            }
            textMute?.text = context.getString(resId)
        }
        imageAudioDevice?.setOnClickListener {
            var resId: Int
            if (TUICallState.instance.audioPlayoutDevice.get() == TUICommonDefine.AudioPlaybackDevice.Speakerphone) {
                EngineManager.instance.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Earpiece)
                resId = R.string.tuicallkit_toast_use_earpiece
            } else {
                EngineManager.instance.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Speakerphone)
                resId = R.string.tuicallkit_toast_speaker
            }
            textAudioDevice?.text = context.getString(resId)
        }
        imageOpenCamera?.setOnClickListener {
            if (TUICallState.instance.isCameraOpen.get() == true) {
                EngineManager.instance.closeCamera()
            } else {
                var camera: TUICommonDefine.Camera = TUICallState.instance.isFrontCamera.get()
                val videoView = VideoViewFactory.instance.findVideoView(TUICallState.instance.selfUser.get().id)
                EngineManager.instance.openCamera(camera, videoView?.getVideoView(), null)

                if (TUICallState.instance.scene.get() == TUICallDefine.Scene.GROUP_CALL) {
                    if (TUICallState.instance.showLargeViewUserId.get() != TUICallState.instance.selfUser.get().id) {
                        TUICallState.instance.showLargeViewUserId.set(TUICallState.instance.selfUser.get().id)
                    }
                }
            }
        }

        imageHangup?.setOnClickListener { EngineManager.instance.hangup(null) }

        imageExpandView?.setOnClickListener() {
            TUICallState.instance.isBottomViewExpand.set(!TUICallState.instance.isBottomViewExpand.get())
        }

        imageBlurBackground?.setOnClickListener {
            EngineManager.instance.setBlurBackground(!TUICallState.instance.enableBlurBackground.get())
        }

        imageSwitchCamera?.setOnClickListener() {
            var camera = TUICommonDefine.Camera.Back
            if (TUICallState.instance.isFrontCamera.get() == TUICommonDefine.Camera.Back) {
                camera = TUICommonDefine.Camera.Front
            }
            EngineManager.instance.switchCamera(camera)
        }

        rootLayout?.addTransitionListener(object : MotionLayout.TransitionListener {
            override fun onTransitionStarted(motionLayout: MotionLayout, startId: Int, endId: Int) {
                rootLayout?.background = context.resources.getDrawable(R.drawable.tuicallkit_bg_group_call_bottom)
            }

            override fun onTransitionChange(motionLayout: MotionLayout, startId: Int, endId: Int, progress: Float) {}

            override fun onTransitionCompleted(motionLayout: MotionLayout, currentId: Int) {
                rootLayout?.getConstraintSet(R.id.start)?.getConstraint(R.id.iv_expanded)?.propertySet?.visibility =
                    VISIBLE
            }

            override fun onTransitionTrigger(motionLayout: MotionLayout, id: Int, positive: Boolean, progress: Float) {}
        })
    }

    private fun updateView(isExpand: Boolean) {
        if (TUICallState.instance.scene?.get() == TUICallDefine.Scene.SINGLE_CALL) {
            return
        }
        if (isExpand) {
            rootLayout?.transitionToStart()
            rootLayout?.getConstraintSet(R.id.start)?.getConstraint(R.id.iv_expanded)?.propertySet?.visibility = VISIBLE
        } else {
            rootLayout?.transitionToEnd()
        }
    }
}