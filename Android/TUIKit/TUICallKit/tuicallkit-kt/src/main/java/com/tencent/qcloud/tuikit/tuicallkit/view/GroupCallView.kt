package com.tencent.qcloud.tuikit.tuicallkit.view

import android.content.Context
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.state.GlobalState
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.CallFunctionLayout
import com.tencent.qcloud.tuikit.tuicallkit.view.component.hint.CallHintView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.hint.CallTimerView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.inviteuser.InviteUserButton
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.CallVideoLayout
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.imageloader.ImageOptions

class GroupCallView(context: Context) : ConstraintLayout(context) {
    private val activityContext: Context = context

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        initView()
    }

    private fun initView() {
        LayoutInflater.from(activityContext).inflate(R.layout.tuicallkit_root_view_group, this)

        addVideoLayout()
        addFunctionLayout()
        addCallTimeView()
        addCallHintView()
        addFloatButton()
        addInviteUserButton()
        setBackground()
    }

    private fun addVideoLayout() {
        val layoutVideo: FrameLayout = findViewById(R.id.rl_layout_video_group)
        layoutVideo.addView(CallVideoLayout(activityContext))
    }

    private fun addFunctionLayout() {
        val layoutFunction: FrameLayout = findViewById(R.id.rl_layout_function)
        layoutFunction.addView(CallFunctionLayout(activityContext))
    }

    private fun addCallTimeView() {
        val layoutTimer: FrameLayout = findViewById(R.id.rl_layout_call_time)
        layoutTimer.addView(CallTimerView(activityContext))
    }

    private fun addCallHintView() {
        val layoutCallHint: FrameLayout = findViewById(R.id.rl_layout_call_hint)
        layoutCallHint.addView(CallHintView(activityContext))

        if (CallManager.instance.userState.selfUser.get().callRole == TUICallDefine.Role.Caller) {
            val lp = LayoutParams(LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            lp.startToStart = LayoutParams.PARENT_ID
            lp.endToEnd = LayoutParams.PARENT_ID
            lp.topToTop = R.id.gl_horizontal_top
            lp.topMargin = 20
            layoutCallHint.layoutParams = lp
        }
    }

    private fun addFloatButton() {
        val floatButton: ImageView = findViewById(R.id.image_float_icon_group)
        if (!GlobalState.instance.enableFloatWindow) {
            floatButton.visibility = GONE
        }
        // TODO: 仅支持悬浮窗, 后续支持画中画
        floatButton.setOnClickListener {
            TUICore.notifyEvent(Constants.KEY_TUI_CALLKIT, Constants.SUB_KEY_SHOW_FLOAT_WINDOW, null)
        }
    }

    private fun addInviteUserButton() {
        if (CallManager.instance.callState.chatGroupId.isNullOrEmpty()) {
            return
        }
        val inviteUserButton: FrameLayout = findViewById(R.id.rl_layout_invite_user)
        inviteUserButton.addView(InviteUserButton(activityContext))
    }

    private fun setBackground() {
        val imageBackground: ImageView = findViewById(R.id.img_group_view_background)
        val selfUser = CallManager.instance.userState.selfUser.get()
        val option = ImageOptions.Builder().setPlaceImage(R.drawable.tuicallkit_ic_avatar).setBlurEffect(80f).build()
        ImageLoader.load(activityContext, imageBackground, selfUser.avatar.get(), option)
        imageBackground.setColorFilter(ContextCompat.getColor(activityContext, R.color.tuicallkit_color_blur_mask))
    }
}