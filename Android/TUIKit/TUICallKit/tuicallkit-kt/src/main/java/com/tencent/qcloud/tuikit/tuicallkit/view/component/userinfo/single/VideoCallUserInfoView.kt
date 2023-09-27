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
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.userinfo.single.VideoCallUserInfoViewModel

class VideoCallUserInfoView(context: Context) : BaseCallView(context) {
    private var imageAvatar: ImageView? = null
    private var textUserName: TextView? = null
    private var textInviteHint: TextView? = null
    private var mViewModel: VideoCallUserInfoViewModel = VideoCallUserInfoViewModel()

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.Accept) {
            this.visibility = GONE
        } else if (it == TUICallDefine.Status.Waiting) {
            this.visibility = VISIBLE
        }
    }

    private var mediaTypeObserver = Observer<TUICallDefine.MediaType> {
        if (it == TUICallDefine.MediaType.Audio) {
            this.visibility = GONE
        } else {
            this.visibility = VISIBLE
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
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_user_info_video, this)
        imageAvatar = findViewById(R.id.iv_user_avatar)
        textUserName = findViewById(R.id.tv_user_name)
        textInviteHint = findViewById(R.id.tv_video_tag)
        ImageLoader.loadImage(context, imageAvatar, mViewModel.avatar.get(), R.drawable.tuicallkit_ic_avatar)
        textUserName!!.text = mViewModel.nickname.get()
        textInviteHint!!.text = mViewModel.callTag
        val textColor = if (TUICallDefine.MediaType.Video == mViewModel.mediaType.get()) {
            context.resources.getColor(R.color.tuicalling_color_white)
        }else {
            context.resources.getColor(R.color.tuicalling_color_black)
        }
        textInviteHint?.setTextColor(textColor)
        textUserName?.setTextColor(textColor)
        if(mViewModel.callStatus.get() == TUICallDefine.Status.Accept
            || mViewModel.mediaType.get() == TUICallDefine.MediaType.Audio) {
            this.visibility = GONE
        } else {
            this.visibility = VISIBLE
        }
    }

    private fun addObserver() {
        mViewModel.callStatus.observe(callStatusObserver)
        mViewModel.mediaType.observe(mediaTypeObserver)
        mViewModel.avatar.observe(avatarObserver)
        mViewModel.nickname.observe(nicknameObserver)
    }

    private fun removeObserver() {
        mViewModel.callStatus.removeObserver(callStatusObserver)
        mViewModel.mediaType.removeObserver(mediaTypeObserver)
        mViewModel.avatar.removeObserver(avatarObserver)
        mViewModel.nickname.removeObserver(nicknameObserver)
    }
}