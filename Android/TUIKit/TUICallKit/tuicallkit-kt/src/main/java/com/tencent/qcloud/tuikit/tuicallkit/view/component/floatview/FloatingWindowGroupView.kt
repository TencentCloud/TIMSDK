package com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview

import android.content.Context
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoViewFactory
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.floatview.FloatingWindowViewModel

class FloatingWindowGroupView(context: Context) : BaseCallView(context) {
    private var layoutVideoView: RelativeLayout? = null
    private var imageAudioIcon: ImageView? = null
    private var textCallStatus: TextView? = null
    private var imageAvatar: ImageView? = null
    private var textName: TextView? = null
    private var videoView: VideoView? = null
    private var layoutFloatMark: LinearLayout? = null
    private var imageFloatVideoMark: ImageView? = null
    private var imageFloatAudioMark: ImageView? = null

    private var currentShowVideUserId: String? = null
    private var viewModel: FloatingWindowViewModel = FloatingWindowViewModel()

    private val observer: Observer<Any> = Observer {
        updateView(it)
    }

    private val timeCountObserver = Observer<Int> {
        if (viewModel.selfUser.callStatus.get() == TUICallDefine.Status.Accept) {
            textCallStatus?.text = DateTimeUtil.formatSecondsTo00(viewModel.timeCount.get())
        }
    }

    init {
        initView(context)
        addObserver()
    }

    override fun clear() {
        removeObserver()
        currentShowVideUserId = null
    }

    private fun addObserver() {
        viewModel.timeCount.observe(timeCountObserver)

        viewModel.selfUser.callStatus.observe(observer)
        viewModel.selfUser.videoAvailable.observe(observer)
        viewModel.selfUser.playoutVolume.observe(observer)
        for (user in viewModel.remoteUserList) {
            user.videoAvailable.observe(observer)
            user.playoutVolume.observe(observer)
        }
    }

    private fun removeObserver() {
        viewModel.timeCount.removeObserver(timeCountObserver)

        viewModel.selfUser.callStatus.removeObserver(observer)
        viewModel.selfUser.videoAvailable.removeObserver(observer)
        viewModel.selfUser.playoutVolume.removeObserver(observer)
        for (user in viewModel.remoteUserList) {
            user.videoAvailable.removeObserver(observer)
            user.playoutVolume.removeObserver(observer)
        }
    }

    private fun initView(context: Context) {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_float_call_group_view, this)
        layoutVideoView = findViewById(R.id.rl_video_view)
        imageAvatar = findViewById(R.id.iv_avatar)
        textName = findViewById(R.id.tv_float_name)
        textCallStatus = findViewById(R.id.tv_call_status)
        imageAudioIcon = findViewById(R.id.iv_audio_view_icon)
        layoutFloatMark = findViewById(R.id.ll_float_mark)
        imageFloatVideoMark = findViewById(R.id.iv_float_video_mark)
        imageFloatAudioMark = findViewById(R.id.iv_float_audio_mark)

        updateView(null)
    }

    private fun updateView(it: Any?) {
        if (viewModel.selfUser.callStatus.get() == TUICallDefine.Status.None) {
            VideoViewFactory.instance.clear()
            clear()
            viewModel.stopFloatService()
            return
        }

        updateFloatMarkOfSelfUser()

        if (it != null && it is Int && it < Constants.MIN_AUDIO_VOLUME) {
            return
        }

        val list = ArrayList<User>()
        list.addAll(viewModel.remoteUserList)
        list.add(viewModel.selfUser)

        for (user in list) {
            if (user.playoutVolume.get() > Constants.MIN_AUDIO_VOLUME) {
                imageAudioIcon?.visibility = GONE
                textCallStatus?.visibility = GONE
                textName?.visibility = VISIBLE
                textName?.text = user.nickname.get()

                if (user.videoAvailable.get() == true) {
                    if (user.id == currentShowVideUserId) {
                        return
                    }
                    currentShowVideUserId = user.id

                    imageAvatar?.visibility = GONE
                    layoutVideoView?.visibility = VISIBLE
                    resetLayoutVideoView(user)
                    return
                }
                currentShowVideUserId = null
                imageAvatar?.visibility = VISIBLE
                layoutVideoView?.visibility = GONE
                ImageLoader.loadImage(context, imageAvatar, user.avatar.get())
                return
            }
        }
        currentShowVideUserId = null
        textCallStatus?.text = if (viewModel.selfUser.callStatus.get() == TUICallDefine.Status.Waiting) {
            context.getString(R.string.tuicallkit_wait_response)
        } else {
            DateTimeUtil.formatSecondsTo00(viewModel.timeCount.get())
        }

        textCallStatus?.visibility = VISIBLE
        imageAudioIcon?.visibility = VISIBLE
        imageAvatar?.visibility = GONE
        textName?.visibility = GONE
        layoutVideoView?.visibility = GONE
    }

    private fun resetLayoutVideoView(user: User) {
        videoView = VideoViewFactory.instance.createVideoView(user, context)
        videoView?.setVideoIconVisibility(false)

        if (videoView != null && videoView?.parent != null) {
            (videoView?.parent as ViewGroup).removeView(videoView)
            layoutVideoView?.removeAllViews()
        }
        layoutVideoView?.addView(videoView)
        if (user.id != viewModel.selfUser.id) {
            EngineManager.instance.startRemoteView(user.id, videoView?.getVideoView(), null)
        }
    }

    private fun updateFloatMarkOfSelfUser() {
        if (viewModel.selfUser.videoAvailable.get() == true) {
            imageFloatVideoMark?.setImageResource(R.drawable.tuicallkit_ic_float_video_on)
        } else {
            imageFloatVideoMark?.setImageResource(R.drawable.tuicallkit_ic_float_video_off)
        }

        if (viewModel.selfUser.audioAvailable.get() == true) {
            imageFloatAudioMark?.setImageResource(R.drawable.tuicallkit_ic_float_audio_on)
        } else {
            imageFloatAudioMark?.setImageResource(R.drawable.tuicallkit_ic_float_audio_off)
        }
    }

    override fun onInterceptTouchEvent(ev: MotionEvent?): Boolean {
        return true
    }
}