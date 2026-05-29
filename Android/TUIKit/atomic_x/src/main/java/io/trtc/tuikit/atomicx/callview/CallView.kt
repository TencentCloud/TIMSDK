package io.trtc.tuikit.atomicx.callview

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.callview.core.CallViewFunction
import io.trtc.tuikit.atomicx.callview.core.common.utils.CallUtils
import io.trtc.tuikit.atomicx.callview.core.common.utils.ImageResourceCache
import io.trtc.tuikit.atomicx.callview.core.common.utils.Logger
import io.trtc.tuikit.atomicx.callview.public.controls.MultiCallControlsView
import io.trtc.tuikit.atomicx.callview.public.controls.SingleCallControlsView
import io.trtc.tuikit.atomicx.callview.public.hint.HintView
import io.trtc.tuikit.atomicx.callview.public.hint.TimerView
import io.trtc.tuikit.atomicx.callview.public.multi.MultiCallWaitingView
import io.trtc.tuikit.atomicx.callview.public.transcriber.CallTranscriberView
import io.trtc.tuikit.atomicx.common.util.ScreenUtil.dip2px
import io.trtc.tuikit.atomicx.callview.public.smartcellularswitchrecommendation.SmartCellularRecommendationDialog
import io.trtc.tuikit.atomicx.widget.basicwidget.toast.AtomicToast
import io.trtc.tuikit.atomicxcore.api.call.CallListener
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantInfo
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantStatus
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.device.DeviceStore
import io.trtc.tuikit.atomicxcore.api.device.NetworkQuality
import io.trtc.tuikit.atomicxcore.api.device.NetworkType
import io.trtc.tuikit.atomicxcore.api.view.CallCoreView
import io.trtc.tuikit.atomicxcore.api.view.CallLayoutTemplate
import io.trtc.tuikit.atomicxcore.api.view.VolumeLevel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.supervisorScope
import org.json.JSONObject
import java.io.File
import java.util.concurrent.atomic.AtomicInteger

enum class Feature(val value: String) {
    AI_TRANSCRIBER("aiTranscriber"),
}

class CallView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : ConstraintLayout(context, attrs, defStyleAttr), CallViewFunction {
    private data class ParticipantAvatarInfo(
        var originalUrl: String,
        var cachedPath: String?
    )
    private var callMainView: CallCoreView? = null
    private var transcriberContainer: FrameLayout? = null
    private var subscribeStateJob: Job? = null
    private val participantAvatarInfoMap: MutableMap<String, ParticipantAvatarInfo> = mutableMapOf()
    private val imageResourceCache = ImageResourceCache(context)

    private var layoutFunction: FrameLayout? = null
    private var layoutTimer: FrameLayout? = null
    private var layoutCallHint: FrameLayout? = null
    private var multiCallWaitingViewContainer: LinearLayout? = null
    private var disableFeatures: List<Feature>? = null

    private var callListener: CallListener = object : CallListener() {
        override fun onSuggestSwitchToCellular() {
            super.onSuggestSwitchToCellular()
            this@CallView.onSuggestSwitchToCellular()
        }
    }

    init {
        initView()
        setIconResourcePath()
    }

    fun disableFeatures(features: List<Feature>?) {
        disableFeatures = features
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        addFunctionLayout()
        addTranscriberLayout()
        updateWaitingView()
        CallStore.shared.addListener(callListener)
        subscribeStateJob = CoroutineScope(Dispatchers.Main).launch {
            supervisorScope {
                launch { observeSelfInfo() }
                launch { observeParticipantInfo() }
                launch { observeNetworkType() }
            }
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        callMainView?.removeAllViews()
        callListener.let { CallStore.shared.removeListener(it) }
        subscribeStateJob?.cancel()
    }

    private suspend fun observeSelfInfo() {
        CallStore.shared.observerState.selfInfo.collect { selfInfo ->
            val isAccepted = selfInfo.status == CallParticipantStatus.Accept
            if (isAccepted && callMainView?.visibility == GONE) {
                updateWaitingView()
            }
        }
    }

    private suspend fun observeParticipantInfo() {
        CallStore.shared.observerState.allParticipants.collect { allParticipants ->
            updateParticipantsAvatars(allParticipants)
        }
    }

    private suspend fun observeNetworkType() {
        DeviceStore.shared().deviceState.networkType.collect { networkType ->
            handleNetworkTypeChanged(networkType)
        }
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.callview_root_view, this, true)
        multiCallWaitingViewContainer = findViewById(R.id.ll_callee_waiting_view)
        layoutFunction = findViewById(R.id.rl_layout_function)
        layoutTimer = findViewById(R.id.rl_layout_call_time)
        layoutCallHint = findViewById(R.id.rl_layout_call_hint)
        callMainView = CallCoreView(context)
        val layoutParams = ConstraintLayout.LayoutParams(ConstraintLayout.LayoutParams.MATCH_PARENT, ConstraintLayout.LayoutParams.MATCH_PARENT)
        this.addView(callMainView, 0, layoutParams)
    }

