package com.tencent.qcloud.tuikit.tuichat.component.voiceinput

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Shader
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.animation.DecelerateInterpolator
import android.view.animation.LinearInterpolator
import android.widget.FrameLayout
import android.widget.PopupWindow
import android.widget.TextView
import androidx.core.graphics.ColorUtils
import androidx.core.view.ViewCompat
import com.tencent.qcloud.tuikit.tuichat.R
import kotlin.math.abs
import kotlin.math.sin

internal class VoiceInputRecordOverlay(
    private val anchorView: View,
) {
    private val context = anchorView.context
    private val density = context.resources.displayMetrics.density
    private val rootView = FrameLayout(context)
    private val backgroundView = VoiceInputOverlayGradientBackgroundView(context)
    private val bubbleHeight = (40 * density).toInt()
    private val bubbleDefaultHorizontalMargin = (8 * density).toInt()
    private val bubbleDefaultBottomMargin = (43 * density).toInt()
    private val actionDefaultBottomMargin = (107 * density).toInt()
    private val statusDefaultBottomMargin = (199 * density).toInt()
    private val actionSize = (80 * density).toInt()
    private val animationSpec = VoiceInputRecordOverlayAnimationPolicy.createSpec()
    private val animationInterpolator = DecelerateInterpolator()
    private var isDismissed = false
    private var cancelButtonLayoutParams: FrameLayout.LayoutParams? = null
    private var transcribeButtonLayoutParams: FrameLayout.LayoutParams? = null
    private var statusLayoutParams: FrameLayout.LayoutParams? = null

    private val bubbleView = VoiceInputBubbleView(context).apply {
        setBubbleColor(VoiceInputColors.BUTTON_PRIMARY_DEFAULT)
        setContentColor(VoiceInputColors.TEXT_BUTTON)
    }
    private val statusTextView = TextView(context).apply {
        gravity = Gravity.CENTER
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
        setTextColor(VoiceInputColors.TEXT_SECONDARY)
    }
    private val cancelButtonView = TextView(context).apply {
        gravity = Gravity.CENTER
        setText(R.string.voice_input_cancel)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(VoiceInputColors.BUTTON_SECONDARY_DEFAULT)
        }
        setTextColor(VoiceInputColors.TEXT_PRIMARY)
    }
    private val transcribeButtonView = TextView(context).apply {
        gravity = Gravity.CENTER
        setText(R.string.voice_input_transcribe_to_text)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(VoiceInputColors.BUTTON_SECONDARY_DEFAULT)
        }
        setTextColor(VoiceInputColors.TEXT_PRIMARY)
    }
    private val popupWindow = PopupWindow(
        rootView,
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.MATCH_PARENT,
        false,
    ).apply {
        isClippingEnabled = false
        isTouchable = false
        isFocusable = false
        isOutsideTouchable = false
    }

    init {
        buildLayout()
        applyOverlayBackground(VoiceInputColors.BG_OPERATE)
    }

    fun show() {
        if (popupWindow.isShowing || !anchorView.isAttachedToWindow) {
            return
        }
        isDismissed = false
        rootView.animate().cancel()
        rootView.alpha = animationSpec.enterStartAlpha
        updateBubbleLayoutForAnchorBeforeShow()
        rootView.visibility = View.VISIBLE
        popupWindow.showAtLocation(anchorView, Gravity.NO_GRAVITY, 0, 0)
        rootView.animate()
            .alpha(animationSpec.enterEndAlpha)
            .setDuration(animationSpec.enterDurationMs)
            .setInterpolator(animationInterpolator)
            .setListener(null)
            .start()
        rootView.post {
            if (popupWindow.isShowing && !isDismissed) {
                updateBubbleLayoutForAnchorAfterShow()
            }
        }
    }

    fun dismiss() {
        if (!popupWindow.isShowing) {
            return
        }
        isDismissed = true
        rootView.animate().cancel()
        rootView.alpha = animationSpec.exitStartAlpha.coerceAtMost(rootView.alpha.coerceAtLeast(0f))
        rootView.animate()
            .alpha(animationSpec.exitEndAlpha)
            .setDuration(animationSpec.exitDurationMs)
            .setInterpolator(animationInterpolator)
            .withEndAction {
                if (popupWindow.isShowing) {
                    popupWindow.dismiss()
                }
            }
            .start()
    }

    fun releaseActionFor(rawX: Float, rawY: Float): VoiceInputReleaseAction {
        if (!popupWindow.isShowing) {
            return VoiceInputReleaseAction.SEND_AUDIO
        }
        val rootLocation = IntArray(2)
        rootView.getLocationOnScreen(rootLocation)
        val localX = rawX - rootLocation[0]
        val localY = rawY - rootLocation[1]
        return VoiceInputGesturePolicy.decideReleaseAction(
            localX,
            localY,
            cancelButtonView.toGestureTarget(),
            transcribeButtonView.toGestureTarget(),
        )
    }

    fun update(state: VoiceInputController.RecordUiState, durationMs: Int, powerLevel: Int, maxDurationMs: Int) {
        val releaseAction = when (state) {
            VoiceInputController.RecordUiState.READY_TO_CANCEL -> VoiceInputReleaseAction.CANCEL
            VoiceInputController.RecordUiState.READY_TO_TRANSCRIBE -> VoiceInputReleaseAction.TRANSCRIBE
            else -> VoiceInputReleaseAction.SEND_AUDIO
        }
        statusTextView.text = statusTextFor(releaseAction, durationMs, maxDurationMs)
        applyOverlayBackground(VoiceInputColors.BG_OPERATE)
        statusTextView.setTextColor(VoiceInputColors.TEXT_SECONDARY)

        val cancelActive = releaseAction == VoiceInputReleaseAction.CANCEL
        val transcribeActive = releaseAction == VoiceInputReleaseAction.TRANSCRIBE
        setCircleBackground(
            cancelButtonView,
            if (cancelActive) VoiceInputColors.BUTTON_HANGUP_DEFAULT else VoiceInputColors.BUTTON_SECONDARY_DEFAULT,
        )
        cancelButtonView.setTextColor(if (cancelActive) VoiceInputColors.TEXT_BUTTON else VoiceInputColors.TEXT_PRIMARY)
        setCircleBackground(
            transcribeButtonView,
            if (transcribeActive) VoiceInputColors.BUTTON_PRIMARY_DEFAULT else VoiceInputColors.BUTTON_SECONDARY_DEFAULT,
        )
        transcribeButtonView.setTextColor(if (transcribeActive) VoiceInputColors.TEXT_BUTTON else VoiceInputColors.TEXT_PRIMARY)

        val bubbleColor = when (releaseAction) {
            VoiceInputReleaseAction.CANCEL -> VoiceInputColors.BUTTON_HANGUP_DEFAULT
            else -> VoiceInputColors.BUTTON_PRIMARY_DEFAULT
        }
        bubbleView.setBubbleColor(bubbleColor)
        bubbleView.setContentColor(VoiceInputColors.TEXT_BUTTON)
        bubbleView.setPowerLevel(powerLevel)
        bubbleView.setDuration(durationMs)
    }

    private fun statusTextFor(releaseAction: VoiceInputReleaseAction, durationMs: Int, maxDurationMs: Int): String {
        val countdown = VoiceInputGesturePolicy.remainingSecondsBeforeAutoStop(durationMs, maxDurationMs)
        return when {
            releaseAction == VoiceInputReleaseAction.CANCEL -> context.getString(R.string.voice_input_release_cancel_hint)
            releaseAction == VoiceInputReleaseAction.TRANSCRIBE -> context.getString(R.string.voice_input_release_transcribe_hint)
            countdown != null -> context.getString(R.string.voice_input_auto_stop_countdown, countdown)
            else -> context.getString(R.string.voice_input_release_send_hint)
        }
    }

    private fun buildLayout() {
        rootView.layoutDirection = ViewCompat.getLayoutDirection(anchorView)
        rootView.addView(
            backgroundView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )

        val cancelLp = FrameLayout.LayoutParams(actionSize, actionSize, Gravity.BOTTOM or Gravity.START)
        cancelLp.marginStart = dp(72)
        cancelLp.bottomMargin = actionDefaultBottomMargin
        cancelButtonLayoutParams = cancelLp
        rootView.addView(cancelButtonView, cancelLp)

        val transcribeLp = FrameLayout.LayoutParams(actionSize, actionSize, Gravity.BOTTOM or Gravity.END)
        transcribeLp.marginEnd = dp(72)
        transcribeLp.bottomMargin = actionDefaultBottomMargin
        transcribeButtonLayoutParams = transcribeLp
        rootView.addView(transcribeButtonView, transcribeLp)

        val statusLp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT,
            Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL,
        )
        statusLp.bottomMargin = statusDefaultBottomMargin
        statusLayoutParams = statusLp
        rootView.addView(statusTextView, statusLp)

        val bubbleLp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            bubbleHeight,
            Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL,
        )
        bubbleLp.marginStart = bubbleDefaultHorizontalMargin
        bubbleLp.marginEnd = bubbleDefaultHorizontalMargin
        bubbleLp.bottomMargin = bubbleDefaultBottomMargin
        rootView.addView(bubbleView, bubbleLp)
        bubbleView.layoutDirection = rootView.layoutDirection
    }

    private fun updateBubbleLayoutForAnchorBeforeShow() {
        val root = anchorView.rootView
        val rootLocation = IntArray(2)
        val anchorLocation = IntArray(2)
        root.getLocationOnScreen(rootLocation)
        anchorView.getLocationOnScreen(anchorLocation)
        updateBubbleLayout(
            rootWidth = root.width,
            rootHeight = root.height,
            anchorLeft = anchorLocation[0] - rootLocation[0],
            anchorTop = anchorLocation[1] - rootLocation[1],
        )
    }

    private fun updateBubbleLayoutForAnchorAfterShow() {
        val rootLocation = IntArray(2)
        val anchorLocation = IntArray(2)
        rootView.getLocationOnScreen(rootLocation)
        anchorView.getLocationOnScreen(anchorLocation)
        updateBubbleLayout(
            rootWidth = rootView.width,
            rootHeight = rootView.height,
            anchorLeft = anchorLocation[0] - rootLocation[0],
            anchorTop = anchorLocation[1] - rootLocation[1],
        )
    }

    private fun updateBubbleLayout(rootWidth: Int, rootHeight: Int, anchorLeft: Int, anchorTop: Int) {
        val layout = VoiceInputRecordOverlayBubbleLayoutPolicy.calculate(
            rootWidth = rootWidth,
            rootHeight = rootHeight,
            anchorLeft = anchorLeft,
            anchorTop = anchorTop,
            anchorWidth = anchorView.width,
            anchorHeight = anchorView.height,
            defaultHorizontalMargin = bubbleDefaultHorizontalMargin,
            defaultBottomMargin = bubbleDefaultBottomMargin,
            bubbleHeight = bubbleHeight,
            defaultActionBottomMargin = actionDefaultBottomMargin,
            defaultStatusBottomMargin = statusDefaultBottomMargin,
            actionSize = actionSize,
            minActionBubbleGap = dp(24),
            minStatusActionGap = dp(12),
        )
        val layoutParams = bubbleView.layoutParams as FrameLayout.LayoutParams
        layoutParams.marginStart = layout.leftMargin
        layoutParams.marginEnd = layout.rightMargin
        layoutParams.bottomMargin = layout.bottomMargin
        layoutParams.height = layout.height
        bubbleView.layoutParams = layoutParams
        updateBottomMargin(cancelButtonView, cancelButtonLayoutParams, layout.actionBottomMargin)
        updateBottomMargin(transcribeButtonView, transcribeButtonLayoutParams, layout.actionBottomMargin)
        updateBottomMargin(statusTextView, statusLayoutParams, layout.statusBottomMargin)
    }

    private fun updateBottomMargin(view: View, layoutParams: FrameLayout.LayoutParams?, bottomMargin: Int) {
        if (layoutParams == null || layoutParams.bottomMargin == bottomMargin) {
            return
        }
        layoutParams.bottomMargin = bottomMargin
        view.layoutParams = layoutParams
    }

    private fun View.toGestureTarget(): VoiceInputGestureTarget {
        return VoiceInputGestureTarget(left.toFloat(), top.toFloat(), width.toFloat(), height.toFloat())
    }

    private fun setCircleBackground(view: View, color: Int) {
        view.background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(color)
        }
    }

    private fun applyOverlayBackground(backgroundColor: Int) {
        backgroundView.setGradientSpec(VoiceInputOverlayBackgroundPolicy.createGradientSpec(backgroundColor))
    }

    private fun dp(value: Int): Int = (value * density).toInt()
}

