package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoFactory
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.livedata.Observer
import com.trtc.tuikit.common.util.ScreenUtil

class VideoCallerWaitingView(context: Context) : ConstraintLayout(context) {
    private lateinit var buttonCancel: ControlButton
    private lateinit var buttonSwitchCamera: ControlButton
    private lateinit var buttonCamera: ControlButton
    private lateinit var buttonBlurBackground: ControlButton

    private var isCameraOpenObserver = Observer<Boolean> {
        buttonCamera.imageView.isActivated = it
    }
    private var isVirtualBackgroundObserver = Observer<Boolean> {
        buttonBlurBackground.imageView.isActivated = it
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
    }

    private fun registerObserver() {
        CallManager.instance.viewState.isVirtualBackgroundOpened.observe(isVirtualBackgroundObserver)
        CallManager.instance.mediaState.isCameraOpened.observe(isCameraOpenObserver)
    }

    private fun unregisterObserver() {
        CallManager.instance.viewState.isVirtualBackgroundOpened.removeObserver(isVirtualBackgroundObserver)
        CallManager.instance.mediaState.isCameraOpened.removeObserver(isCameraOpenObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_video_inviting, this)
        buttonCancel = findViewById(R.id.cb_cancel)
        buttonCamera = findViewById(R.id.cb_camera)
        buttonSwitchCamera = findViewById(R.id.cb_switch_camera)
        buttonBlurBackground = findViewById(R.id.cb_blur)

        val buttonSet = GlobalState.instance.disableControlButtonSet
        buttonSwitchCamera.visibility = if (buttonSet.contains(Constants.ControlButton.SwitchCamera)) GONE else VISIBLE
        buttonCamera.visibility = if (buttonSet.contains(Constants.ControlButton.Camera)) GONE else VISIBLE

        buttonCamera.imageView.isActivated = CallManager.instance.mediaState.isCameraOpened.get()
        if (!GlobalState.instance.enableVirtualBackground) {
            buttonBlurBackground.visibility = GONE
            buildRowConstraint()
        }

        initViewListener()
    }

    private fun buildRowConstraint() {
        val disableButtonSet = GlobalState.instance.disableControlButtonSet
        val buttonIds = mutableListOf<Int>().apply {
            if (!disableButtonSet.contains(Constants.ControlButton.SwitchCamera)) {
                add(buttonSwitchCamera.id)
            }
            add(buttonCancel.id)
            if (!disableButtonSet.contains(Constants.ControlButton.Camera)) {
                add(buttonCamera.id)
            }
        }

        val rootView: ConstraintLayout = findViewById(R.id.constraint_layout)
        val rowSet = ConstraintSet()
        rowSet.clone(rootView)

        buttonIds.forEach {
            rowSet.clear(it)
            rowSet.setVisibility(it, View.VISIBLE)
            rowSet.constrainWidth(it, ConstraintSet.WRAP_CONTENT)
            rowSet.constrainHeight(it, ConstraintSet.WRAP_CONTENT)
        }
        if (buttonIds.size >= 2) {
            rowSet.createHorizontalChainRtl(
                ConstraintSet.PARENT_ID, ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.END,
                buttonIds.toIntArray(), null, ConstraintSet.CHAIN_SPREAD
            )
        } else {
            rowSet.connect(buttonCancel.id, ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.START)
            rowSet.connect(buttonCancel.id, ConstraintSet.END, ConstraintSet.PARENT_ID, ConstraintSet.END)
        }
        val margin = ScreenUtil.dip2px(20f)
        buttonIds.forEach { id ->
            rowSet.connect(id, ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP, margin)
            rowSet.connect(id, ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM, margin)
        }
        rowSet.applyTo(rootView)
    }

    private fun initViewListener() {
        buttonCancel.setOnClickListener {
            buttonCancel.imageView.roundPercent = 1.0f
            buttonCancel.imageView.setBackgroundColor(ContextCompat.getColor(context, R.color.tuicallkit_button_bg_red))
            ImageLoader.loadGif(context, buttonCancel.imageView, R.drawable.tuicallkit_hangup_loading)
            disableButton(buttonCamera)
            disableButton(buttonSwitchCamera)
            disableButton(buttonBlurBackground)
            CallManager.instance.hangup(null)
        }
        buttonSwitchCamera.setOnClickListener {
            if (!buttonSwitchCamera.isEnabled) {
                return@setOnClickListener
            }
            var camera = TUICommonDefine.Camera.Back
            if (CallManager.instance.mediaState.isFrontCamera.get() == TUICommonDefine.Camera.Back) {
                camera = TUICommonDefine.Camera.Front
            }
            CallManager.instance.switchCamera(camera)
        }
        buttonCamera.setOnClickListener {
            if (!buttonCamera.isEnabled) {
                return@setOnClickListener
            }
            val isCameraOpened = CallManager.instance.mediaState.isCameraOpened.get()
            buttonCamera.imageView.isActivated = !isCameraOpened
            buttonSwitchCamera.imageView.isActivated = !isCameraOpened
            buttonBlurBackground.imageView.isActivated = !isCameraOpened

            if (isCameraOpened) {
                CallManager.instance.closeCamera()
                buttonCamera.textView.text = context.resources.getString(R.string.tuicallkit_toast_disable_camera)
            } else {
                val camera = CallManager.instance.mediaState.isFrontCamera.get()
                val videoView = VideoFactory.instance.findVideoView(CallManager.instance.userState.selfUser.get().id)
                CallManager.instance.openCamera(camera, videoView, null)
                buttonCamera.textView.text = context.resources.getString(R.string.tuicallkit_toast_enable_camera)
            }
        }
        buttonBlurBackground.setOnClickListener {
            if (!buttonBlurBackground.isEnabled) {
                return@setOnClickListener
            }
            CallManager.instance.setBlurBackground(!CallManager.instance.viewState.isVirtualBackgroundOpened.get())
        }
    }

    private fun disableButton(button: View) {
        button.isEnabled = false
        button.alpha = 0.8f
    }
}