    private fun updateWaitingView() {
        val selfUser = CallStore.shared.observerState.selfInfo.value
        if (CallParticipantStatus.Waiting == selfUser.status && !CallUtils.isCaller(selfUser.id) && isMultiCall()) {
            multiCallWaitingViewContainer?.addView(MultiCallWaitingView(context))
            multiCallWaitingViewContainer?.visibility = VISIBLE
            callMainView?.visibility = GONE
            layoutCallHint?.visibility = GONE
            layoutTimer?.visibility = GONE
        } else {
            multiCallWaitingViewContainer?.visibility = GONE
            callMainView?.visibility = VISIBLE
            layoutCallHint?.visibility = VISIBLE
            layoutTimer?.visibility = VISIBLE
        }
    }

    private fun setIconResourcePath() {
        val volumeLevelIcons = mapOf(
            VolumeLevel.Mute to imageResourceCache.getDrawablePath(R.drawable.callview_ic_self_mute),
            VolumeLevel.Low to imageResourceCache.getDrawablePath(R.drawable.callview_ic_audio_input),
            VolumeLevel.Medium to imageResourceCache.getDrawablePath(R.drawable.callview_ic_audio_input),
            VolumeLevel.High to imageResourceCache.getDrawablePath(R.drawable.callview_ic_audio_input),
            VolumeLevel.Peak to imageResourceCache.getDrawablePath(R.drawable.callview_ic_audio_input),
        )
        callMainView?.setVolumeLevelIcons(volumeLevelIcons)

        val networkQualityIcons = mapOf(
            NetworkQuality.BAD to imageResourceCache.getDrawablePath(R.drawable.callview_ic_network_bad),
            NetworkQuality.VERY_BAD to imageResourceCache.getDrawablePath(R.drawable.callview_ic_network_bad)
        )
        callMainView?.setNetworkQualityIcons(networkQualityIcons)
        callMainView?.setWaitingAnimation(imageResourceCache.getDrawablePath(R.drawable.callview_ic_loading))
    }

    private fun addTranscriberLayout() {
        if (disableFeatures?.contains(Feature.AI_TRANSCRIBER) == true) {
            return
        }
        transcriberContainer = findViewById<FrameLayout>(R.id.call_layout_transcriber_container)
        transcriberContainer?.addView(CallTranscriberView(context))
    }

    private fun addFunctionLayout() {
        if (isMultiCall()) {
            addMultiFunctionLayout()
        } else {
            addSingleFunctionLayout()
        }
    }

    private fun addMultiFunctionLayout() {
        layoutFunction?.addView(MultiCallControlsView(context))
        layoutTimer?.addView(TimerView(context))
        layoutCallHint?.addView(HintView(context))
    }

    private fun addSingleFunctionLayout() {
        layoutFunction?.addView(SingleCallControlsView(context))
        layoutTimer?.addView(TimerView(context))
        layoutCallHint?.addView(HintView(context))
    }

