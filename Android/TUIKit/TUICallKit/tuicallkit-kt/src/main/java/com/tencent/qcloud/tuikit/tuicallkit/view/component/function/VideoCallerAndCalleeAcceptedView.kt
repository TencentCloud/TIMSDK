package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.function.VideoCallerAndCalleeAcceptedViewModel

class VideoCallerAndCalleeAcceptedView(context: Context) : BaseCallView(context) {
    private var layoutOpenCamera: LinearLayout? = null
    private var layoutMute: LinearLayout? = null
    private var layoutHandsFree: LinearLayout? = null
    private var layoutHangup: LinearLayout? = null
    private var imageOpenCamera: ImageView? = null
    private var imageMute: ImageView? = null
    private var imageHandsFree: ImageView? = null
    private var imageSwitchCamera: ImageView? = null
    private var viewModel = VideoCallerAndCalleeAcceptedViewModel()

    private var isCameraOpenObserver = Observer<Boolean> {
        imageOpenCamera?.isActivated = it
    }

    private var isMicMuteObserver = Observer<Boolean> {
        imageMute?.isActivated = it
    }

    private var isSpeakerObserver = Observer<Boolean> {
        imageHandsFree?.isActivated = it
    }

    init {
        initView()

        addObserver()
    }

    override fun clear() {
        removeObserver()

        if (viewModel != null) {
            viewModel.removeObserver()
        }
    }

    private fun addObserver() {
        viewModel?.isCameraOpen?.observe(isCameraOpenObserver)
        viewModel?.isMicMute?.observe(isMicMuteObserver)
        viewModel?.isSpeaker?.observe(isSpeakerObserver)
    }

    private fun removeObserver() {
        viewModel?.isCameraOpen?.removeObserver(isCameraOpenObserver)
        viewModel?.isMicMute?.removeObserver(isMicMuteObserver)
        viewModel?.isSpeaker?.removeObserver(isSpeakerObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_funcation_view_video, this)
        layoutMute = findViewById<View>(R.id.ll_mute) as LinearLayout
        imageMute = findViewById<View>(R.id.iv_mute) as ImageView
        layoutHandsFree = findViewById<View>(R.id.ll_handsfree) as LinearLayout
        imageHandsFree = findViewById<View>(R.id.iv_handsfree) as ImageView
        layoutOpenCamera = findViewById<View>(R.id.ll_open_camera) as LinearLayout
        imageOpenCamera = findViewById<View>(R.id.img_camera) as ImageView
        layoutHangup = findViewById<View>(R.id.ll_hangup) as LinearLayout
        imageSwitchCamera = findViewById<View>(R.id.switch_camera) as ImageView

        imageOpenCamera?.isActivated = viewModel?.isCameraOpen?.get() == true
        imageMute?.isActivated = viewModel?.isMicMute?.get() == true
        imageHandsFree?.isActivated = viewModel?.isSpeaker?.get() == true

        initViewListener()
    }

    private fun initViewListener() {
        layoutMute?.setOnClickListener {
            val resId = if (viewModel?.isMicMute?.get() == true) {
                viewModel?.openMicrophone()
                R.string.tuicalling_toast_disable_mute
            } else {
                viewModel?.closeMicrophone()
                R.string.tuicalling_toast_enable_mute
            }
            ToastUtil.toastShortMessage(context.getString(resId))
        }
        layoutHandsFree?.setOnClickListener {
            val resId = if (viewModel?.isSpeaker?.get() == true) {
                viewModel?.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Earpiece)
                R.string.tuicalling_toast_use_handset
            } else {
                viewModel?.selectAudioPlaybackDevice(TUICommonDefine.AudioPlaybackDevice.Speakerphone)
                R.string.tuicalling_toast_speaker
            }
            ToastUtil.toastShortMessage(context.getString(resId))
        }
        layoutOpenCamera?.setOnClickListener {
            if (viewModel?.isCameraOpen?.get() == true) {
                viewModel?.closeCamera()
                ToastUtil.toastShortMessage(context.getString(R.string.tuicalling_toast_disable_camera))
            } else {
                if (null != VideoViewFactory.instance.videoEntityList.size
                    && VideoViewFactory.instance.videoEntityList.size > 0
                ) {
                    viewModel?.openCamera(viewModel?.frontCamera?.get())
                    ToastUtil.toastShortMessage(context.getString(R.string.tuicalling_toast_enable_camera))
                }
            }
        }
        imageSwitchCamera?.setOnClickListener {
            viewModel?.switchCamera(
                if (viewModel?.frontCamera?.get() == true) TUICommonDefine
                    .Camera
                    .Back else
                    TUICommonDefine.Camera.Front
            )
            ToastUtil.toastShortMessage(context.getString(R.string.tuicalling_toast_switch_camera))
        }
        layoutHangup?.setOnClickListener { viewModel?.hangup() }
    }
}