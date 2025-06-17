package com.tencent.qcloud.tuikit.tuicallkit.view.component.inviteuser

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import android.view.ViewGroup
import android.widget.ImageView
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager

@SuppressLint("AppCompatCustomView")
class InviteUserButton(context: Context) : ImageView(context) {
    private val context: Context = context.applicationContext

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        initView()
    }

    private fun initView() {
        this.setBackgroundResource(R.drawable.tuicallkit_ic_add_user_black)
        this.setOnClickListener {
            inviteUser()
        }
        layoutParams = layoutParams.apply {
            width = ViewGroup.LayoutParams.MATCH_PARENT
            height = ViewGroup.LayoutParams.MATCH_PARENT
        }
        visibility = VISIBLE
    }

    private fun inviteUser() {
        // TODO: 3.0 上这里不止是groupId
        val groupId = CallManager.instance.callState.chatGroupId
        if (groupId.isNullOrEmpty()) {
            ToastUtil.toastShortMessage(context.getString(R.string.tuicallkit_group_id_is_empty))
            return
        }
        val list = ArrayList<String?>()
        for (model in CallManager.instance.userState.remoteUserList.get()) {
            if (!model.id.isNullOrEmpty() && !list.contains(model.id)) {
                list.add(model.id)
            }
        }
        if (!list.contains(TUILogin.getLoginUser())) {
            list.add(TUILogin.getLoginUser())
        }
        Logger.i(TAG, "InviteUserButton clicked, groupId: $groupId ,list: $list")
        val bundle = Bundle()
        bundle.putString("groupId", groupId)
        bundle.putStringArrayList("selectMemberList", list)
        TUICore.startActivity("SelectGroupMemberActivity", bundle)
    }

    companion object {
        private const val TAG = "InviteUserButton"
    }
}