    private fun updateParticipantsAvatars(participants: Collection<CallParticipantInfo>) {
        val participantsToUpdate = mutableListOf<Pair<String, String>>()
        val currentParticipantIds = participants.map { it.id }.toSet()
        val removedIds = participantAvatarInfoMap.keys.filter { it !in currentParticipantIds }
        val hasRemovedParticipants = removedIds.isNotEmpty()
        removedIds.forEach { id ->
            participantAvatarInfoMap.remove(id)
        }
        for (participant in participants) {
            val participantId = participant.id
            val currentAvatarUrl = participant.avatarURL ?: ""
            val existingInfo = participantAvatarInfoMap[participantId]
            if (existingInfo?.originalUrl != currentAvatarUrl) {
                participantsToUpdate.add(participantId to currentAvatarUrl)
                participantAvatarInfoMap[participantId] = ParticipantAvatarInfo(
                    originalUrl = currentAvatarUrl,
                    cachedPath = existingInfo?.cachedPath
                )
            }
        }
        
        if (participantsToUpdate.isEmpty()) {
            if (hasRemovedParticipants) {
                val avatarMap = buildAvatarPathMap()
                callMainView?.setParticipantAvatars(avatarMap)
            }
            return
        }
        
        val completedCount = AtomicInteger(0)
        val totalCount = participantsToUpdate.size
        
        for ((participantId, avatarUrl) in participantsToUpdate) {
            imageResourceCache.cacheNetworkImage(avatarUrl) { cachedPath ->
                synchronized(participantAvatarInfoMap) {
                    val info = participantAvatarInfoMap[participantId]
                    if (info != null) {
                        if (cachedPath != null) {
                            info.cachedPath = File(cachedPath).absolutePath
                        } else {
                            val defaultAvatarPath = imageResourceCache.getDefaultAvatarPath(R.drawable.callview_ic_avatar)
                            info.cachedPath = defaultAvatarPath
                            if (defaultAvatarPath == null) {
                                participantAvatarInfoMap.remove(participantId)
                            }
                        }
                    }
                    if (completedCount.incrementAndGet() == totalCount) {
                        val avatarMap = buildAvatarPathMap()
                        callMainView?.setParticipantAvatars(avatarMap)
                    }
                }
            }
        }
    }

    private fun buildAvatarPathMap(): Map<String, String> {
        return participantAvatarInfoMap
            .filter { it.value.cachedPath != null }
            .mapValues { it.value.cachedPath!! }
    }

    private fun onSuggestSwitchToCellular() {
        this.post {
            try {
                val dialog = SmartCellularRecommendationDialog(context)
                dialog.onEnableSmartCellular = {
                    enableCellularFallback()
                }
                dialog.show()
            } catch (e: Exception) {
                Logger.e("showSmartCellularRecommendation failed: ${e.message}")
            }
        }
    }

    private fun handleNetworkTypeChanged(type: NetworkType) {
        val toastString = when (type) {
            NetworkType.CELLULAR -> context.getString(R.string.smart_cellular_switched_to_cellular)
            NetworkType.WIFI -> context.getString(R.string.smart_cellular_switched_to_wifi)
            else -> return
        }
        AtomicToast.show(context, toastString)
    }


    override fun setLayoutTemplate(template: CallLayoutTemplate) {
        val isPipView = template == CallLayoutTemplate.Pip
        layoutFunction?.visibility = if (isPipView) GONE else VISIBLE
        layoutCallHint?.visibility = if (isPipView) GONE else VISIBLE
        layoutTimer?.visibility = if (isPipView) GONE else VISIBLE
        multiCallWaitingViewContainer?.visibility = if (isPipView) GONE else VISIBLE
        callMainView?.visibility = VISIBLE
        updateCallCoreViewTopMargin(template)
        callMainView?.setLayoutTemplate(template)
        transcriberContainer?.isVisible = !isPipView
    }

    private fun updateCallCoreViewTopMargin(template: CallLayoutTemplate) {
        val marginTop = if (template == CallLayoutTemplate.Grid) {
            getStatusBarHeight() + dip2px(GRID_VIDEO_CONTAINER_MARGIN_TOP_DP)
        } else {
            0
        }
        val layoutParams = callMainView?.layoutParams as? ConstraintLayout.LayoutParams
        layoutParams?.let {
            it.topMargin = marginTop
            callMainView?.layoutParams = it
        }
    }

    private fun getStatusBarHeight(): Int {
        var statusBarHeight = 0
        val resourceId = this.resources.getIdentifier(STATUS_BAR_HEIGHT, DIMEN, ANDROID)
        if (resourceId > 0) {
            statusBarHeight = this.resources.getDimensionPixelSize(resourceId)
        }
        return statusBarHeight
    }

    private fun isMultiCall(): Boolean {
        val inviteeIdListSize = CallStore.shared.observerState.activeCall.value.inviteeIds.size
        val chatGroupId = CallStore.shared.observerState.activeCall.value.chatGroupId
        return chatGroupId.isNotEmpty() || inviteeIdListSize > 1
    }

    private fun enableCellularFallback() {
        val json = JSONObject()
        json.put("api", "enableCellularFallback")
        json.put("params", JSONObject().put("enable", true))
        CallStore.shared.callExperimentalAPI(json.toString())
    }

    companion object {
        private const val GRID_VIDEO_CONTAINER_MARGIN_TOP_DP = 45f
        private const val STATUS_BAR_HEIGHT = "status_bar_height"
        private const val DIMEN = "dimen"
        private const val ANDROID = "android"
    }
}