package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.utils.widget.ImageFilterView
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.ScreenUtil
import com.tencent.qcloud.tuikit.TUICommonDefine.Camera
import com.tencent.qcloud.tuikit.TUIVideoView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.manager.EngineManager
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.common.CustomLoadingView
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout.VideoViewModel

class VideoView(context: Context) : BaseCallView(context) {
    private var tuiVideoView: TUIVideoView? = null
    private var imageAvatar: ImageFilterView? = null
    private var imageSwitchCamera: ImageView? = null
    private var imageUserBlurBackground: ImageView? = null
    private var imageNetworkBad: ImageView? = null
    private var textUserName: TextView? = null
    private var imageAudioInput: ImageView? = null
    private var imageLoading: CustomLoadingView? = null
    private var imageBackground: ImageView? = null
    private var viewModel: VideoViewModel? = null

    private var videoAvailableObserver = Observer<Boolean> {
        if (it) {
            tuiVideoView?.visibility = VISIBLE
            imageBackground?.visibility = GONE
            imageAvatar?.visibility = GONE
            if (viewModel?.user?.id != viewModel?.selfUser?.id) {
                EngineManager.instance.startRemoteView(viewModel?.user?.id, tuiVideoView, null)
            }
        } else {
            tuiVideoView?.visibility = GONE
            imageBackground?.visibility = VISIBLE
            ImageLoader.loadBlurImage(context, imageBackground, viewModel?.user?.avatar?.get())

            if (viewModel?.user?.id == viewModel?.selfUser?.id
                && TUICallState.instance.scene.get() == TUICallDefine.Scene.SINGLE_CALL
                && viewModel?.selfUser?.callStatus?.get() == TUICallDefine.Status.Waiting
            ) {
                imageAvatar?.visibility = GONE
            } else {
                imageAvatar?.visibility = VISIBLE
                ImageLoader.loadImage(context, imageAvatar, viewModel?.user?.avatar?.get())
            }
        }

        val show = it && viewModel?.user?.id == viewModel?.selfUser?.id
                && viewModel?.showLargeViewUserId?.get() == viewModel?.selfUser?.id
        refreshFunctionButton(show)
    }

    private var audioAvailableObserver = Observer<Boolean> {
        if (!it && viewModel?.scene?.get() == TUICallDefine.Scene.GROUP_CALL && viewModel?.user == viewModel?.selfUser) {
            imageAudioInput?.setImageResource(R.drawable.tuicallkit_ic_self_mute)
            imageAudioInput?.visibility = VISIBLE
        } else {
            imageAudioInput?.visibility = GONE
        }
    }

