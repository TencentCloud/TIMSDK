package com.tencent.qcloud.tuikit.tuicallkit.view.component

import android.content.Context
import android.view.LayoutInflater
import android.widget.LinearLayout
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.view.root.BaseCallView
import com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.SwitchAudioViewModel

class SwitchAudioView(context: Context) : BaseCallView(context) {
    private var viewmodel = SwitchAudioViewModel()

    init {
        initView()
    }

    override fun clear() {}

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_switch_audio_view, this)
        var layoutSwitchToAudio = findViewById<LinearLayout>(R.id.ll_switch_audio)
        layoutSwitchToAudio.setOnClickListener {
            viewmodel.switchCallMediaType(TUICallDefine.MediaType.Audio)
        }
    }

}