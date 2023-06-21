package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.LinearLayout
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.function.VideoCallerWaitingViewModel

class VideoCallerWaitingView(context: Context) : BaseCallView(context) {
    private var layoutCancel: LinearLayout? = null
    private var imageSwitchCamera: ImageView? = null
    private var viewModel = VideoCallerWaitingViewModel()

    init {
        initView()
    }


    override fun clear() {
        if(viewModel != null) {
            viewModel.removeObserver()
        }
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_funcation_view_video_inviting, this)
        layoutCancel = findViewById(R.id.ll_cancel)
        imageSwitchCamera = findViewById(R.id.img_switch_camera)

        initViewListener()
    }

    private fun initViewListener() {
        layoutCancel?.setOnClickListener { viewModel?.hangup() }
        imageSwitchCamera!!.setOnClickListener {
            viewModel?.switchCamera(if (viewModel?.frontCamera?.get() == true) TUICommonDefine.Camera.Back else
                TUICommonDefine
                .Camera.Front)
            ToastUtil.toastShortMessage(context.getString(R.string.tuicalling_toast_switch_camera))
        }
    }
}