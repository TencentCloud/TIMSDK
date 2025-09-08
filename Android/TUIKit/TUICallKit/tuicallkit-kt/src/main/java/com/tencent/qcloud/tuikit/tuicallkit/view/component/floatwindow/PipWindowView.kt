package com.tencent.qcloud.tuikit.tuicallkit.view.component.floatwindow

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoFactory
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.imageloader.ImageOptions
import com.trtc.tuikit.common.livedata.Observer

class PipWindowView(private val context: Context) : ConstraintLayout(context) {
    private lateinit var layoutVideoView: FrameLayout
    private lateinit var imageAudioView: ImageView
    private lateinit var textCallStatus: TextView

    private var remoteUser: UserState.User = UserState.User()
    private var showingUserId: String = ""

    private val callStatusObserver: Observer<Any> = Observer {
        if (!CallManager.instance.viewState.enterPipMode.get()) {
            return@Observer
        }
        updateView()
    }

    private val isInPipObserver: Observer<Boolean> = Observer {
        fadeViewInOut(it)
    }

    private val callDurationObserver: Observer<Int> = Observer {
        post {
            updateCallStatusHint()
        }
    }

    init {
        val remoteUserList = CallManager.instance.userState.remoteUserList.get()
        if (remoteUserList != null && remoteUserList.size > 0) {
            remoteUser = remoteUserList.first()
        }
        initView()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
    }

    private fun registerObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
        CallManager.instance.callState.callDurationCount.observe(callDurationObserver)
        CallManager.instance.viewState.enterPipMode.observe(isInPipObserver)
        val scene = CallManager.instance.callState.scene.get()
        if (scene == TUICallDefine.Scene.GROUP_CALL || scene == TUICallDefine.Scene.MULTI_CALL) {
            CallManager.instance.userState.selfUser.get().playoutVolume.observe(callStatusObserver)
            for (user in CallManager.instance.userState.remoteUserList.get()) {
                user.playoutVolume.observe(callStatusObserver)
            }
        }
    }

    private fun unregisterObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.removeObserver(callStatusObserver)
        CallManager.instance.callState.callDurationCount.removeObserver(callDurationObserver)
        CallManager.instance.viewState.enterPipMode.removeObserver(isInPipObserver)
        val scene = CallManager.instance.callState.scene.get()
        if (scene == TUICallDefine.Scene.GROUP_CALL || scene == TUICallDefine.Scene.MULTI_CALL) {
            CallManager.instance.userState.selfUser.get().playoutVolume.removeObserver(callStatusObserver)
            for (user in CallManager.instance.userState.remoteUserList.get()) {
                user.playoutVolume.removeObserver(callStatusObserver)
            }
        }
        this.removeAllViews()
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_pip_call_view, this)
        layoutVideoView = findViewById(R.id.rl_video_view)
        imageAudioView = findViewById(R.id.iv_audio_view)
        textCallStatus = findViewById(R.id.tv_float_call_status)
        setBackground()
        updateView()
        updateCallStatusHint()
    }

    private fun setBackground() {
        val imageBackground: ImageView = findViewById(R.id.img_view_background)
        val selfUser = CallManager.instance.userState.selfUser.get()
        val option = ImageOptions.Builder().setPlaceImage(R.drawable.tuicallkit_ic_avatar).setBlurEffect(80f).build()
        ImageLoader.load(context, imageBackground, selfUser.avatar.get(), option)
        imageBackground.setColorFilter(ContextCompat.getColor(context, R.color.tuicallkit_color_blur_mask))
    }

    private fun updateView() {
        if (CallManager.instance.userState.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
            VideoFactory.instance.clearVideoView()
            return
        }

        val scene = CallManager.instance.callState.scene.get()
        if (scene == TUICallDefine.Scene.GROUP_CALL || scene == TUICallDefine.Scene.MULTI_CALL) {
            updateMultiCallLayout()
        } else {
            updateSingleCallLayout()
        }
    }

    private fun updateSingleCallLayout() {
        val isAudio = CallManager.instance.callState.mediaType.get() == TUICallDefine.MediaType.Audio
        if (isAudio) {
            imageAudioView.visibility = VISIBLE
            layoutVideoView.visibility = GONE
            return
        }
        imageAudioView.visibility = GONE
        val selfUser = CallManager.instance.userState.selfUser.get()
        textCallStatus.visibility = when {
            selfUser.callStatus.get() == TUICallDefine.Status.Waiting -> VISIBLE
            else -> GONE
        }

        if (selfUser.callStatus.get() == TUICallDefine.Status.Accept) {
            showUserVideoView(remoteUser)
        } else {
            showUserVideoView(selfUser)
        }
    }

    private fun updateMultiCallLayout() {
        if (CallManager.instance.userState.selfUser.get().callStatus.get() == TUICallDefine.Status.Waiting) {
            imageAudioView.visibility = VISIBLE
            layoutVideoView.visibility = GONE
            return
        }
        if (showingUserId == "") {
            showSelf()
        }
        val list = ArrayList<UserState.User>()
        list.add(CallManager.instance.userState.selfUser.get())
        list.addAll(CallManager.instance.userState.remoteUserList.get())
        for (user in list) {
            if (user.playoutVolume.get() > Constants.MIN_AUDIO_VOLUME) {
                if (user.id == showingUserId) {
                    return
                }
                showingUserId = user.id
                showUserVideoView(user)
                return
            }
        }
    }

    private fun showUserVideoView(user: UserState.User) {
        imageAudioView.visibility = GONE
        textCallStatus.visibility = GONE
        var videoView = VideoFactory.instance.findVideoView(user.id)
        resetView(videoView)
        if (videoView == null) {
            videoView = VideoFactory.instance.createVideoView(context, user)
            CallManager.instance.startRemoteView(user.id, videoView, null)
        }
        layoutVideoView.removeAllViews()
        layoutVideoView.addView(videoView)
        layoutVideoView.visibility = VISIBLE
    }

    private fun showSelf() {
        val self: UserState.User = CallManager.instance.userState.selfUser.get()
        showingUserId = self.id
        showUserVideoView(self)
    }

    private fun updateCallStatusHint() {
        val callStatus = CallManager.instance.userState.selfUser.get().callStatus.get()
        val isAudio = CallManager.instance.callState.mediaType.get() == TUICallDefine.MediaType.Audio
        val isSingleCall = CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL

        textCallStatus.text = when (callStatus) {
            TUICallDefine.Status.Waiting -> context.getString(R.string.tuicallkit_wait_response)
            else -> DateTimeUtil.formatSecondsTo00(CallManager.instance.callState.callDurationCount.get())
        }

        if (isSingleCall && !isAudio && callStatus == TUICallDefine.Status.Waiting) {
            textCallStatus.setTextColor(ContextCompat.getColor(context, R.color.tuicallkit_color_white))
        }
    }

    private fun resetView(view: View?) {
        if (view?.parent != null) {
            (view.parent as ViewGroup).removeView(view)
        }
    }

    private fun fadeViewInOut(isEnterPipMode: Boolean) {
        val endAlpha = if (isEnterPipMode) 1f else 0f
        this.animate()?.alpha(endAlpha)?.setDuration(500)?.start()
    }
}