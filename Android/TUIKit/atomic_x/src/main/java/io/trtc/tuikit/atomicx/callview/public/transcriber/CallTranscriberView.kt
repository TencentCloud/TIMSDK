package io.trtc.tuikit.atomicx.callview.public.transcriber

import android.content.Context
import android.view.LayoutInflater
import android.widget.FrameLayout
import androidx.constraintlayout.utils.widget.ImageFilterButton
import androidx.core.view.isVisible
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.ai.TranscriberView
import io.trtc.tuikit.atomicxcore.api.ai.SourceLanguage
import io.trtc.tuikit.atomicxcore.api.ai.TranslationLanguage
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantStatus
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.supervisorScope

class CallTranscriberView(context: Context): FrameLayout(context) {

    private var subscribeStateJob: Job? = null
    private var btnShowTranscriber: ImageFilterButton? = null
    private var transcriberView: TranscriberView? = null

    init {
        initView()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        subscribeStateJob = CoroutineScope(Dispatchers.Main).launch {
            supervisorScope {
                launch { observeSelfInfo() }
            }
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        subscribeStateJob?.cancel()
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.callview_ai_transcriber, this)
        btnShowTranscriber = findViewById(R.id.call_btn_ai_transcriber)
        transcriberView = findViewById(R.id.call_view_ai_transcriber)

        btnShowTranscriber?.setOnClickListener {
            val isVisible = transcriberView?.isVisible == false
            btnShowTranscriber?.setBackgroundResource(
                if (isVisible) R.drawable.callview_ic_ai_transcriber_on
                else R.drawable.callview_ic_ai_transcriber_off
            )
            transcriberView?.isVisible = isVisible
        }
    }

    private suspend fun observeSelfInfo() {
        CallStore.shared.observerState.selfInfo.collect { selfInfo ->
            val isAccept = selfInfo.status == CallParticipantStatus.Accept
            btnShowTranscriber?.isVisible = isAccept
            transcriberView?.isVisible = isAccept
            if (!isAccept) {
                TranscriberView.currentSourceLanguage = SourceLanguage.CHINESE_ENGLISH
                TranscriberView.currentTranslationLanguage = TranslationLanguage.ENGLISH
                TranscriberView.isBilingualEnabled = true
            }
        }
    }
}