package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoFactory
import com.trtc.tuikit.common.livedata.Observer

class VideoCallerWaitingView(context: Context) : RelativeLayout(context) {
    private lateinit var layoutCancel: LinearLayout
    private lateinit var imageSwitchCamera: ImageView
    private lateinit var imageViewBlur: ImageView
    private lateinit var imageOpenCamera: ImageView
    private lateinit var layoutBlurBackground: LinearLayout
    private lateinit var textCamera: TextView

    private var isCameraOpenObserver = Observer<Boolean> {
        imageOpenCamera.isActivated = it
    }
    private var isVirtualBackgroundObserver = Observer<Boolean> {
        imageViewBlur.isActivated = it
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
        layoutCancel = findViewById(R.id.ll_cancel)
        imageSwitchCamera = findViewById(R.id.img_switch_camera)
        imageOpenCamera = findViewById(R.id.img_camera)
        textCamera = findViewById(R.id.tv_camera)
        layoutBlurBackground = findViewById(R.id.ll_blur)
        imageViewBlur = findViewById(R.id.iv_video_blur)

        imageOpenCamera.isActivated = CallManager.instance.mediaState.isCameraOpened.get()
        if (!GlobalState.instance.enableVirtualBackground) {
            layoutBlurBackground.visibility = GONE
            reLayoutView()
        }

        initViewListener()
    }

    private fun reLayoutView() {
        val size = ConstraintLayout.LayoutParams.WRAP_CONTENT
        val parentId = ConstraintLayout.LayoutParams.PARENT_ID

        layoutCancel.layoutParams = ConstraintLayout.LayoutParams(size, size).apply {
            topToTop = parentId
            startToStart = parentId
            endToEnd = parentId
        }

        findViewById<LinearLayout>(R.id.ll_switch).layoutParams = ConstraintLayout.LayoutParams(size, size).apply {
            startToStart = parentId
            endToStart = layoutCancel.id
            topToTop = layoutCancel.id
            bottomToBottom = layoutCancel.id
        }

        findViewById<LinearLayout>(R.id.ll_camera).layoutParams = ConstraintLayout.LayoutParams(size, size).apply {
            startToEnd = layoutCancel.id
            endToEnd = parentId
            topToTop = layoutCancel.id
            bottomToBottom = layoutCancel.id
        }
    }

    private fun initViewListener() {
        layoutCancel.setOnClickListener {
            CallManager.instance.hangup(null)
        }
        imageSwitchCamera.setOnClickListener {
            var camera = TUICommonDefine.Camera.Back
            if (CallManager.instance.mediaState.isFrontCamera.get() == TUICommonDefine.Camera.Back) {
                camera = TUICommonDefine.Camera.Front
            }
            CallManager.instance.switchCamera(camera)
        }
        imageOpenCamera.setOnClickListener {
            val isCameraOpened = CallManager.instance.mediaState.isCameraOpened.get()
            imageOpenCamera.isActivated = !isCameraOpened
            imageSwitchCamera.isEnabled = !isCameraOpened
            layoutBlurBackground.isEnabled = !isCameraOpened

            if (isCameraOpened) {
                CallManager.instance.closeCamera()
                textCamera.text = context.resources.getString(R.string.tuicallkit_toast_disable_camera)
            } else {
                val camera = CallManager.instance.mediaState.isFrontCamera.get()
                val videoView = VideoFactory.instance.findVideoView(CallManager.instance.userState.selfUser.get().id)
                CallManager.instance.openCamera(camera, videoView, null)
                textCamera.text = context.resources.getString(R.string.tuicallkit_toast_enable_camera)
            }
        }
        layoutBlurBackground.setOnClickListener {
            CallManager.instance.setBlurBackground(!CallManager.instance.viewState.isVirtualBackgroundOpened.get())
        }
    }
}