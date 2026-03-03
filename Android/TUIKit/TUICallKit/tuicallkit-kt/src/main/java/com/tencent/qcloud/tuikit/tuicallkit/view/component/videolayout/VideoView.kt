package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.constraintlayout.utils.widget.ImageFilterView
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.cloud.tuikit.engine.common.TUIVideoView
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.ScreenUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import com.tencent.qcloud.tuikit.tuicallkit.state.ViewState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.multicall.MultiCallLoadingView
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.imageloader.ImageOptions
import com.trtc.tuikit.common.livedata.Observer

class VideoView(context: Context, userInfo: UserState.User) : RelativeLayout(context) {
    private val context = context.applicationContext
    private var user: UserState.User = userInfo
    private var isShowFloatWindow: Boolean = false

    private lateinit var videoView: TUIVideoView
    private lateinit var imageAvatar: ImageFilterView
    private lateinit var buttonSwitchCamera: ImageView
    private lateinit var buttonBlur: ImageView
    private lateinit var imageNetworkBad: ImageView
    private lateinit var textUserName: TextView
    private lateinit var imageAudioInput: ImageView
    private lateinit var imageBackground: ImageView
    private lateinit var imageLoading: MultiCallLoadingView

    private var videoAvailableObserver = Observer<Boolean> {
        updateVideoView()
        updateBackground()
        updateUserAvatarView()
        updateUserNameView()
        updateSwitchCameraButton()
        updateBlurButton()
    }

    private var audioAvailableObserver = Observer<Boolean> {
        updateAudioInputIcon()
    }

