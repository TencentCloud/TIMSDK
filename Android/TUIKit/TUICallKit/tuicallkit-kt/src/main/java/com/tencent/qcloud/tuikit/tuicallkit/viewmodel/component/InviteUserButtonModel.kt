package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component

import android.os.Bundle
import android.text.TextUtils
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.Constants
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class InviteUserButtonModel {
    public var role: LiveData<TUICallDefine.Role>? = null
    public var mediaType = LiveData<TUICallDefine.MediaType>()
    public var callStatus = LiveData<TUICallDefine.Status>()

    init {
        role = TUICallState.instance.selfUser.get().callRole
        mediaType = TUICallState.instance.mediaType
        callStatus = TUICallState.instance.selfUser.get().callStatus
    }

    fun inviteUser() {
        val groupId = TUICallState.instance.groupId.get()
        if (TextUtils.isEmpty(groupId)) {
            ToastUtil.toastShortMessage(
                ServiceInitializer.getAppContext().getString(R.string.tuicallkit_group_id_is_empty)
            )
            return
        }
        val status: TUICallDefine.Status = TUICallState.instance.selfUser.get().callStatus.get()
        if (TUICallDefine.Role.Called == role?.get() && TUICallDefine.Status.Accept != status) {
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
        private const val TAG = "InviteUserButtonModel"
    }
}