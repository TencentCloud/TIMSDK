package com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow

import android.content.Context
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.floatview.FloatingWindowViewModel

class FloatingWindowView(context: Context) : BaseCallView(context) {

    private var layoutAvatar: FrameLayout? = null
    private var layoutVideoView: RelativeLayout? = null
    private var imageAudioIcon: ImageView? = null
    private var textCallStatus: TextView? = null
    private var imageAvatar: ImageView? = null
    private var videoView: VideoView? = null
    private var viewModel: FloatingWindowViewModel = FloatingWindowViewModel()
    private val observer: Observer<Any> = Observer {
        updateView(it)
    }

    init {
        initView(context)

        addObserver()
    }

    override fun clear() {
        videoView?.clear()
        removeObserver()
    }

    private fun addObserver() {
        viewModel?.mediaType?.observe(observer)
        viewModel?.timeCount?.observe(observer)
        viewModel?.selfUser?.callStatus?.observe(observer)
        viewModel.remoteUser?.videoAvailable?.observe(observer)
    }

    private fun removeObserver() {
        viewModel?.mediaType?.removeObserver(observer)
        viewModel?.timeCount?.removeObserver(observer)
        viewModel?.selfUser?.callStatus?.removeObserver(observer)
        viewModel.remoteUser?.videoAvailable?.removeObserver(observer)
    }

    private fun initView(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_float_call_view, this)
        layoutVideoView = findViewById(R.id.rl_video_view)
        imageAvatar = findViewById(R.id.iv_avatar)
        textCallStatus = findViewById(R.id.tv_call_status)
        imageAudioIcon = findViewById(R.id.iv_audio_view_icon)
        layoutAvatar = findViewById(R.id.fl_avatar)

        updateView(null)
    }

    private fun updateView(it: Any?) {
        if (it != null && it is Int) {
            textCallStatus?.post {
                textCallStatus?.text = DateTimeUtil.formatSecondsTo00(it)
            }
            return
        }
        if (viewModel.mediaType.get() == TUICallDefine.MediaType.Audio
            || viewModel.scene.get() == TUICallDefine.Scene.GROUP_CALL
        ) {
            imageAudioIcon?.visibility = VISIBLE
            textCallStatus?.visibility = VISIBLE
            layoutVideoView?.visibility = GONE
            layoutAvatar?.visibility = GONE
            if (viewModel.selfUser?.callStatus?.get() == TUICallDefine.Status.Waiting) {
                textCallStatus?.text = context.getString(R.string.tuicallkit_wait_response)
            } else if (viewModel.selfUser?.callStatus?.get() == TUICallDefine.Status.Accept) {
                textCallStatus?.text = DateTimeUtil.formatSecondsTo00(viewModel.timeCount.get())
            } else {
                VideoViewFactory.instance.clear()
                clear()
                viewModel.stopFloatService()
            }
        } else if (viewModel.mediaType.get() == TUICallDefine.MediaType.Video) {
            imageAudioIcon?.visibility = GONE
            if (viewModel.selfUser?.callStatus?.get() == TUICallDefine.Status.Waiting) {
                layoutVideoView?.visibility = VISIBLE
                layoutAvatar?.visibility = GONE
                textCallStatus?.visibility = VISIBLE
                textCallStatus?.text = context.getString(R.string.tuicallkit_wait_response)
                textCallStatus?.setTextColor(context.resources.getColor(R.color.tuicallkit_color_white))
                videoView = VideoViewFactory.instance.createVideoView(viewModel.selfUser, context)
                if (videoView != null && videoView?.parent != null) {
                    (videoView?.parent as ViewGroup).removeView(videoView)
                    layoutVideoView?.removeAllViews()
                }
                layoutVideoView?.addView(videoView)
            } else if (viewModel.selfUser?.callStatus?.get() == TUICallDefine.Status.Accept) {
                if (viewModel.remoteUser?.videoAvailable?.get() == true) {
                    layoutVideoView?.visibility = VISIBLE
                    layoutAvatar?.visibility = GONE
                    textCallStatus?.visibility = GONE
                    videoView = VideoViewFactory.instance.createVideoView(viewModel.remoteUser, context)
                    if (videoView != null && videoView?.parent != null) {
                        (videoView?.parent as ViewGroup).removeView(videoView)
                        layoutVideoView?.removeAllViews()
                    }
                    layoutVideoView?.addView(videoView)
                    EngineManager.instance.startRemoteView(
                        viewModel.remoteUser?.id,
                        videoView?.getVideoView(),
                        null
                    )
                } else {
                    layoutVideoView?.visibility = GONE
                    layoutAvatar?.visibility = VISIBLE

                    ImageLoader.loadImage(
                        context,
                        imageAvatar,
                        viewModel.remoteUser?.avatar?.get(),
                        R.drawable.tuicallkit_ic_avatar
                    )
                }
            } else {
                VideoViewFactory.instance.clear()
                clear()
                viewModel.stopFloatService()
            }
        }
    }
}