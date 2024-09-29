package com.tencent.qcloud.tuikit.tuicallkit.view.component.userinfo.single

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView

class VideoCallUserInfoView(context: Context) : BaseCallView(context) {
    private var imageAvatar: ImageView? = null
    private var textUserName: TextView? = null
    private var userModel = TUICallState.instance.remoteUserList.get().first()

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
        ImageLoader.loadImage(context, imageAvatar, userModel.avatar.get(), R.drawable.tuicallkit_ic_avatar)
        textUserName!!.text = userModel.nickname.get()

        if (TUICallState.instance.selfUser.get().callStatus.get() == TUICallDefine.Status.Accept
            || TUICallState.instance.mediaType.get() == TUICallDefine.MediaType.Audio
        ) {
            this.visibility = GONE
        } else {
            this.visibility = VISIBLE
        }
    }

    private fun addObserver() {
        TUICallState.instance.selfUser.get().callStatus.observe(callStatusObserver)
        TUICallState.instance.mediaType.observe(mediaTypeObserver)
        userModel.avatar.observe(avatarObserver)
        userModel.nickname.observe(nicknameObserver)
    }

    private fun removeObserver() {
        TUICallState.instance.selfUser.get().callStatus.removeObserver(callStatusObserver)
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
        userModel.avatar.removeObserver(avatarObserver)
        userModel.nickname.removeObserver(nicknameObserver)
    }
}