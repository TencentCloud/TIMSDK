package com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.group

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView

class GroupCallerUserInfoView(context: Context) : BaseCallView(context) {
    private var imageAvatar: ImageView? = null
    private var textUserName: TextView? = null
    private var user = findCaller()

    init {
        initView()
    }

    private fun findCaller(): User? {
        for (user in TUICallState.instance.remoteUserList.get()) {
            if (TUICallDefine.Role.Caller == user.callRole.get()) {
                return user
            }
        }
        return null
    }

    override fun clear() {}

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_user_info_group_caller, this)
        imageAvatar = findViewById(R.id.img_avatar)
        textUserName = findViewById(R.id.tv_name)

        ImageLoader.loadImage(context, imageAvatar, user?.avatar?.get(), R.drawable.tuicallkit_ic_avatar)
        textUserName!!.text = if (TextUtils.isEmpty(user?.nickname?.get())) {
            user?.id
        } else {
            user?.nickname?.get()
        }
    }
}