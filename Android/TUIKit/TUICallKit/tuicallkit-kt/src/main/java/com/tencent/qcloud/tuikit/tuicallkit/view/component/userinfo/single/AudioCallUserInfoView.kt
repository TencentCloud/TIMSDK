package com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.single

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.single.AudioCallUserInfoViewModel

class AudioCallUserInfoView(context: Context) : BaseCallView(context) {
    private var imageBackground: ImageView? = null
    private var imageAvatar: ImageView? = null
    private var textUserName: TextView? = null
    private var viewModel = AudioCallUserInfoViewModel()

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
        ImageLoader.loadImage(context, imageAvatar, viewModel.avatar.get(), R.drawable.tuicallkit_ic_avatar)
        textUserName!!.text = viewModel.nickname.get()

        setBackground()
    }

    private fun setBackground() {
        ImageLoader.loadBlurImage(context, imageBackground, viewModel.avatar.get())
    }

    private fun addObserver() {
        viewModel.avatar.observe(avatarObserver)
        viewModel.nickname.observe(nicknameObserver)
    }

    private fun removeObserver() {
        viewModel.avatar.removeObserver(avatarObserver)
        viewModel.nickname.removeObserver(nicknameObserver)
    }
}