    private var playoutVolumeObserver = Observer<Int> {
        updateAudioInputIcon()
    }

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.None) {
            unregisterObserver()
            return@Observer
        }
        updateImageLoadingView()
        updateUserAvatarView()
    }

    private var avatarObserver = Observer<String> {
        updateUserAvatarView()
        updateBackground()
    }

    private var nicknameObserver = Observer<String> {
        textUserName.text = it
    }

    private var showLargeViewUserIdObserver = Observer<String> {
        updateUserNameView()
        updateSwitchCameraButton()
        updateBlurButton()
    }

    private var networkQualityObserver = Observer<Boolean> {
        updateNetworkHint()
    }

    private val viewRouterObserver = Observer<ViewState.ViewRouter> {
        isShowFloatWindow = it == ViewState.ViewRouter.FloatView
        updateNetworkHint()
        updateAudioInputIcon()
        updateSwitchCameraButton()
        updateBlurButton()
        updateUserNameView()
    }

    private val isInPipObserver = Observer<Boolean> {
        if (GlobalState.instance.enablePipMode) {
            buttonSwitchCamera.visibility = if (it) View.GONE else View.VISIBLE
            buttonBlur.visibility = if (it) View.GONE else View.VISIBLE
            textUserName.visibility = if (it) View.GONE else View.VISIBLE
        }
    }

    init {
        initView()
        registerObserver()
    }

    private fun registerObserver() {
        user.videoAvailable.observe(videoAvailableObserver)
        user.avatar.observe(avatarObserver)
        user.nickname.observe(nicknameObserver)
        user.callStatus.observe(callStatusObserver)
        user.audioAvailable.observe(audioAvailableObserver)
        user.playoutVolume.observe(playoutVolumeObserver)
        user.networkQualityReminder.observe(networkQualityObserver)
        CallManager.instance.viewState.showLargeViewUserId.observe(showLargeViewUserIdObserver)
        CallManager.instance.viewState.router.observe(viewRouterObserver)
        CallManager.instance.viewState.enterPipMode.observe(isInPipObserver)
    }

    private fun unregisterObserver() {
        user.videoAvailable.removeObserver(videoAvailableObserver)
        user.avatar.removeObserver(avatarObserver)
        user.nickname.removeObserver(nicknameObserver)
        user.callStatus.removeObserver(callStatusObserver)
        user.audioAvailable.removeObserver(audioAvailableObserver)
        user.playoutVolume.removeObserver(playoutVolumeObserver)
        user.networkQualityReminder.removeObserver(networkQualityObserver)
        CallManager.instance.viewState.showLargeViewUserId.removeObserver(showLargeViewUserIdObserver)
        CallManager.instance.viewState.router.removeObserver(viewRouterObserver)
        CallManager.instance.viewState.enterPipMode.removeObserver(isInPipObserver)
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_video_view, this, true)
        videoView = findViewById(R.id.tx_cloud_view)
        imageAvatar = findViewById(R.id.img_head)
        textUserName = findViewById(R.id.tv_name)
        imageAudioInput = findViewById(R.id.iv_audio_input)
        imageBackground = findViewById(R.id.img_video_background)
        imageNetworkBad = findViewById(R.id.iv_network)
        imageLoading = findViewById(R.id.img_loading)
        buttonSwitchCamera = findViewById(R.id.iv_switch_camera)
        buttonSwitchCamera.setOnClickListener {
            var camera = TUICommonDefine.Camera.Back
            if (CallManager.instance.mediaState.isFrontCamera.get() == TUICommonDefine.Camera.Back) {
                camera = TUICommonDefine.Camera.Front
            }
            CallManager.instance.switchCamera(camera)
        }
        buttonBlur = findViewById(R.id.iv_blur)
        buttonBlur.setOnClickListener {
            CallManager.instance.setBlurBackground(!CallManager.instance.viewState.isVirtualBackgroundOpened.get())
        }

        updateVideoView()
        updateImageLoadingView()
        updateUserAvatarView()
        updateUserNameView()
        updateBackground()
    }

    fun getVideoView(): TUIVideoView {
        return videoView
    }

    private fun updateVideoView() {
        if (user.videoAvailable.get()) {
            CallManager.instance.startRemoteView(user.id, this, null)
            videoView.visibility = View.VISIBLE
        } else {
            videoView.visibility = View.GONE
        }
    }

    private fun updateImageLoadingView() {
        val scene = CallManager.instance.callState.scene.get()
        if ((TUICallDefine.Scene.GROUP_CALL == scene || TUICallDefine.Scene.MULTI_CALL == scene)
            && TUICallDefine.Status.Waiting == user.callStatus.get() && user.id != TUILogin.getLoginUser()
        ) {
            imageLoading.visibility = View.VISIBLE
            imageLoading.startLoading()
        } else {
            imageLoading.visibility = View.GONE
            imageLoading.stopLoading()
        }
    }

    private fun updateAudioInputIcon() {
        if (isShowFloatWindow || CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            imageAudioInput.visibility = View.GONE
            return
        }

        when {
            !user.audioAvailable.get() && user.id == CallManager.instance.userState.selfUser.get().id -> {
                imageAudioInput.setImageResource(R.drawable.tuicallkit_ic_self_mute)
                imageAudioInput.visibility = View.VISIBLE
            }
            user.playoutVolume.get() > Constants.MIN_AUDIO_VOLUME -> {
                imageAudioInput.setImageResource(R.drawable.tuicallkit_ic_audio_input)
                imageAudioInput.visibility = View.VISIBLE
            }
            else -> imageAudioInput.visibility = View.GONE
        }
    }
    private fun updateNetworkHint() {
        if (isShowFloatWindow || CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            imageNetworkBad.visibility = View.GONE
            return
        }
        when {
            user.networkQualityReminder.get() -> imageNetworkBad.visibility = View.VISIBLE
            else -> imageNetworkBad.visibility = View.GONE
        }
    }

    private fun updateSwitchCameraButton() {
        if (GlobalState.instance.disableControlButtonSet.contains(Constants.ControlButton.SwitchCamera)) {
            buttonSwitchCamera.visibility = View.GONE
            return
        }
        if (isShowFloatWindow || CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            buttonSwitchCamera.visibility = View.GONE
            return
        }
        val selfUser = CallManager.instance.userState.selfUser.get()
        val largeUserId = CallManager.instance.viewState.showLargeViewUserId.get()

        if (user.videoAvailable.get() && user.id == selfUser.id && user.id == largeUserId) {
            buttonSwitchCamera.visibility = View.VISIBLE
        } else {
            buttonSwitchCamera.visibility = View.GONE
        }
    }

    private fun updateBlurButton() {
        if (!GlobalState.instance.enableVirtualBackground) {
            buttonBlur.visibility = View.GONE
            return
        }
        if (isShowFloatWindow || CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            buttonBlur.visibility = View.GONE
            return
        }
        val selfUser = CallManager.instance.userState.selfUser.get()
        val largeUserId = CallManager.instance.viewState.showLargeViewUserId.get()

        if (user.videoAvailable.get() && user.id == selfUser.id && user.id == largeUserId) {
            buttonBlur.visibility = View.VISIBLE
        } else {
            buttonBlur.visibility = View.GONE
        }
    }

    private fun updateUserAvatarView() {
        if (user.videoAvailable.get()) {
            imageAvatar.visibility = View.GONE
            return
        }

        val selfUser = CallManager.instance.userState.selfUser.get()
        if (user.id == selfUser.id && selfUser.callStatus.get() == TUICallDefine.Status.Waiting
            && CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL
        ) {
            imageAvatar.visibility = View.GONE
            return
        }

        val layoutParams = imageAvatar.layoutParams
        if (TUICallDefine.Scene.SINGLE_CALL != CallManager.instance.callState.scene.get()) {
            layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
            layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT
            imageAvatar.round = 0f
        } else {
            layoutParams.width = ScreenUtil.dip2px(80f)
            layoutParams.height = ScreenUtil.dip2px(80f)
            imageAvatar.round = 12f
        }
        imageAvatar.layoutParams = layoutParams
        ImageLoader.load(context, imageAvatar, user.avatar.get(), R.drawable.tuicallkit_ic_avatar)
        imageAvatar.visibility = VISIBLE
    }

    private fun updateUserNameView() {
        if (isShowFloatWindow || CallManager.instance.callState.scene.get() == TUICallDefine.Scene.SINGLE_CALL) {
            textUserName.visibility = View.GONE
            return
        }
        val shouldShowUserId = CallManager.instance.viewState.showLargeViewUserId.get() == user.id

        textUserName.visibility = if (shouldShowUserId) View.VISIBLE else View.GONE
        textUserName.text = user.nickname.get()
    }

    private fun updateBackground() {
        if (user.videoAvailable.get() || CallManager.instance.callState.scene.get() != TUICallDefine.Scene.SINGLE_CALL) {
            imageBackground.visibility = View.GONE
            return
        }

        imageBackground.visibility = View.VISIBLE
        val option = ImageOptions.Builder().setPlaceImage(R.drawable.tuicallkit_ic_avatar).setBlurEffect(80f).build()
        ImageLoader.load(context, imageBackground, user.avatar.get(), option)
        imageBackground.setColorFilter(ContextCompat.getColor(context, R.color.tuicallkit_color_blur_mask))
    }
}