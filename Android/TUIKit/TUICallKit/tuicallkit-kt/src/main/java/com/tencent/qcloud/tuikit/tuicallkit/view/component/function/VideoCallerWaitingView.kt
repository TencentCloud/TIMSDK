package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView

class VideoCallerWaitingView(context: Context) : BaseCallView(context) {
    private var layoutCancel: LinearLayout? = null
    private var imageSwitchCamera: ImageView? = null
    private var imageViewBlur: ImageView? = null
    private var imageOpenCamera: ImageView? = null
    private var layoutBlurBackground: LinearLayout? = null
    private var textCamera: TextView? = null

    private var enableBlurBackgroundObserver = Observer<Boolean> {
        imageViewBlur?.isActivated = TUICallState.instance.enableBlurBackground.get()
    }

    private var isCameraOpenObserver = Observer<Boolean> {
        imageOpenCamera?.isActivated = TUICallState.instance.isCameraOpen.get()
    }

    init {
        initView()
        TUICallState.instance.enableBlurBackground.observe(enableBlurBackgroundObserver)
        TUICallState.instance.isCameraOpen.observe(isCameraOpenObserver)
    }

    override fun clear() {
        TUICallState.instance.enableBlurBackground.removeObserver(enableBlurBackgroundObserver)
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_video_inviting, this)
        layoutCancel = findViewById(R.id.ll_cancel)
        imageSwitchCamera = findViewById(R.id.img_switch_camera)
        imageOpenCamera = findViewById(R.id.img_camera)
        textCamera = findViewById(R.id.tv_camera)
        layoutBlurBackground = findViewById(R.id.ll_blur)
        imageViewBlur = findViewById(R.id.iv_video_blur)

        imageOpenCamera?.isActivated = TUICallState.instance.isCameraOpen.get()

        if (!TUICallState.instance.showVirtualBackgroundButton) {
            layoutBlurBackground?.visibility = GONE
            reLayoutView()
        }

        initViewListener()
    }

    private fun reLayoutView() {
        val constraintLayout: ConstraintLayout = findViewById(R.id.constraint_layout)
        val constraintSet: ConstraintSet = ConstraintSet()
        constraintSet.clone(constraintLayout)

        constraintSet.connect(R.id.ll_cancel, ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP)

        constraintSet.connect(R.id.ll_switch, ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.START)
        constraintSet.connect(R.id.ll_switch, ConstraintSet.END, R.id.ll_cancel, ConstraintSet.START)
        constraintSet.connect(R.id.ll_switch, ConstraintSet.TOP, R.id.ll_cancel, ConstraintSet.TOP)
        constraintSet.connect(R.id.ll_switch, ConstraintSet.BOTTOM, R.id.ll_cancel, ConstraintSet.BOTTOM)

        constraintSet.connect(R.id.ll_camera, ConstraintSet.START, R.id.ll_cancel, ConstraintSet.END)
        constraintSet.connect(R.id.ll_camera, ConstraintSet.END, ConstraintSet.PARENT_ID, ConstraintSet.END)
        constraintSet.connect(R.id.ll_camera, ConstraintSet.TOP, R.id.ll_cancel, ConstraintSet.TOP)
        constraintSet.connect(R.id.ll_camera, ConstraintSet.BOTTOM, R.id.ll_cancel, ConstraintSet.BOTTOM)

        constraintSet.applyTo(constraintLayout)
    }

    private fun initViewListener() {
        layoutCancel?.setOnClickListener { EngineManager.instance.hangup(null) }
        imageSwitchCamera!!.setOnClickListener {
            var camera = TUICommonDefine.Camera.Back
            if (TUICallState.instance.isFrontCamera.get() == TUICommonDefine.Camera.Back) {
                camera = TUICommonDefine.Camera.Front
            }
            EngineManager.instance.switchCamera(camera)
        }
        imageOpenCamera?.setOnClickListener {
            if (TUICallState.instance.isCameraOpen.get()) {
                EngineManager.instance.closeCamera()

                imageOpenCamera?.setImageResource(R.drawable.tuicallkit_ic_camera_disable)
                textCamera?.text = context.resources.getString(R.string.tuicallkit_toast_disable_camera)
                imageSwitchCamera?.isEnabled = false
                layoutBlurBackground?.isEnabled = false
            } else {
                val camera = TUICallState.instance.isFrontCamera.get()
                val videoView = VideoViewFactory.instance.findVideoView(TUICallState.instance.selfUser.get().id)
                EngineManager.instance.openCamera(camera, videoView?.getVideoView(), null)

                imageOpenCamera?.setImageResource(R.drawable.tuicallkit_ic_camera_enable)
                textCamera?.text = context.resources.getString(R.string.tuicallkit_toast_enable_camera)
                imageSwitchCamera?.isEnabled = true
                layoutBlurBackground?.isEnabled = true
            }
        }
        layoutBlurBackground?.setOnClickListener {
            EngineManager.instance.setBlurBackground(!TUICallState.instance.enableBlurBackground.get())
        }
    }
}