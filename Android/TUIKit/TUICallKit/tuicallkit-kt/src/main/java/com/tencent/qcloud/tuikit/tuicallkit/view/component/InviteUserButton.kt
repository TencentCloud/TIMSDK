package com.tencent.qcloud.tuikit.tuicallkit.view.component

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import android.text.TextUtils
import android.view.ViewGroup
import android.widget.ImageView
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

@SuppressLint("AppCompatCustomView")
class InviteUserButton(context: Context) : ImageView(context) {

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        visibility = if (it == TUICallDefine.Status.Accept) {
            VISIBLE
        } else {
            GONE
        }
    }

    init {
        initView()

        addObserver()
    }

    private fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
    }

    fun clear() {
        removeObserver()
    }

    private fun removeObserver() {
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
    }

    private fun initView() {
        setBackgroundResource(R.drawable.tuicallkit_ic_add_user_black)
        val lp = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        layoutParams = lp

        visibility =
            if (TUICallDefine.Role.Caller == TUICallState.instance.selfUser.get().callRole?.get()
                || TUICallDefine.Status.Accept == TUICallState.instance.selfUser.get().callStatus.get()
            ) {
                VISIBLE
            } else {
                GONE
            }

        setOnClickListener {
            inviteUser()
        }
    }

    private fun inviteUser() {
        val groupId = TUICallState.instance.groupId.get()
        if (TextUtils.isEmpty(groupId)) {
            ToastUtil.toastShortMessage(
                ServiceInitializer.getAppContext().getString(R.string.tuicallkit_group_id_is_empty)
            )
            return
        }
        val status: TUICallDefine.Status = TUICallState.instance.selfUser.get().callStatus.get()
        if (TUICallDefine.Role.Called == TUICallState.instance.selfUser.get().callRole?.get()
            && TUICallDefine.Status.Accept != status
        ) {
            TUILog.i(TAG, "This feature can only be used after the callee accepted the call.")
            return
        }
        val list = ArrayList<String?>()
        for (model in TUICallState.instance.remoteUserList.get()) {
            if (model != null && !TextUtils.isEmpty(model.id) && !list.contains(model.id)) {
                list.add(model.id)
            }
        }
        if (!list.contains(TUILogin.getLoginUser())) {
            list.add(TUILogin.getLoginUser())
        }
        TUILog.i(TAG, "initInviteUserFunction, groupId: $groupId ,list: $list")
        val bundle = Bundle()
        bundle.putString(Constants.GROUP_ID, groupId)
        bundle.putStringArrayList(Constants.SELECT_MEMBER_LIST, list)
        TUICore.startActivity("SelectGroupMemberActivity", bundle)
    }

    companion object {
        private const val TAG = "InviteUserButton"
    }
}