    private var playoutVolumeAvailableObserver = Observer<Int> {
        if (viewModel?.scene?.get() == TUICallDefine.Scene.GROUP_CALL
            && viewModel?.user == viewModel?.selfUser && viewModel?.selfUser?.audioAvailable?.get() == false
        ) {
            imageAudioInput?.setImageResource(R.drawable.tuicallkit_ic_self_mute)
            imageAudioInput?.visibility = VISIBLE
        } else if (it > Constants.MIN_AUDIO_VOLUME && viewModel?.scene?.get() == TUICallDefine.Scene.GROUP_CALL) {
            imageAudioInput?.setImageResource(R.drawable.tuicallkit_ic_audio_input)
            imageAudioInput?.visibility = VISIBLE
        } else {
            imageAudioInput?.visibility = GONE
        }
    }

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.Waiting && !viewModel?.user?.id.equals(TUILogin.getLoginUser())) {
            imageLoading?.visibility = VISIBLE
            imageLoading?.startLoading()
        } else {
            imageLoading?.visibility = GONE
            imageLoading?.stopLoading()
        }
        if (viewModel?.user?.id == viewModel?.selfUser?.id && viewModel?.user?.videoAvailable?.get() == false) {
            imageAvatar?.visibility = VISIBLE
            ImageLoader.loadImage(context, imageAvatar, viewModel?.user?.avatar?.get())
        }
    }

    private var avatarObserver = Observer<String> {
        if (!TextUtils.isEmpty(it)) {
            ImageLoader.loadImage(context.applicationContext, imageAvatar, it, R.drawable.tuicallkit_ic_avatar)
            ImageLoader.loadBlurImage(context, imageBackground, it)
        }
    }

    private var nicknameObserver = Observer<String> {
        if (!TextUtils.isEmpty(it)) {
            textUserName?.text = it
        }
    }

    private var showLargeViewUserIdObserver = Observer<String> {
        val show = !it.isNullOrEmpty() && viewModel?.selfUser?.videoAvailable?.get() == true
                && it == viewModel?.user?.id && it == viewModel?.selfUser?.id
        refreshFunctionButton(show)
        refreshUserNameView()
    }

    private var networkQualityObserver = Observer<Boolean> {
        if (it && viewModel?.scene?.get() == TUICallDefine.Scene.GROUP_CALL) {
            imageNetworkBad?.visibility = VISIBLE
        } else {
            imageNetworkBad?.visibility = GONE
        }
    }

    init {
        initView()
    }

    override fun onInterceptTouchEvent(ev: MotionEvent): Boolean {
        return super.onInterceptTouchEvent(ev)
    }

    override fun clear() {
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
            imageBackground?.visibility = VISIBLE
            ImageLoader.loadImage(context, imageAvatar, viewModel?.user?.avatar?.get())
            ImageLoader.loadBlurImage(context, imageBackground, viewModel?.user?.avatar?.get())
        } else {
            imageAvatar?.visibility = GONE
            imageBackground?.visibility = GONE
        }
    }

    fun setVideoIconVisibility(needShow: Boolean) {
        if (!needShow) {
            imageAudioInput?.visibility = GONE
            textUserName?.visibility = GONE
            refreshFunctionButton(false)
        }
    }

    private fun addObserver() {
        viewModel?.user?.videoAvailable?.observe(videoAvailableObserver)
        viewModel?.user?.audioAvailable?.observe(audioAvailableObserver)
        viewModel?.user?.playoutVolume?.observe(playoutVolumeAvailableObserver)
        viewModel?.user?.callStatus?.observe(callStatusObserver)
        viewModel?.user?.avatar?.observe(avatarObserver)
        viewModel?.user?.nickname?.observe(nicknameObserver)
        viewModel?.user?.networkQualityReminder?.observe(networkQualityObserver)

        viewModel?.showLargeViewUserId?.observe(showLargeViewUserIdObserver)
    }

    private fun removeObserver() {
        viewModel?.user?.videoAvailable?.removeObserver(videoAvailableObserver)
        viewModel?.user?.audioAvailable?.removeObserver(audioAvailableObserver)
        viewModel?.user?.playoutVolume?.removeObserver(playoutVolumeAvailableObserver)
        viewModel?.user?.callStatus?.removeObserver(callStatusObserver)
        viewModel?.user?.avatar?.removeObserver(avatarObserver)
        viewModel?.user?.nickname?.removeObserver(nicknameObserver)
        viewModel?.user?.networkQualityReminder?.removeObserver(networkQualityObserver)

        viewModel?.showLargeViewUserId?.removeObserver(showLargeViewUserIdObserver)
    }

    private fun refreshView() {
        if (TUICallDefine.Scene.GROUP_CALL == viewModel?.scene?.get()
            && TUICallDefine.Status.Waiting == viewModel?.user?.callStatus?.get()
        ) {
            if (!viewModel?.user?.id.equals(TUILogin.getLoginUser())) {
                imageLoading?.visibility = VISIBLE
                imageLoading?.startLoading()
            }
        } else if (TUICallDefine.Status.Accept == viewModel?.user?.callStatus?.get()) {
            if (viewModel?.user?.videoAvailable?.get() == true) {
                tuiVideoView?.visibility = VISIBLE
                imageAvatar?.visibility = GONE
            } else {
                tuiVideoView?.visibility = GONE
                imageAvatar?.visibility = VISIBLE
            }
            imageLoading?.visibility = GONE
            imageLoading?.stopLoading()
        } else {
            imageLoading?.visibility = GONE
            imageLoading?.stopLoading()
        }

        refreshUserAvatarView()
        refreshUserNameView()

        val show = viewModel?.user?.videoAvailable?.get() == true
                && viewModel?.showLargeViewUserId?.get() == viewModel?.user?.id
        refreshFunctionButton(show)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_video_view, this, true)
        tuiVideoView = findViewById(R.id.tx_cloud_view)
        imageAvatar = findViewById(R.id.img_head)
        imageSwitchCamera = findViewById(R.id.iv_switch_camera)
        imageUserBlurBackground = findViewById(R.id.iv_blur_background)
        textUserName = findViewById(R.id.tv_name)
        imageAudioInput = findViewById(R.id.iv_audio_input)
        imageLoading = findViewById(R.id.img_loading)
        imageBackground = findViewById(R.id.img_video_background)
        imageNetworkBad = findViewById(R.id.iv_network)

        refreshUserAvatarView()
        refreshUserNameView()

        imageSwitchCamera?.setOnClickListener() {
            val camera = if (viewModel?.isFrontCamera?.get() == Camera.Front) Camera.Back else Camera.Front
            EngineManager.instance.switchCamera(camera)
        }
        imageUserBlurBackground?.setOnClickListener {
            EngineManager.instance.setBlurBackground(!TUICallState.instance.enableBlurBackground.get())
            imageUserBlurBackground?.isActivated = TUICallState.instance.enableBlurBackground.get()
        }
    }

    private fun refreshUserAvatarView() {
        val layoutParams: LayoutParams = imageAvatar?.layoutParams as LayoutParams
        if (TUICallDefine.Scene.GROUP_CALL == viewModel?.scene?.get()) {
            layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
            layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT
            layoutParams.removeRule(CENTER_IN_PARENT)
            imageAvatar?.round = 0f
        } else {
            layoutParams.addRule(CENTER_IN_PARENT)
            layoutParams.width = ScreenUtil.dip2px(80.0f)
            layoutParams.height = ScreenUtil.dip2px(80.0f)
            imageAvatar?.round = 12f
        }
        ImageLoader.loadImage(context, imageAvatar, viewModel?.user?.avatar?.get(), R.drawable.tuicallkit_ic_avatar)
        imageAvatar?.layoutParams = layoutParams
    }

    private fun refreshUserNameView() {
        if (TUICallDefine.Scene.GROUP_CALL == viewModel?.scene?.get()
            && viewModel?.showLargeViewUserId?.get() == viewModel?.user?.id
        ) {
            textUserName?.visibility = VISIBLE
        } else {
            textUserName?.visibility = GONE
        }

        textUserName?.text = if (TextUtils.isEmpty(viewModel?.user?.nickname?.get())) {
            viewModel?.user?.id
        } else {
            viewModel?.user?.nickname?.get()
        }
    }

    private fun refreshFunctionButton(show: Boolean) {
        imageSwitchCamera?.visibility = if (show) VISIBLE else GONE
        imageUserBlurBackground?.visibility =
            if (TUICallState.instance.showVirtualBackgroundButton && show) VISIBLE else GONE

    }

    fun getVideoView(): TUIVideoView? {
        return tuiVideoView
    }
}