internal data class VoiceInputRecordOverlayBubbleLayout(
    val leftMargin: Int,
    val rightMargin: Int,
    val bottomMargin: Int,
    val height: Int,
    val actionBottomMargin: Int,
    val statusBottomMargin: Int,
)

internal data class VoiceInputRecordOverlayAnimationSpec(
    val enterStartAlpha: Float,
    val enterEndAlpha: Float,
    val exitStartAlpha: Float,
    val exitEndAlpha: Float,
    val enterDurationMs: Long,
    val exitDurationMs: Long,
)

internal object VoiceInputRecordOverlayAnimationPolicy {
    fun createSpec(): VoiceInputRecordOverlayAnimationSpec {
        return VoiceInputRecordOverlayAnimationSpec(
            enterStartAlpha = 0.92f,
            enterEndAlpha = 1f,
            exitStartAlpha = 1f,
            exitEndAlpha = 0f,
            enterDurationMs = 120L,
            exitDurationMs = 100L,
        )
    }
}

internal object VoiceInputRecordOverlayBubbleLayoutPolicy {
    @Suppress("UNUSED_PARAMETER")
    fun calculate(
        rootWidth: Int,
        rootHeight: Int,
        anchorLeft: Int,
        anchorTop: Int,
        anchorWidth: Int,
        anchorHeight: Int,
        defaultHorizontalMargin: Int,
        defaultBottomMargin: Int,
        bubbleHeight: Int,
        defaultActionBottomMargin: Int,
        defaultStatusBottomMargin: Int,
        actionSize: Int,
        minActionBubbleGap: Int,
        minStatusActionGap: Int,
    ): VoiceInputRecordOverlayBubbleLayout {
        if (rootWidth <= 0 || rootHeight <= 0 || anchorWidth <= 0 || anchorHeight <= 0) {
            return VoiceInputRecordOverlayBubbleLayout(
                leftMargin = defaultHorizontalMargin,
                rightMargin = defaultHorizontalMargin,
                bottomMargin = defaultBottomMargin,
                height = bubbleHeight,
                actionBottomMargin = defaultActionBottomMargin,
                statusBottomMargin = defaultStatusBottomMargin,
            )
        }
        val anchorBottom = anchorTop + anchorHeight
        val resolvedBubbleHeight = anchorHeight.coerceAtMost(bubbleHeight)
        val bubbleBottomMargin = (rootHeight - anchorBottom).coerceAtLeast(0)
        val minActionBottomMargin = bubbleBottomMargin + resolvedBubbleHeight + minActionBubbleGap
        val actionBottomMargin = maxOf(defaultActionBottomMargin, minActionBottomMargin)
            .coerceAtMost((rootHeight - actionSize).coerceAtLeast(0))
        val statusBottomMargin = maxOf(defaultStatusBottomMargin, actionBottomMargin + actionSize + minStatusActionGap)
            .coerceAtMost(rootHeight)
        return VoiceInputRecordOverlayBubbleLayout(
            leftMargin = defaultHorizontalMargin,
            rightMargin = defaultHorizontalMargin,
            bottomMargin = bubbleBottomMargin,
            height = resolvedBubbleHeight,
            actionBottomMargin = actionBottomMargin,
            statusBottomMargin = statusBottomMargin,
        )
    }
}

