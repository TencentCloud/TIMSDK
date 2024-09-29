package com.tencent.qcloud.tuikit.tuicallkit.view.root

import android.content.Context
import android.view.LayoutInflater
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ScrollView
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.component.CallTimerView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.CallWaitingHintView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.InviteUserButton
import com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview.FloatingWindowButton
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.AudioAndVideoCalleeWaitingView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.function.VideoCallerAndCalleeAcceptedView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.group.GroupCallerUserInfoView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.group.InviteeAvatarListView
import com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.GroupCallVideoLayout

class GroupCallView(context: Context) : BaseCallView(context) {

    private var layoutRender: ScrollView? = null
    private var layoutFunction: FrameLayout? = null
    private var layoutCallTime: FrameLayout? = null
    private var layoutInviterWaitHint: FrameLayout? = null
    private var layoutFloatIcon: FrameLayout? = null
    private var layoutInviteUserIcon: FrameLayout? = null
    private var layoutCallerUserInfo: FrameLayout? = null
    private var layoutInviteeWaitHint: FrameLayout? = null
    private var layoutInviteeAvatar: LinearLayout? = null
    private var imageBackground: ImageView? = null

    private var groupCallVideoLayout: GroupCallVideoLayout? = null
    private var functionWaitView: BaseCallView? = null
    private var functionAcceptView: BaseCallView? = null
    private var floatingWindowButton: FloatingWindowButton? = null
    private var inviteUserButton: InviteUserButton? = null
    private var callTimerView: CallTimerView? = null
    private var callWaitingHintView: CallWaitingHintView? = null
    private var callerUserInfo: GroupCallerUserInfoView? = null
    private var inviteeAvatarListView: InviteeAvatarListView? = null

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        refreshCallerUserInfoView()
        refreshInviteeAvatarView()

        refreshRenderView()
        refreshFunctionView()
        refreshFloatView()
        refreshInviteUserIconView()
        refreshCallStatusView()
        refreshTimerView()

        showAntiFraudReminder()
    }

    private var bottomViewExpandObserver = Observer<Boolean> {
        layoutFunction?.background = context.resources.getDrawable(R.drawable.tuicallkit_bg_group_call_bottom)
    }

    init {
        initView()
        addObserver()
    }

    override fun clear() {
        groupCallVideoLayout?.clear()
        functionWaitView?.clear()
        functionAcceptView?.clear()
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
        imageBackground = findViewById(R.id.img_group_view_background)

        ImageLoader.loadBlurImage(context, imageBackground, TUICallState.instance.selfUser.get().avatar.get())

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
        if (TUICallDefine.Status.Waiting == TUICallState.instance.selfUser.get().callStatus.get()
            && TUICallDefine.Role.Called == TUICallState.instance.selfUser.get().callRole.get()
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
        if (TUICallDefine.Status.Waiting == TUICallState.instance.selfUser.get().callStatus.get()
            && TUICallDefine.Role.Called == TUICallState.instance.selfUser.get().callRole.get()
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
        if (TUICallDefine.Status.Accept == TUICallState.instance.selfUser.get().callStatus.get()) {
            layoutCallTime?.removeAllViews()
            callTimerView = CallTimerView(context)
            layoutCallTime?.addView(callTimerView)
        } else {
            layoutCallTime?.removeAllViews()
            callTimerView = null
        }
    }

    private fun refreshCallStatusView() {
        if (TUICallDefine.Status.Waiting == TUICallState.instance.selfUser.get().callStatus.get()) {
            if (TUICallDefine.Role.Called == TUICallState.instance.selfUser.get().callRole.get()) {
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
        if ((TUICallDefine.Role.Caller == TUICallState.instance.selfUser.get().callRole.get()
                    && TUICallDefine.Status.None != TUICallState.instance.selfUser.get().callStatus.get())
            || TUICallDefine.Status.Accept == TUICallState.instance.selfUser.get().callStatus.get()
        ) {
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
        if (TUICallState.instance.selfUser.get().callRole.get() == TUICallDefine.Role.Called) {
            if (TUICallDefine.Status.Waiting == TUICallState.instance.selfUser.get().callStatus.get()) {
                functionWaitView = AudioAndVideoCalleeWaitingView(context)
                layoutFunction!!.removeAllViews()
                layoutFunction!!.addView(functionWaitView)
            } else {
                if (functionAcceptView == null) {
                    functionAcceptView = VideoCallerAndCalleeAcceptedView(context)
                }
                layoutFunction!!.removeAllViews()
                layoutFunction!!.addView(functionAcceptView)
            }
        } else if (functionAcceptView == null) {
            functionAcceptView = VideoCallerAndCalleeAcceptedView(context)
            layoutFunction!!.removeAllViews()
            layoutFunction!!.addView(functionAcceptView)
        }
    }

    private fun refreshRenderView() {
        if (TUICallDefine.Role.Called == TUICallState.instance.selfUser.get().callRole.get()) {
            if (TUICallDefine.Status.Waiting == TUICallState.instance.selfUser.get().callStatus.get()) {
                layoutRender?.visibility = GONE
            } else {
                layoutRender?.visibility = VISIBLE
                if (groupCallVideoLayout == null) {
                    groupCallVideoLayout = GroupCallVideoLayout(context)
                    layoutRender!!.removeAllViews()
                    layoutRender!!.addView(groupCallVideoLayout)
                }
            }
        } else if (groupCallVideoLayout == null) {
            layoutRender?.visibility = VISIBLE
            groupCallVideoLayout = GroupCallVideoLayout(context)
            layoutRender!!.removeAllViews()
            layoutRender!!.addView(groupCallVideoLayout)
        }
    }

    private fun showAntiFraudReminder() {
        if (TUICallDefine.Status.Accept != TUICallState.instance.selfUser.get().callStatus.get()) {
            return
        }

        if (TUICore.getService(TUIConstants.Service.TUI_PRIVACY) == null) {
            return
        }
        var map = HashMap<String, Any?>()
        map[TUIConstants.Privacy.PARAM_DIALOG_CONTEXT] = context
        TUICore.callService(
            TUIConstants.Service.TUI_PRIVACY, TUIConstants.Privacy.METHOD_ANTO_FRAUD_REMINDER, map, null
        )
    }

    private fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
        TUICallState.instance.isBottomViewExpand.observe(bottomViewExpandObserver)
    }

    private fun removeObserver() {
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.isBottomViewExpand.removeObserver(bottomViewExpandObserver)
    }
}