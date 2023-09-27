package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.ScreenUtil
import com.tencent.qcloud.tuikit.TUIVideoView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout.VideoViewModel

class VideoView constructor(context: Context) : BaseCallView(context) {
    private var tuiVideoView: TUIVideoView? = null
    private var imageAvatar: ImageView? = null
    private var textUserName: TextView? = null
    private var imageAudioInput: ImageView? = null
    private var imageLoading: ImageView? = null
    private var viewModel: VideoViewModel? = null

    private var videoAvailableObserver = Observer<Boolean> {
        if (it) {
            tuiVideoView?.visibility = VISIBLE
            imageAvatar?.visibility = GONE
        } else {
            tuiVideoView?.visibility = GONE
            imageAvatar?.visibility = VISIBLE
            ImageLoader.loadImage(
                context.applicationContext,
                imageAvatar,
                viewModel?.user?.avatar?.get(),
                R.drawable.tuicallkit_ic_avatar
            )
        }
    }

    private var audioAvailableObserver = Observer<Boolean> {
        imageAudioInput?.visibility = if (it
            && viewModel?.user?.playoutVolume!!.get() > Constants.MIN_AUDIO_VOLUME
        ) VISIBLE else GONE
    }

    private var playoutVolumeAvailableObserver = Observer<Int> {
        imageAudioInput?.visibility = if (viewModel?.user?.audioAvailable?.get() == true
            && it > Constants.MIN_AUDIO_VOLUME
        ) VISIBLE else GONE
    }

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.Waiting && !viewModel?.user?.id.equals(TUILogin.getLoginUser())) {
            imageLoading?.visibility = VISIBLE
        } else {
            imageLoading?.visibility = GONE
        }
    }

    private var avatarObserver = Observer<String> {
        if (!TextUtils.isEmpty(it)) {
            ImageLoader.loadImage(context.applicationContext, imageAvatar, it, R.drawable.tuicallkit_ic_avatar)
        }
    }

    private var nicknameObserver = Observer<String> {
        if (!TextUtils.isEmpty(it)) {
            textUserName?.text = it
        }
    }

    init {
        initView()
    }

    override fun onInterceptTouchEvent(ev: MotionEvent): Boolean {
        return true
    }

    override fun clear() {
        if (tuiVideoView != null) {
            tuiVideoView = null
        }

        removeObserver()
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        return false
    }

    fun setUser(user: User) {
        viewModel = VideoViewModel(user)
        refreshView()

        addObserver()
    }

    fun setImageAvatarVisibility(isShow: Boolean) {
        if (isShow) {
            imageAvatar?.visibility = VISIBLE
        } else {
            imageAvatar?.visibility = GONE
        }
    }

    private fun addObserver() {
        viewModel?.user?.videoAvailable?.observe(videoAvailableObserver)
        viewModel?.user?.audioAvailable?.observe(audioAvailableObserver)
        viewModel?.user?.playoutVolume?.observe(playoutVolumeAvailableObserver)
        viewModel?.user?.callStatus?.observe(callStatusObserver)
        viewModel?.user?.avatar?.observe(avatarObserver)
        viewModel?.user?.nickname?.observe(nicknameObserver)
    }

    private fun removeObserver() {
        viewModel?.user?.videoAvailable?.removeObserver(videoAvailableObserver)
        viewModel?.user?.audioAvailable?.removeObserver(audioAvailableObserver)
        viewModel?.user?.playoutVolume?.removeObserver(playoutVolumeAvailableObserver)
        viewModel?.user?.callStatus?.removeObserver(callStatusObserver)
        viewModel?.user?.avatar?.removeObserver(avatarObserver)
        viewModel?.user?.nickname?.removeObserver(nicknameObserver)
    }

    private fun refreshView() {
        var layoutParams: LayoutParams = imageAvatar?.layoutParams as LayoutParams
        if (TUICallDefine.Scene.GROUP_CALL == viewModel?.scene?.get()) {
            layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
            layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT
            layoutParams.removeRule(CENTER_IN_PARENT)
            textUserName?.visibility = VISIBLE
        } else {
            layoutParams.addRule(CENTER_IN_PARENT)
            layoutParams.width = ScreenUtil.dip2px(80.0f)
            layoutParams.height = ScreenUtil.dip2px(80.0f)
            textUserName?.visibility = GONE
        }
        imageAvatar?.layoutParams = layoutParams
        ImageLoader.loadImage(
            context.applicationContext,
            imageAvatar,
            viewModel?.user?.avatar?.get(),
            R.drawable.tuicallkit_ic_avatar
        )
        textUserName?.text = if (TextUtils.isEmpty(viewModel?.user?.nickname?.get())) {
            viewModel?.user?.id
        } else {
            viewModel?.user?.nickname?.get()
        }
        if (TUICallDefine.Scene.GROUP_CALL == viewModel?.scene?.get()
            && TUICallDefine.Status.Waiting == viewModel?.user?.callStatus?.get()
        ) {
            if (!viewModel?.user?.id.equals(TUILogin.getLoginUser())) {
                imageLoading?.visibility = VISIBLE
            }
        } else if (TUICallDefine.Status.Accept == viewModel?.user?.callStatus?.get()) {
            if (viewModel?.user?.videoAvailable?.get() == true) {
                tuiVideoView?.visibility = VISIBLE
                imageAvatar?.visibility = GONE
            } else {
                tuiVideoView?.visibility = GONE
                imageAvatar?.visibility = VISIBLE
            }
        } else {
            imageLoading?.visibility = GONE
        }
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_video_view, this, true)
        tuiVideoView = findViewById(R.id.tx_cloud_view)
        imageAvatar = findViewById(R.id.img_head)
        textUserName = findViewById(R.id.tv_name)
        imageAudioInput = findViewById(R.id.iv_audio_input)
        imageLoading = findViewById<View>(R.id.img_loading) as ImageView

        var layoutParams: LayoutParams = imageAvatar?.layoutParams as LayoutParams
        if (TUICallDefine.Scene.GROUP_CALL == viewModel?.scene?.get()) {
            layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
            layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT
            layoutParams.removeRule(CENTER_IN_PARENT)
            textUserName?.visibility = VISIBLE
        } else {
            layoutParams.addRule(CENTER_IN_PARENT)
            layoutParams.width = ScreenUtil.dip2px(80.0f)
            layoutParams.height = ScreenUtil.dip2px(80.0f)
            textUserName?.visibility = GONE
        }
        imageAvatar?.layoutParams = layoutParams

        ImageLoader.loadGifImage(context.applicationContext, imageLoading, R.drawable.tuicallkit_loading)
        ImageLoader.loadImage(
            context.applicationContext,
            imageAvatar,
            viewModel?.user?.avatar?.get(),
            R.drawable.tuicallkit_ic_avatar
        )
        textUserName?.text = if (TextUtils.isEmpty(viewModel?.user?.nickname?.get())) {
            viewModel?.user?.id
        } else {
            viewModel?.user?.nickname?.get()
        }
    }

    fun getVideoView(): TUIVideoView? {
        return tuiVideoView
    }
}