internal enum class VoiceInputGradientDirection {
    TOP_TO_BOTTOM,
}

internal data class VoiceInputOverlayGradientSpec(
    val colors: IntArray,
    val positions: FloatArray,
    val direction: VoiceInputGradientDirection,
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is VoiceInputOverlayGradientSpec) return false
        return colors.contentEquals(other.colors) &&
            positions.contentEquals(other.positions) &&
            direction == other.direction
    }

    override fun hashCode(): Int {
        var result = colors.contentHashCode()
        result = 31 * result + positions.contentHashCode()
        result = 31 * result + direction.hashCode()
        return result
    }
}

internal object VoiceInputOverlayBackgroundPolicy {
    fun createGradientSpec(backgroundColor: Int): VoiceInputOverlayGradientSpec {
        return VoiceInputOverlayGradientSpec(
            colors = intArrayOf(
                ColorUtils.setAlphaComponent(backgroundColor, 0x00),
                ColorUtils.setAlphaComponent(backgroundColor, 0xB3),
                backgroundColor,
                backgroundColor,
            ),
            positions = floatArrayOf(0f, 0.42f, 0.67f, 1f),
            direction = VoiceInputGradientDirection.TOP_TO_BOTTOM,
        )
    }
}

internal class VoiceInputOverlayGradientBackgroundView(context: Context) : View(context) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private var spec = VoiceInputOverlayBackgroundPolicy.createGradientSpec(Color.TRANSPARENT)
    private var shaderHeight = -1

    fun setGradientSpec(gradientSpec: VoiceInputOverlayGradientSpec) {
        if (spec == gradientSpec) {
            return
        }
        spec = gradientSpec
        shaderHeight = -1
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        if (height <= 0 || width <= 0) {
            return
        }
        if (shaderHeight != height) {
            paint.shader = LinearGradient(
                0f,
                0f,
                0f,
                height.toFloat(),
                spec.colors,
                spec.positions,
                Shader.TileMode.CLAMP,
            )
            shaderHeight = height
        }
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)
    }
}

