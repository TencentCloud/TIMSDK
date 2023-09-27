package com.tencent.qcloud.tuikit.tuicallkit.view.root

import android.content.Context
import android.view.LayoutInflater
import android.widget.LinearLayout
import android.widget.RelativeLayout
import androidx.constraintlayout.widget.ConstraintLayout
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.view.component.CallWaitingHintView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.InviteUserButton
import com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.group.InviteeAvatarListView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.CallTimerView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview.FloatingWindowButton
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.AudioCallerWaitingAndAcceptedView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.AudioAndVideoCalleeWaitingView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.VideoCallerAndCalleeAcceptedView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.GroupCallVideoLayout
import com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.group.GroupCallerUserInfoView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.root.GroupCallViewModel

class GroupCallView(context: Context) : BaseCallView(context) {

    private var layoutRender: RelativeLayout? = null
    private var layoutFunction: RelativeLayout? = null
    private var layoutCallTime: RelativeLayout? = null
    private var layoutInviterWaitHint: RelativeLayout? = null
    private var layoutFloatIcon: RelativeLayout? = null
    private var layoutInviteUserIcon: RelativeLayout? = null
    private var layoutCallerUserInfo: RelativeLayout? = null
    private var layoutInviteeWaitHint: RelativeLayout? = null
    private var layoutInviteeAvatar: LinearLayout? = null

    private var groupCallVideoLayout: GroupCallVideoLayout? = null
    private var functionView: BaseCallView? = null
    private var floatingWindowButton: FloatingWindowButton? = null
    private var inviteUserButton: InviteUserButton? = null
    private var callTimerView: CallTimerView? = null
    private var callWaitingHintView: CallWaitingHintView? = null
    private var callerUserInfo: GroupCallerUserInfoView? = null
    private var inviteeAvatarListView: InviteeAvatarListView? = null

    private var viewModel = GroupCallViewModel()

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        refreshCallerUserInfoView()
        refreshInviteeAvatarView()

