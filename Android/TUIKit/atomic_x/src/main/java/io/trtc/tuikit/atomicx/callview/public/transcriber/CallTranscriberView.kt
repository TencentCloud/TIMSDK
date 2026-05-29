package io.trtc.tuikit.atomicx.callview.public.transcriber

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import androidx.constraintlayout.utils.widget.ImageFilterButton
import androidx.core.view.isVisible
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.FragmentActivity
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.AITranscriber.TranscriberSettingsDialogFragment
import io.trtc.tuikit.atomicx.AITranscriber.TranscriberView
import io.trtc.tuikit.atomicx.callview.CallViewStore
import io.trtc.tuikit.atomicxcore.api.ai.AITranscriberStore
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
    private var emptyHintView: TextView? = null

    init {
        initView()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        subscribeStateJob = CoroutineScope(Dispatchers.Main).launch {
            supervisorScope {
                launch { observeTranscriberPanelState() }
                launch { observeSelfInfo() }
                launch { observeRealtimeMessages() }
            }
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        subscribeStateJob?.cancel()
    }

    override fun onVisibilityChanged(changedView: View, visibility: Int) {
        super.onVisibilityChanged(changedView, visibility)
        if (visibility != VISIBLE) {
            val activity = context as? FragmentActivity ?: return
            activity.supportFragmentManager
                .findFragmentByTag(TranscriberSettingsDialogFragment.TAG)
                ?.let { (it as? DialogFragment)?.dismissAllowingStateLoss() }
        }
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.callview_ai_transcriber, this)
        btnShowTranscriber = findViewById(R.id.call_btn_ai_transcriber)
        transcriberView = findViewById(R.id.call_view_ai_transcriber)
        emptyHintView = findViewById(R.id.call_tv_ai_transcriber_empty_hint)

        btnShowTranscriber?.setOnClickListener {
            val current = CallViewStore.isShowTranscriberPanel.value
            CallViewStore.setShowTranscriberPanel(!current)
        }
        updateTranscriberPanel()
    }

    private suspend fun observeSelfInfo() {
        CallStore.shared.observerState.selfInfo.collect { selfInfo ->
            val accept = selfInfo.status == CallParticipantStatus.Accept
            isVisible = accept
            if (!accept) {
                TranscriberView.currentSourceLanguage = SourceLanguage.CHINESE_ENGLISH
                TranscriberView.currentTranslationLanguage = TranslationLanguage.ENGLISH
                TranscriberView.isBilingualEnabled = true
            }
        }
    }

    private suspend fun observeTranscriberPanelState() {
        CallViewStore.isShowTranscriberPanel.collect { show ->
            updateTranscriberPanel()
        }
    }

    private fun updateTranscriberPanel() {
        val isShow = CallViewStore.isShowTranscriberPanel.value
        val isEmpty = AITranscriberStore.shared.transcriberState.realtimeMessageList.value.isEmpty()
        transcriberView?.isVisible = isShow
        emptyHintView?.isVisible = isShow && isEmpty
        btnShowTranscriber?.setBackgroundResource(
            if (isShow) R.drawable.callview_ic_ai_transcriber_on
            else R.drawable.callview_ic_ai_transcriber_off
        )
    }

    private suspend fun observeRealtimeMessages() {
        AITranscriberStore.shared.transcriberState.realtimeMessageList.collect { messages ->
            val isEmpty = messages.isEmpty()
            val isShow = CallViewStore.isShowTranscriberPanel.value
            emptyHintView?.isVisible = isShow && isEmpty
        }
    }
}