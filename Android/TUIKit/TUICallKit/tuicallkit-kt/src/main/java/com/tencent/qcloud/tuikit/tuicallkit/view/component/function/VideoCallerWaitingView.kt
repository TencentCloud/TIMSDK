package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.function.VideoCallerWaitingViewModel

class VideoCallerWaitingView(context: Context) : BaseCallView(context) {
    private var layoutCancel: LinearLayout? = null
    private var imageSwitchCamera: ImageView? = null
    private var imageViewBlur: ImageView? = null
    private var imageOpenCamera: ImageView? = null
    private var layoutBlurBackground: LinearLayout? = null
    private var textCamera: TextView? = null

    private var viewModel = VideoCallerWaitingViewModel()

    private var enableBlurBackgroundObserver = Observer<Boolean> {
        imageViewBlur?.isActivated = viewModel.enableBlurBackground.get()
    }

    init {
        initView()
        viewModel.enableBlurBackground.observe(enableBlurBackgroundObserver)
    }

    override fun clear() {
        viewModel.enableBlurBackground.removeObserver(enableBlurBackgroundObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_video_inviting, this)
        layoutCancel = findViewById(R.id.ll_cancel)
        imageSwitchCamera = findViewById(R.id.img_switch_camera)
        imageOpenCamera = findViewById(R.id.img_camera)
        textCamera = findViewById(R.id.tv_camera)
        layoutBlurBackground = findViewById(R.id.ll_blur)
        imageViewBlur = findViewById(R.id.iv_video_blur)

        imageOpenCamera?.isActivated = viewModel.isCameraOpen

        if (!viewModel.isShowVirtualBackgroundButton) {
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
        layoutCancel?.setOnClickListener { viewModel?.hangup() }
        imageSwitchCamera!!.setOnClickListener {
            viewModel.switchCamera()
        }
        imageOpenCamera?.setOnClickListener {
            if (viewModel.isCameraOpen) {
                viewModel.closeCamera()
                imageOpenCamera?.setImageResource(R.drawable.tuicallkit_ic_camera_disable)
                textCamera?.text = context.resources.getString(R.string.tuicallkit_toast_disable_camera)
                imageSwitchCamera?.isEnabled = false
                layoutBlurBackground?.isEnabled = false
            } else {
                viewModel.openCamera()
                imageOpenCamera?.setImageResource(R.drawable.tuicallkit_ic_camera_enable)
                textCamera?.text = context.resources.getString(R.string.tuicallkit_toast_enable_camera)
                imageSwitchCamera?.isEnabled = true
                layoutBlurBackground?.isEnabled = true
            }
        }
        layoutBlurBackground?.setOnClickListener {
            viewModel.setBlurBackground()
        }
    }
}