        refreshRenderView()
        refreshFunctionView()
        refreshFloatView()
        refreshInviteUserIconView()
        refreshCallStatusView()
        refreshTimerView()
    }

    init {
        initView()

        addObserver()
    }

    override fun clear() {
        groupCallVideoLayout?.clear()
        functionView?.clear()
        floatingWindowButton?.clear()
        inviteUserButton?.clear()
        callTimerView?.clear()
        callWaitingHintView?.clear()
        callerUserInfo?.clear()
        inviteeAvatarListView?.clear()
        removeObserver()
    }

    fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_root_view_group, this)
        layoutCallerUserInfo = findViewById(R.id.rl_layout_caller_user_info)
        layoutInviteeWaitHint = findViewById(R.id.rl_layout_invitee_wait_hint)
        layoutInviteeAvatar = findViewById(R.id.ll_layout_invitee_avatar)

        layoutRender = findViewById(R.id.rl_layout_render)
        layoutFunction = findViewById(R.id.rl_layout_function)
        layoutFloatIcon = findViewById(R.id.rl_layout_float_icon)
        layoutInviteUserIcon = findViewById(R.id.rl_layout_add_user)
        layoutInviterWaitHint = findViewById(R.id.rl_layout_call_status)
        layoutCallTime = findViewById(R.id.rl_layout_call_time)

        if (TUICallDefine.MediaType.Audio == viewModel.mediaType.get()) {
            findViewById<ConstraintLayout>(R.id.cl_root).setBackgroundColor(
                context.resources.getColor(R.color.tuicalling_color_white)
            )
        } else {
            findViewById<ConstraintLayout>(R.id.cl_root).setBackgroundColor(
                context.resources.getColor(R.color.tuicalling_color_black)
            )
        }

        refreshCallerUserInfoView()
        refreshInviteeAvatarView()

        refreshRenderView()
        refreshFunctionView()
        refreshFloatView()
        refreshInviteUserIconView()
        refreshCallStatusView()
        refreshTimerView()
    }

    private fun refreshCallerUserInfoView() {
        if (TUICallDefine.Status.Waiting == viewModel.callStatus.get()
            && TUICallDefine.Role.Called == viewModel.callRole.get()
        ) {
            layoutCallerUserInfo?.visibility = VISIBLE
            callerUserInfo = GroupCallerUserInfoView(context)
            layoutCallerUserInfo!!.removeAllViews()
            layoutCallerUserInfo!!.addView(callerUserInfo)
        } else {
            layoutCallerUserInfo?.visibility = GONE
        }
    }

    private fun refreshInviteeAvatarView() {
        if (TUICallDefine.Status.Waiting == viewModel.callStatus.get()
            && TUICallDefine.Role.Called == viewModel.callRole.get()
        ) {
            layoutInviteeAvatar?.visibility = VISIBLE
            inviteeAvatarListView = InviteeAvatarListView(context)
            layoutInviteeAvatar!!.removeAllViews()
            layoutInviteeAvatar!!.addView(inviteeAvatarListView)
        } else {
            layoutInviteeAvatar?.visibility = GONE
        }
    }

    private fun refreshTimerView() {
        if (TUICallDefine.Status.Accept == viewModel.callStatus.get()) {
            layoutCallTime?.removeAllViews()
            callTimerView = CallTimerView(context)
            layoutCallTime?.addView(callTimerView)
        } else {
            layoutCallTime?.removeAllViews()
            callTimerView = null
        }
    }

    private fun refreshCallStatusView() {
        if (TUICallDefine.Status.Waiting == viewModel.callStatus.get()) {
            if (TUICallDefine.Role.Called == viewModel.callRole.get()) {
                layoutInviteeWaitHint?.visibility = VISIBLE
                layoutInviterWaitHint?.visibility = GONE
                layoutInviteeWaitHint?.removeAllViews()
                callWaitingHintView = CallWaitingHintView(context)
                layoutInviteeWaitHint?.addView(callWaitingHintView)
            } else {
                layoutInviteeWaitHint?.visibility = GONE
                layoutInviterWaitHint?.visibility = VISIBLE
                layoutInviterWaitHint?.removeAllViews()
                callWaitingHintView = CallWaitingHintView(context)
                layoutInviterWaitHint?.addView(callWaitingHintView)
            }
        } else {
            layoutInviterWaitHint?.removeAllViews()
            callWaitingHintView = null
        }
    }

    private fun refreshInviteUserIconView() {
        if (TUICallDefine.Role.Caller == viewModel.callRole.get() || TUICallDefine.Status.Accept == viewModel.callStatus.get()) {
            layoutInviteUserIcon?.removeAllViews()
            inviteUserButton?.clear()
            inviteUserButton = InviteUserButton(context)
            layoutInviteUserIcon?.addView(inviteUserButton)
        } else {
            layoutInviteUserIcon?.removeAllViews()
            inviteUserButton?.clear()
            inviteUserButton = null
        }
    }

    private fun refreshFloatView() {
        layoutFloatIcon?.removeAllViews()
        floatingWindowButton = FloatingWindowButton(context)
        layoutFloatIcon?.addView(floatingWindowButton)
    }

    private fun refreshFunctionView() {
        if (TUICallDefine.Status.Waiting == viewModel.callStatus.get()) {
            if (viewModel.callRole.get() == TUICallDefine.Role.Caller) {
                if (viewModel.mediaType.get() == TUICallDefine.MediaType.Audio) {
                    functionView = AudioCallerWaitingAndAcceptedView(context)
                } else {
                    functionView = VideoCallerAndCalleeAcceptedView(context)
                }
            } else {
                functionView = AudioAndVideoCalleeWaitingView(context)
            }
        } else if (TUICallDefine.Status.Accept == viewModel.callStatus.get()) {
            if (viewModel.mediaType.get() == TUICallDefine.MediaType.Audio) {
                functionView = AudioCallerWaitingAndAcceptedView(context)
            } else {
                functionView = VideoCallerAndCalleeAcceptedView(context)
            }
        }

        layoutFunction!!.removeAllViews()
        if (null != functionView) {
            layoutFunction!!.addView(functionView)
        }
    }

    private fun refreshRenderView() {
        if (TUICallDefine.Status.Waiting == viewModel.callStatus.get()
            && TUICallDefine.Role.Called == viewModel.callRole.get()
        ) {
            layoutRender?.visibility = GONE
        } else if (TUICallDefine.Status.Accept == viewModel.callStatus.get() || TUICallDefine.Status.Waiting == viewModel.callStatus.get()) {
            layoutRender?.visibility = VISIBLE
            groupCallVideoLayout = GroupCallVideoLayout(context)
            layoutRender!!.removeAllViews()
            layoutRender!!.addView(groupCallVideoLayout)
        }
    }

    private fun addObserver() {
        viewModel.callStatus.observe(callStatusObserver)
    }

    private fun removeObserver() {
        viewModel.callStatus.removeObserver(callStatusObserver)
    }
}