internal data class VoiceInputWaveformLayout(
    val startX: Float,
    val totalWidth: Float,
) {
    val waveformCenterX: Float = startX + totalWidth / 2f
}

internal object VoiceInputWaveformLayoutPolicy {
    fun calculate(containerWidth: Float, barCount: Int, barWidth: Float, gap: Float): VoiceInputWaveformLayout {
        val totalWidth = barCount * barWidth + (barCount - 1).coerceAtLeast(0) * gap
        return VoiceInputWaveformLayout(
            startX = (containerWidth - totalWidth) / 2f,
            totalWidth = totalWidth,
        )
    }
}

internal class VoiceInputBubbleView(context: Context) : View(context) {
    private val density = context.resources.displayMetrics.density
    private val bubblePaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val waveformPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.TRANSPARENT
        style = Paint.Style.FILL
    }
    private val cornerRadius = 12f * density

    private var bubbleColor = Color.TRANSPARENT
    private var powerLevel: Int = 0
    private var durationText: String = "00:00"
    private val durationPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.TRANSPARENT
        textAlign = Paint.Align.RIGHT
        textSize = 12f * density
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
    }

    private val totalBars = 24
    private val phases: FloatArray
    private val freqs: FloatArray

    private val startTimeNanos = System.nanoTime()
    private var animator: ValueAnimator? = null

    init {
        bubblePaint.color = bubbleColor
        bubblePaint.style = Paint.Style.FILL

        val rng = java.util.Random(20260421L)
        phases = FloatArray(totalBars) { rng.nextFloat() * (Math.PI * 2).toFloat() }
        freqs = FloatArray(totalBars) { 2.4f + rng.nextFloat() * 3.2f }
    }

    fun setBubbleColor(color: Int) {
        if (bubbleColor != color) {
            bubbleColor = color
            bubblePaint.color = color
            invalidate()
        }
    }

    fun setContentColor(color: Int) {
        waveformPaint.color = color
        durationPaint.color = color
        invalidate()
    }

    fun setPowerLevel(level: Int) {
        powerLevel = level.coerceIn(0, 100)
    }

    fun setDuration(durationMs: Int) {
        val seconds = (durationMs / 1000).coerceAtLeast(0)
        durationText = String.format("%02d:%02d", seconds / 60, seconds % 60)
        invalidate()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        animator?.cancel()
        animator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = 1000L
            repeatCount = ValueAnimator.INFINITE
            repeatMode = ValueAnimator.RESTART
            interpolator = LinearInterpolator()
            addUpdateListener { invalidate() }
            start()
        }
    }

    override fun onDetachedFromWindow() {
        animator?.cancel()
        animator = null
        super.onDetachedFromWindow()
    }

    override fun onDraw(canvas: Canvas) {
        val w = width.toFloat()
        val h = height.toFloat()
        canvas.drawRoundRect(0f, 0f, w, h, cornerRadius, cornerRadius, bubblePaint)
        drawWaveform(canvas, w, h)
        drawDuration(canvas, w, h)
    }

    private fun drawWaveform(canvas: Canvas, w: Float, bodyBottom: Float) {
        val centerY = bodyBottom / 2f
        val barWidth = 2.5f * density
        val gap = 3f * density
        val layout = VoiceInputWaveformLayoutPolicy.calculate(
            containerWidth = w,
            barCount = totalBars,
            barWidth = barWidth,
            gap = gap,
        )

        val t = (System.nanoTime() - startTimeNanos) / 1_000_000_000.0
        val amplitude = 13f * density * (0.45f + (powerLevel / 100f) * 0.55f)
        val minH = 3f * density

        for (i in 0 until totalBars) {
            val phase = phases[i].toDouble()
            val freq = freqs[i].toDouble()
            val wave = abs(sin(t * freq + phase)).toFloat()
            val barH = minH + amplitude * wave
            val x = layout.startX + i * (barWidth + gap)
            val top = centerY - barH / 2f
            val bottom = centerY + barH / 2f
            canvas.drawRoundRect(
                x,
                top,
                x + barWidth,
                bottom,
                barWidth / 2f,
                barWidth / 2f,
                waveformPaint,
            )
        }
    }

    private fun drawDuration(canvas: Canvas, w: Float, h: Float) {
        val centerY = h / 2f
        val textY = centerY - (durationPaint.descent() + durationPaint.ascent()) / 2f
        val isRtl = layoutDirection == View.LAYOUT_DIRECTION_RTL
        durationPaint.textAlign = if (isRtl) Paint.Align.LEFT else Paint.Align.RIGHT
        val x = if (isRtl) 16f * density else w - 16f * density
        canvas.drawText(durationText, x, textY, durationPaint)
    }
}
