package com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.group

import android.content.Context
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.group.GroupCallerUserInfoViewModel

class GroupCallerUserInfoView(context: Context) : BaseCallView(context) {
    private var imageAvatar: ImageView? = null
    private var textUserName: TextView? = null
    private var viewModel = GroupCallerUserInfoViewModel()

    init {
        initView()
    }

    override fun clear() {}

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_user_info_group_caller, this)
        imageAvatar = findViewById(R.id.img_avatar)
        textUserName = findViewById(R.id.tv_name)

        ImageLoader.loadImage(context, imageAvatar, viewModel!!.avatar.get(), R.drawable.tuicallkit_ic_avatar)
        textUserName!!.text = viewModel.nickname.get()

        val textColor = if (TUICallDefine.MediaType.Video == viewModel.mediaType.get()) {
            context.resources.getColor(R.color.tuicalling_color_white)
        }else {
            context.resources.getColor(R.color.tuicalling_color_black)
        }
        textUserName?.setTextColor(textColor)
    }
}