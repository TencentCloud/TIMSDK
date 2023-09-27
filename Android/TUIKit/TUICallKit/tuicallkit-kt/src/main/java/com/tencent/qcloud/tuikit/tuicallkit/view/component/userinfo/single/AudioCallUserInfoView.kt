package com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.single

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.single.AudioCallUserInfoViewModel

class AudioCallUserInfoView(context: Context) : BaseCallView(context) {
    private var imageAvatar: ImageView? = null
    private var textUserName: TextView? = null
    private var textWaitHint: TextView? = null
    private var viewModel = AudioCallUserInfoViewModel()

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.Waiting) {
            textWaitHint?.visibility = VISIBLE
        } else if (it == TUICallDefine.Status.Accept) {
            textWaitHint?.visibility = GONE
        }
    }

    private var avatarObserver = Observer<String> {
        if (!TextUtils.isEmpty(it)) {
            ImageLoader.loadImage(context.applicationContext, imageAvatar, it, R.drawable.tuicallkit_ic_avatar)
        }
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

        if (viewModel != null) {
            viewModel.removeObserver()
        }
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_user_info_audio, this)
        imageAvatar = findViewById(R.id.img_avatar)
        textUserName = findViewById(R.id.tv_name)
        textWaitHint = findViewById(R.id.tv_tag)
        ImageLoader.loadImage(context, imageAvatar, viewModel!!.avatar.get(), R.drawable.tuicallkit_ic_avatar)
        textUserName!!.text = viewModel.nickname.get()
        textWaitHint!!.text = viewModel.callTag.get()
        val textColor = if (TUICallDefine.MediaType.Video == viewModel.mediaType.get()) {
            context.resources.getColor(R.color.tuicalling_color_white)
        } else {
            context.resources.getColor(R.color.tuicalling_color_black)
        }
        textWaitHint?.setTextColor(textColor)
        textUserName?.setTextColor(textColor)

        if (viewModel.callStatus.get() == TUICallDefine.Status.Accept) {
            textWaitHint?.visibility = GONE
        } else {
            textWaitHint?.visibility = VISIBLE
        }
    }

    private fun addObserver() {
        viewModel.callStatus.observe(callStatusObserver)
        viewModel.avatar.observe(avatarObserver)
        viewModel.nickname.observe(nicknameObserver)
    }

    private fun removeObserver() {
        viewModel.callStatus.removeObserver(callStatusObserver)
        viewModel.avatar.removeObserver(avatarObserver)
        viewModel.nickname.removeObserver(nicknameObserver)
    }

}