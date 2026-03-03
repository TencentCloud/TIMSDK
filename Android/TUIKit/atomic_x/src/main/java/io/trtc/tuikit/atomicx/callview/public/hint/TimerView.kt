package io.trtc.tuikit.atomicx.callview.public.hint

import android.content.Context
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantStatus
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class TimerView(context: Context) : AppCompatTextView(context) {
    private var subscribeStateJob: Job? = null

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        initView()
        registerActiveCallObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        subscribeStateJob?.cancel()
    }

    private fun registerActiveCallObserver() {
        subscribeStateJob = CoroutineScope(Dispatchers.Main).launch {
            CallStore.shared.observerState.activeCall.collect { activeCall ->
                updateDurationView(activeCall.duration)
            }
        }
    }

    private fun initView() {
        setTextColor(ContextCompat.getColor(context, R.color.callview_color_white))
        val duration = CallStore.shared.observerState.activeCall.value.duration
        updateDurationView(duration)
    }

    private fun updateDurationView(time: Long) {
        val self = CallStore.shared.observerState.selfInfo.value
        if (self.status == CallParticipantStatus.Accept) {
            text = DateTimeUtil.formatSecondsTo00(time.toInt())
            visibility = VISIBLE
        } else {
            visibility = GONE
        }
    }
}