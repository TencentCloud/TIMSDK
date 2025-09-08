package com.tencent.qcloud.tuikit.tuicallkit.view.component.floatwindow

import android.content.Context
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.VideoFactory
import com.trtc.tuikit.common.livedata.Observer
import com.trtc.tuikit.common.ui.floatwindow.FloatWindowManager

class FloatWindowView(context: Context) : RelativeLayout(context) {
    private val context: Context = context.applicationContext
    private lateinit var layoutVideoView: FrameLayout
    private lateinit var imageAudioView: ImageView
    private lateinit var textCallStatus: TextView
    private lateinit var imageFloatVideoMark: ImageView
    private lateinit var imageFloatAudioMark: ImageView

    private var remoteUser: UserState.User = UserState.User()
    private var currentShowVideoUserId: String = ""

    private val observer: Observer<Any> = Observer {
        updateView()
    }

    private val callDurationObserver: Observer<Int> = Observer {
        post {
            updateCallStatusHint()
        }
    }

    private val mediaAvailableObserver: Observer<Boolean> = Observer {
        updateSelfAudioAndVideoView()
    }

    init {
        val remoteUserList = CallManager.instance.userState.remoteUserList.get()
        if (remoteUserList != null && remoteUserList.size > 0) {
            remoteUser = remoteUserList.first()
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        initView()
        registerObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        unregisterObserver()
    }

    private fun registerObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.observe(observer)
        CallManager.instance.userState.selfUser.get().videoAvailable.observe(mediaAvailableObserver)
        CallManager.instance.userState.selfUser.get().audioAvailable.observe(mediaAvailableObserver)
        CallManager.instance.callState.callDurationCount.observe(callDurationObserver)
        val scene = CallManager.instance.callState.scene.get()
        if (scene == TUICallDefine.Scene.GROUP_CALL || scene == TUICallDefine.Scene.MULTI_CALL) {
            CallManager.instance.userState.selfUser.get().playoutVolume.observe(observer)
            for (user in CallManager.instance.userState.remoteUserList.get()) {
                user.playoutVolume.observe(observer)
            }
        }
    }

    private fun unregisterObserver() {
        CallManager.instance.userState.selfUser.get().callStatus.removeObserver(observer)
        CallManager.instance.userState.selfUser.get().videoAvailable.removeObserver(mediaAvailableObserver)
        CallManager.instance.userState.selfUser.get().audioAvailable.removeObserver(mediaAvailableObserver)
        CallManager.instance.callState.callDurationCount.removeObserver(callDurationObserver)

        val scene = CallManager.instance.callState.scene.get()
        if (scene == TUICallDefine.Scene.GROUP_CALL || scene == TUICallDefine.Scene.MULTI_CALL) {
            CallManager.instance.userState.selfUser.get().playoutVolume.removeObserver(observer)
            for (user in CallManager.instance.userState.remoteUserList.get()) {
                user.playoutVolume.removeObserver(observer)
            }
        }
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_float_call_view, this)
        layoutVideoView = findViewById(R.id.rl_video_view)
        imageAudioView = findViewById(R.id.iv_audio_view)
        textCallStatus = findViewById(R.id.tv_float_call_status)
        imageFloatVideoMark = findViewById(R.id.iv_float_video_mark)
        imageFloatAudioMark = findViewById(R.id.iv_float_audio_mark)

        updateView()
        updateCallStatusHint()
    }

    private fun updateView() {
        if (CallManager.instance.userState.selfUser.get().callStatus.get() == TUICallDefine.Status.None) {
            VideoFactory.instance.clearVideoView()
            FloatWindowManager.sharedInstance().dismiss()
            return
        }

        val scene = CallManager.instance.callState.scene.get()
        if (scene == TUICallDefine.Scene.GROUP_CALL || scene == TUICallDefine.Scene.MULTI_CALL) {
            updateGroupCallLayout()
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
        layoutVideoView.visibility = VISIBLE
        val wWidth = context.resources.getDimension(R.dimen.tuicallkit_video_small_view_width).toInt()
        val hHeight = context.resources.getDimension(R.dimen.tuicallkit_video_small_view_height).toInt()
        layoutVideoView.layoutParams.width = wWidth
        layoutVideoView.layoutParams.height = hHeight

        val selfUser = CallManager.instance.userState.selfUser.get()
        textCallStatus.visibility = when {
            selfUser.callStatus.get() == TUICallDefine.Status.Waiting -> VISIBLE
            else -> GONE
        }

        if (selfUser.callStatus.get() == TUICallDefine.Status.Accept) {
            val videoView = VideoFactory.instance.createVideoView(context, remoteUser)
            resetView(videoView)
            CallManager.instance.startRemoteView(remoteUser.id, videoView, null)
            layoutVideoView.addView(videoView)
        } else {
            val videoView = VideoFactory.instance.createVideoView(context, selfUser)
            resetView(videoView)
            layoutVideoView.addView(videoView)
        }
    }

    private fun updateGroupCallLayout() {
        updateSelfAudioAndVideoView()
        if (CallManager.instance.userState.selfUser.get().callStatus.get() == TUICallDefine.Status.Waiting) {
            imageAudioView.visibility = VISIBLE
            layoutVideoView.visibility = GONE
            return
        }

        val list = ArrayList<UserState.User>()
        list.add(CallManager.instance.userState.selfUser.get())
        list.addAll(CallManager.instance.userState.remoteUserList.get())

        for (user in list) {
            if (user.playoutVolume.get() > Constants.MIN_AUDIO_VOLUME) {
                if (user.id == currentShowVideoUserId) {
                    return
                }
                currentShowVideoUserId = user.id
                imageAudioView.visibility = GONE
                textCallStatus.visibility = GONE
                layoutVideoView.visibility = VISIBLE

                var videoView = VideoFactory.instance.findVideoView(user.id)
                resetView(videoView)
                if (videoView == null) {
                    videoView = VideoFactory.instance.createVideoView(context, user)
                    CallManager.instance.startRemoteView(user.id, videoView, null)
                }

                layoutVideoView.removeAllViews()
                layoutVideoView.addView(videoView)
                return
            }
        }
        currentShowVideoUserId = ""
        imageAudioView.visibility = VISIBLE
        textCallStatus.visibility = VISIBLE
        layoutVideoView.visibility = GONE
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

    private fun updateSelfAudioAndVideoView() {
        val scene = CallManager.instance.callState.scene.get()
        if (scene != TUICallDefine.Scene.GROUP_CALL && scene != TUICallDefine.Scene.MULTI_CALL) {
            return
        }
        val selfUser = CallManager.instance.userState.selfUser.get()
        val videoResId = when {
            selfUser.videoAvailable.get() -> R.drawable.tuicallkit_ic_video_incoming
            else -> R.drawable.tuicallkit_ic_float_video_off
        }
        imageFloatVideoMark.setImageResource(videoResId)
        imageFloatVideoMark.visibility = VISIBLE

        val audioResId = when {
            selfUser.audioAvailable.get() -> R.drawable.tuicallkit_ic_float_audio_on
            else -> R.drawable.tuicallkit_ic_float_audio_off
        }
        imageFloatAudioMark.setImageResource(audioResId)
        imageFloatAudioMark.visibility = VISIBLE
    }

    private fun resetView(view: View?) {
        if (view?.parent != null) {
            (view.parent as ViewGroup).removeView(view)
        }
    }

    override fun onInterceptTouchEvent(ev: MotionEvent?): Boolean {
        return true
    }
}