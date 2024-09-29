package com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.single

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView

class AudioCallUserInfoView(context: Context) : BaseCallView(context) {
    private var imageBackground: ImageView? = null
    private var imageAvatar: ImageView? = null
    private var textUserName: TextView? = null
    private var userModel = TUICallState.instance.remoteUserList.get().first()

    private var avatarObserver = Observer<String> {
        if (!TextUtils.isEmpty(it)) {
            ImageLoader.loadImage(context.applicationContext, imageAvatar, it, R.drawable.tuicallkit_ic_avatar)
        }
        setBackground()
    }

    private var nicknameObserver = Observer<String> {
        if (!TextUtils.isEmpty(it)) {
            textUserName?.text = it
        }
    }

    init {
        initView()
        addObserver()
    }

    override fun clear() {
        removeObserver()
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_user_info_audio, this)
        imageBackground = findViewById(R.id.img_user_background)
        imageAvatar = findViewById(R.id.img_avatar)
        textUserName = findViewById(R.id.tv_name)
        ImageLoader.loadImage(context, imageAvatar, userModel.avatar.get(), R.drawable.tuicallkit_ic_avatar)
        textUserName!!.text = userModel.nickname.get()

        setBackground()
    }

    private fun setBackground() {
        ImageLoader.loadBlurImage(context, imageBackground, userModel.avatar.get())
    }

    private fun addObserver() {
        userModel.avatar.observe(avatarObserver)
        userModel.nickname.observe(nicknameObserver)
    }

    private fun removeObserver() {
        userModel.avatar.removeObserver(avatarObserver)
        userModel.nickname.removeObserver(nicknameObserver)
    }
}