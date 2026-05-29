package com.tencent.qcloud.tuikit.tuichat.component.voiceinput

import android.animation.ValueAnimator
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Typeface
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.text.InputType
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.animation.LinearInterpolator
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.PopupWindow
import android.widget.TextView
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat
import com.tencent.qcloud.tuikit.tuichat.R
import kotlin.math.abs
import kotlin.math.sin

internal class VoiceInputTranscriptionOverlay(
    private val anchorView: View,
    private val audioPath: String,
    private val audioDurationSecond: Int,
    private val initialText: String?,
    private val onCancel: () -> Unit,
    private val onSendAudio: (String, Int) -> Unit,
    private val onSendText: (String) -> Unit,
    private val onDismissed: () -> Unit,
) {
    private val context = anchorView.context
    private val density = context.resources.displayMetrics.density

    private val rootView = FrameLayout(context)
    private val backgroundView = VoiceInputOverlayGradientBackgroundView(context)
    private val bubbleView = TranscriptionBubbleView(context)
    private val editText = EditText(context)
    private val loadingDotsView = LoadingDotsView(context)
    private val cancelButton = FrameLayout(context)
    private val sendAudioButton = FrameLayout(context)
    private val cancelIcon = ImageView(context)
    private val sendAudioIcon = ImageView(context)
    private val sendTextButton = TextView(context)
    private val cancelLabel = TextView(context)
    private val sendAudioLabel = TextView(context)
    private val waveformView = OverlayWaveformBarView(context)
    private var bubbleLayoutParams: FrameLayout.LayoutParams? = null
    private var editTextLayoutParams: FrameLayout.LayoutParams? = null
    private var cancelButtonLayoutParams: FrameLayout.LayoutParams? = null
    private var sendAudioButtonLayoutParams: FrameLayout.LayoutParams? = null
    private var sendTextButtonLayoutParams: FrameLayout.LayoutParams? = null
    private var cancelLabelLayoutParams: FrameLayout.LayoutParams? = null
    private var sendAudioLabelLayoutParams: FrameLayout.LayoutParams? = null
    private var waveformLayoutParams: FrameLayout.LayoutParams? = null
    private var bubbleHeightPx = 0
    private var keyboardHeightPx = 0
    private var legacyKeyboardProbe: LegacyKeyboardHeightProbe? = null
    private val rootLayoutChangeListener = View.OnLayoutChangeListener { _, _, _, _, _, _, _, _, _ ->
        updateOverlayLayout()
    }
    private val popupWindow = PopupWindow(
        rootView,
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.MATCH_PARENT,
        true,
    ).apply {
        setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        isClippingEnabled = true
        isTouchable = true
        isFocusable = true
        isOutsideTouchable = true
        inputMethodMode = PopupWindow.INPUT_METHOD_NEEDED
        setOnDismissListener {
            cleanupKeyboardTracking()
            onDismissed()
        }
    }

    private var state: TranscriptionState = when {
        initialText == null -> TranscriptionState.LOADING
        initialText.isBlank() -> TranscriptionState.EMPTY
        else -> TranscriptionState.TEXT
    }

    init {
        buildLayout()
        bindActions()
        applyTheme()
    }

    fun show() {
        if (popupWindow.isShowing || !anchorView.isAttachedToWindow) {
            return
        }
        popupWindow.showAtLocation(anchorView, Gravity.NO_GRAVITY, 0, 0)
        rootView.addOnLayoutChangeListener(rootLayoutChangeListener)
        installKeyboardTracking()
        rootView.post {
            ViewCompat.requestApplyInsets(rootView)
            updateOverlayLayout()
        }
    }

    fun dismiss() {
        if (popupWindow.isShowing) {
            popupWindow.dismiss()
        }
    }

    fun updateResult(resultText: String?) {
        state = if (resultText.isNullOrBlank()) {
            TranscriptionState.EMPTY
        } else {
            TranscriptionState.TEXT
        }
        updateBubbleHeightForState(resultText)
        bindBubbleText(resultText)
        applyTheme()
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

        val bubbleHeight = if (state == TranscriptionState.TEXT && (initialText?.length ?: 0) > 24) 104 else 68
        bubbleHeightPx = (bubbleHeight * density).toInt()
        val initialLayout = calculateOverlayLayout(
            rootHeight = context.resources.displayMetrics.heightPixels,
            bubbleHeight = bubbleHeightPx,
            keyboardHeight = 0,
        )
        val bubbleLp = FrameLayout.LayoutParams((330 * density).toInt(), bubbleHeightPx)
        bubbleLp.leftMargin = scaledLeft(16, 330)
        bubbleLp.topMargin = initialLayout.bubbleTop
        bubbleLayoutParams = bubbleLp
        rootView.addView(bubbleView, bubbleLp)
        bubbleView.layoutDirection = rootView.layoutDirection

        editText.gravity = Gravity.START or Gravity.CENTER_VERTICAL
        editText.textAlignment = View.TEXT_ALIGNMENT_VIEW_START
        editText.textDirection = View.TEXT_DIRECTION_LOCALE
        editText.includeFontPadding = false
        editText.minHeight = 0
        editText.setMinLines(1)
        editText.maxLines = 4
        editText.isVerticalScrollBarEnabled = true
        editText.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
        editText.typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        editText.background = null
        editText.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_MULTI_LINE
        editText.setPadding((16 * density).toInt(), 0, (16 * density).toInt(), 0)
        val editLp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            bubbleContentHeightPx(),
            Gravity.TOP or Gravity.START,
        )
        editTextLayoutParams = editLp
        bubbleView.addView(editText, editLp)

        val dotsLp = FrameLayout.LayoutParams(
            (48 * density).toInt(),
            (20 * density).toInt(),
            Gravity.START or Gravity.TOP,
        )
        dotsLp.marginStart = (20 * density).toInt()
        dotsLp.topMargin = ((bubbleContentHeightPx() - dotsLp.height) / 2).coerceAtLeast(0)
        bubbleView.addView(loadingDotsView, dotsLp)
        bindBubbleText(initialText)

        cancelButtonLayoutParams = addCircleIcon(
            cancelButton,
            cancelIcon,
            R.drawable.voice_input_close_icon,
            48,
            48,
            initialLayout.cancelButtonTop,
        )
        sendAudioButtonLayoutParams = addCircleIcon(
            sendAudioButton,
            sendAudioIcon,
            R.drawable.voice_input_transcribe_icon,
            48,
            142,
            initialLayout.sendAudioButtonTop,
        )
        sendTextButtonLayoutParams = addCircleText(
            sendTextButton,
            context.getString(R.string.send),
            80,
            262,
            initialLayout.sendTextButtonTop,
        )
        cancelLabelLayoutParams = addLabel(
            cancelLabel,
            context.getString(R.string.voice_input_cancel),
            72,
            initialLayout.labelTop,
        )
        sendAudioLabelLayoutParams = addLabel(
            sendAudioLabel,
            context.getString(R.string.voice_input_send_original_voice),
            166,
            initialLayout.labelTop,
        )

        val waveformLp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            (40 * density).toInt(),
            Gravity.TOP,
        )
        waveformLp.leftMargin = scaleX(16)
        waveformLp.rightMargin = scaleX(16)
        waveformLp.topMargin = initialLayout.waveformTop
        waveformLayoutParams = waveformLp
        waveformView.setDurationSecond(audioDurationSecond)
        rootView.addView(waveformView, waveformLp)
        waveformView.layoutDirection = rootView.layoutDirection
    }

    private fun addCircleIcon(
        view: FrameLayout,
        icon: ImageView,
        iconRes: Int,
        sizeDp: Int,
        leftDp: Int,
        topPx: Int,
    ): FrameLayout.LayoutParams {
        icon.setImageResource(iconRes)
        icon.scaleType = ImageView.ScaleType.CENTER
        icon.setColorFilter(VoiceInputColors.TEXT_PRIMARY)
        view.addView(
            icon,
            FrameLayout.LayoutParams((20 * density).toInt(), (20 * density).toInt(), Gravity.CENTER),
        )
        val lp = FrameLayout.LayoutParams((sizeDp * density).toInt(), (sizeDp * density).toInt())
        lp.leftMargin = scaledLeft(leftDp, sizeDp)
        lp.topMargin = topPx
        rootView.addView(view, lp)
        return lp
    }

    private fun addCircleText(
        view: TextView,
        label: String,
        sizeDp: Int,
        leftDp: Int,
        topPx: Int,
    ): FrameLayout.LayoutParams {
        view.gravity = Gravity.CENTER
        view.text = label
        view.setTextSize(TypedValue.COMPLEX_UNIT_SP, if (sizeDp >= 80) 16f else 24f)
        val lp = FrameLayout.LayoutParams((sizeDp * density).toInt(), (sizeDp * density).toInt())
        lp.leftMargin = scaledLeft(leftDp, sizeDp)
        lp.topMargin = topPx
        rootView.addView(view, lp)
        return lp
    }

    private fun addLabel(view: TextView, label: String, centerXDp: Int, topPx: Int): FrameLayout.LayoutParams {
        view.gravity = Gravity.CENTER
        view.text = label
        view.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
        val lp = FrameLayout.LayoutParams((96 * density).toInt(), (20 * density).toInt())
        lp.leftMargin = mirroredLeft(scaleX(centerXDp) - dp(48), dp(96))
        lp.topMargin = topPx
        rootView.addView(view, lp)
        return lp
    }

    private fun bindActions() {
        cancelButton.setOnClickListener {
            dismiss()
            onCancel()
        }
        sendAudioButton.setOnClickListener {
            dismiss()
            onSendAudio(audioPath, audioDurationSecond.coerceAtLeast(1))
        }
        sendTextButton.isEnabled = state == TranscriptionState.TEXT
        sendTextButton.setOnClickListener {
            val currentText = editText.text?.toString().orEmpty()
            if (currentText.isBlank()) {
                return@setOnClickListener
            }
            dismiss()
            onSendText(currentText)
        }
    }

    private fun applyTheme() {
        backgroundView.setGradientSpec(VoiceInputOverlayBackgroundPolicy.createGradientSpec(VoiceInputColors.BG_OPERATE))
        bubbleView.setBubbleColor(
            if (state == TranscriptionState.EMPTY) VoiceInputColors.BUTTON_HANGUP_DEFAULT
            else VoiceInputColors.BUTTON_PRIMARY_DEFAULT
        )
        loadingDotsView.setDotColor(VoiceInputColors.TEXT_BUTTON)
        editText.setTextColor(VoiceInputColors.TEXT_BUTTON)
        setCircleBackground(cancelButton, VoiceInputColors.BUTTON_SECONDARY_DEFAULT)
        setCircleBackground(sendAudioButton, VoiceInputColors.BUTTON_SECONDARY_DEFAULT)
        setCircleBackground(
            sendTextButton,
            if (state == TranscriptionState.TEXT) VoiceInputColors.BUTTON_PRIMARY_DEFAULT
            else VoiceInputColors.BUTTON_PRIMARY_DISABLED,
        )
        cancelIcon.setColorFilter(VoiceInputColors.TEXT_PRIMARY)
        sendAudioIcon.setColorFilter(VoiceInputColors.TEXT_PRIMARY)
        sendTextButton.setTextColor(VoiceInputColors.TEXT_BUTTON)
        cancelLabel.setTextColor(VoiceInputColors.TEXT_TERTIARY)
        sendAudioLabel.setTextColor(VoiceInputColors.TEXT_TERTIARY)
        waveformView.setBarColor(VoiceInputColors.BG_INPUT)
        waveformView.setContentColor(VoiceInputColors.TEXT_PRIMARY)
    }

    private fun bindBubbleText(resultText: String?) {
        if (state == TranscriptionState.LOADING) {
            editText.visibility = View.GONE
            loadingDotsView.visibility = View.VISIBLE
            editText.setText("")
        } else {
            val displayText = when (state) {
                TranscriptionState.EMPTY -> context.getString(R.string.voice_input_transcription_empty)
                TranscriptionState.TEXT -> resultText.orEmpty()
                TranscriptionState.LOADING -> ""
            }
            loadingDotsView.visibility = View.GONE
            editText.visibility = View.VISIBLE
            editText.setText(displayText)
            editText.setSelection(editText.text?.length ?: 0)
            editText.isEnabled = state == TranscriptionState.TEXT
        }
        sendTextButton.isEnabled = state == TranscriptionState.TEXT
    }

    private fun installKeyboardTracking() {
        ViewCompat.setOnApplyWindowInsetsListener(rootView) { _, insets ->
            val imeBottom = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom
            updateKeyboardHeight(KeyboardInsetsUtil.toPanelSpacerHeight(imeBottom, insets))
            insets
        }
        ViewCompat.setWindowInsetsAnimationCallback(
            rootView,
            object : WindowInsetsAnimationCompat.Callback(DISPATCH_MODE_CONTINUE_ON_SUBTREE) {
                override fun onProgress(
                    insets: WindowInsetsCompat,
                    runningAnimations: List<WindowInsetsAnimationCompat>,
                ): WindowInsetsCompat {
                    val imeBottom = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom
                    updateKeyboardHeight(KeyboardInsetsUtil.toPanelSpacerHeight(imeBottom, insets))
                    return insets
                }
            },
        )
        startLegacyKeyboardProbeIfNeeded()
    }

    private fun startLegacyKeyboardProbeIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R || legacyKeyboardProbe != null) {
            return
        }
        val activity = findActivity(context) ?: return
        val minKeyboardHeight = (80 * density).toInt()
        legacyKeyboardProbe = LegacyKeyboardHeightProbe(
            activity = activity,
            minKeyboardHeight = minKeyboardHeight,
            navigationBarBottomProvider = {
                KeyboardInsetsUtil.getNavigationBarBottom(activity, rootView)
            },
            listener = object : LegacyKeyboardHeightProbe.Listener {
                override fun onProbeHeightChanged(height: Int, visible: Boolean) {
                    updateKeyboardHeight(if (visible) height else 0)
                }
            },
        ).also { probe ->
            probe.start(rootView)
        }
    }

    private fun cleanupKeyboardTracking() {
        rootView.removeOnLayoutChangeListener(rootLayoutChangeListener)
        ViewCompat.setOnApplyWindowInsetsListener(rootView, null)
        ViewCompat.setWindowInsetsAnimationCallback(rootView, null)
        legacyKeyboardProbe?.stop()
        legacyKeyboardProbe = null
        keyboardHeightPx = 0
    }

    private fun updateKeyboardHeight(height: Int) {
        val nextHeight = height.coerceAtLeast(0)
        if (keyboardHeightPx == nextHeight) {
            return
        }
        keyboardHeightPx = nextHeight
        updateOverlayLayout()
    }

    private fun updateOverlayLayout() {
        if (bubbleHeightPx <= 0) return
        val rootHeight = rootView.height.takeIf { it > 0 }
            ?: context.resources.displayMetrics.heightPixels
        val layout = calculateOverlayLayout(
            rootHeight = rootHeight,
            bubbleHeight = bubbleHeightPx,
            keyboardHeight = keyboardHeightPx,
        )
        updateTopMargin(bubbleView, bubbleLayoutParams, layout.bubbleTop)
        updateTopMargin(cancelButton, cancelButtonLayoutParams, layout.cancelButtonTop)
        updateTopMargin(sendAudioButton, sendAudioButtonLayoutParams, layout.sendAudioButtonTop)
        updateTopMargin(sendTextButton, sendTextButtonLayoutParams, layout.sendTextButtonTop)
        updateTopMargin(cancelLabel, cancelLabelLayoutParams, layout.labelTop)
        updateTopMargin(sendAudioLabel, sendAudioLabelLayoutParams, layout.labelTop)
        updateTopMargin(waveformView, waveformLayoutParams, layout.waveformTop)
    }

    private fun updateTopMargin(view: View, lp: FrameLayout.LayoutParams?, topMargin: Int) {
        if (lp == null || lp.topMargin == topMargin) {
            return
        }
        lp.topMargin = topMargin
        view.layoutParams = lp
    }

    private fun updateBubbleHeightForState(resultText: String?) {
        val bubbleHeight = if (state == TranscriptionState.TEXT && (resultText?.length ?: 0) > 24) 104 else 68
        val nextHeightPx = (bubbleHeight * density).toInt()
        if (nextHeightPx == bubbleHeightPx) {
            return
        }
        bubbleHeightPx = nextHeightPx
        bubbleLayoutParams?.let { lp ->
            lp.height = nextHeightPx
            bubbleView.layoutParams = lp
        }
        editTextLayoutParams?.let { lp ->
            lp.height = bubbleContentHeightPx()
            editText.layoutParams = lp
        }
        updateLoadingDotsPosition()
        updateOverlayLayout()
    }

    private fun calculateOverlayLayout(
        rootHeight: Int,
        bubbleHeight: Int,
        keyboardHeight: Int,
    ): OverlayLayout {
        val safeRootHeight = rootHeight.coerceAtLeast(1)
        val iconButtonSize = dp(48)
        val sendTextButtonSize = dp(80)
        val labelHeight = dp(20)
        val waveformHeight = dp(40)
        val waveformBottom = dp(41)
        val labelToWaveformGap = dp(26)
        val iconToLabelGap = dp(4)
        val sendTextToWaveformGap = dp(24)
        val bubbleToActionGap = dp(12)
        val bubbleToKeyboardGap = dp(24)

        val waveformTop = (safeRootHeight - waveformBottom - waveformHeight).coerceAtLeast(0)
        val labelTop = (waveformTop - labelToWaveformGap - labelHeight).coerceAtLeast(0)
        val iconButtonTop = (labelTop - iconToLabelGap - iconButtonSize).coerceAtLeast(0)
        val sendTextButtonTop = (waveformTop - sendTextToWaveformGap - sendTextButtonSize).coerceAtLeast(0)
        val firstActionTop = minOf(iconButtonTop, sendTextButtonTop)

        val designBubbleTop = dp(549)
        val maxBubbleTopBeforeActions = (firstActionTop - bubbleToActionGap - bubbleHeight).coerceAtLeast(0)
        val maxBubbleTopBeforeKeyboard = if (keyboardHeight > 0) {
            (safeRootHeight - keyboardHeight - bubbleToKeyboardGap - bubbleHeight).coerceAtLeast(0)
        } else {
            Int.MAX_VALUE
        }

        return OverlayLayout(
            bubbleTop = minOf(designBubbleTop, maxBubbleTopBeforeActions, maxBubbleTopBeforeKeyboard),
            cancelButtonTop = iconButtonTop,
            sendAudioButtonTop = iconButtonTop,
            sendTextButtonTop = sendTextButtonTop,
            labelTop = labelTop,
            waveformTop = waveformTop,
        )
    }

    private fun updateLoadingDotsPosition() {
        val lp = loadingDotsView.layoutParams as? FrameLayout.LayoutParams ?: return
        val nextTop = ((bubbleContentHeightPx() - lp.height) / 2).coerceAtLeast(0)
        if (lp.topMargin != nextTop) {
            lp.topMargin = nextTop
            loadingDotsView.layoutParams = lp
        }
    }

    private fun bubbleContentHeightPx(): Int {
        return (bubbleHeightPx - dp(BUBBLE_TRIANGLE_HEIGHT_DP)).coerceAtLeast(0)
    }

    private fun dp(value: Int): Int = (value * density).toInt()

    private fun scaleX(valueDp: Int): Int {
        val screenWidth = context.resources.displayMetrics.widthPixels
        return (valueDp * screenWidth / DESIGN_WIDTH_DP).toInt()
    }

    private fun scaledLeft(leftDp: Int, widthDp: Int): Int {
        return mirroredLeft(scaleX(leftDp), dp(widthDp))
    }

    private fun mirroredLeft(left: Int, width: Int): Int {
        if (rootView.layoutDirection != View.LAYOUT_DIRECTION_RTL) {
            return left
        }
        val screenWidth = context.resources.displayMetrics.widthPixels
        return (screenWidth - left - width).coerceAtLeast(0)
    }

    private fun setCircleBackground(view: View, color: Int) {
        view.background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(color)
        }
    }

    private fun findActivity(context: Context): Activity? {
        var currentContext = context
        while (currentContext is ContextWrapper) {
            if (currentContext is Activity) {
                return currentContext
            }
            currentContext = currentContext.baseContext
        }
        return currentContext as? Activity
    }

    private enum class TranscriptionState {
        LOADING,
        EMPTY,
        TEXT,
    }

    private data class OverlayLayout(
        val bubbleTop: Int,
        val cancelButtonTop: Int,
        val sendAudioButtonTop: Int,
        val sendTextButtonTop: Int,
        val labelTop: Int,
        val waveformTop: Int,
    )

    private companion object {
        private const val DESIGN_WIDTH_DP = 390f
        private const val BUBBLE_TRIANGLE_HEIGHT_DP = 14
    }
}

private class TranscriptionBubbleView(context: Context) : FrameLayout(context) {
    private val density = context.resources.displayMetrics.density
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }
    private val path = Path()
    private var bubbleColor = Color.TRANSPARENT

    init {
        setWillNotDraw(false)
    }

    fun setBubbleColor(color: Int) {
        bubbleColor = color
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        val triangleHeight = 14f * density
        val bodyBottom = height - triangleHeight
        val radius = 8f * density
        path.reset()
        path.addRoundRect(RectF(0f, 0f, width.toFloat(), bodyBottom), radius, radius, Path.Direction.CW)
        val centerX = width - 64f * density
        path.moveTo(centerX - 12f * density, bodyBottom)
        path.lineTo(centerX, height.toFloat())
        path.lineTo(centerX + 12f * density, bodyBottom)
        path.close()
        paint.color = bubbleColor
        canvas.drawPath(path, paint)
        super.onDraw(canvas)
    }
}

private class LoadingDotsView(context: Context) : View(context) {
    private val density = context.resources.displayMetrics.density
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
        color = Color.TRANSPARENT
    }
    private var animator: ValueAnimator? = null
    private var progress = 0f

    fun setDotColor(color: Int) {
        paint.color = color
        invalidate()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        animator?.cancel()
        animator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = 900L
            repeatCount = ValueAnimator.INFINITE
            interpolator = LinearInterpolator()
            addUpdateListener { animation ->
                progress = animation.animatedValue as Float
                invalidate()
            }
            start()
        }
    }

    override fun onDetachedFromWindow() {
        animator?.cancel()
        animator = null
        super.onDetachedFromWindow()
    }

    override fun onDraw(canvas: Canvas) {
        val radius = 3f * density
        val gap = 10f * density
        val startX = radius
        val centerY = height / 2f
        for (index in 0 until 3) {
            val phase = (progress + index * 0.18f) % 1f
            val alpha = (90 + 165 * abs(sin(phase * Math.PI))).toInt().coerceIn(90, 255)
            paint.alpha = alpha
            canvas.drawCircle(startX + index * gap, centerY, radius, paint)
        }
        paint.alpha = 255
    }
}

private class OverlayWaveformBarView(context: Context) : View(context) {
    private val density = context.resources.displayMetrics.density
    private val barPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
        color = Color.TRANSPARENT
    }
    private val dotPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
        color = Color.TRANSPARENT
    }
    private var animator: ValueAnimator? = null
    private val startTimeNanos = System.nanoTime()
    private var durationText = "00:00"
    private val durationPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        alpha = 160
        textAlign = Paint.Align.RIGHT
        textSize = 12f * density
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
    }

    fun setBarColor(color: Int) {
        barPaint.color = color
        invalidate()
    }

    fun setContentColor(color: Int) {
        dotPaint.color = color
        durationPaint.color = color
        invalidate()
    }

    fun setDurationSecond(durationSecond: Int) {
        val seconds = durationSecond.coerceAtLeast(0)
        durationText = String.format("%02d:%02d", seconds / 60, seconds % 60)
        invalidate()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        animator?.cancel()
        animator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = 1000L
            repeatCount = ValueAnimator.INFINITE
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
        val radius = 12f * density
        canvas.drawRoundRect(0f, 0f, width.toFloat(), height.toFloat(), radius, radius, barPaint)
        val dotRadius = 1.5f * density
        val gap = 8f * density
        val count = 24
        val totalWidth = (count - 1) * gap
        val startX = ((width - totalWidth) / 2f) - 18f * density
        val centerY = height / 2f
        val t = (System.nanoTime() - startTimeNanos) / 1_000_000_000.0
        for (i in 0 until count) {
            val alpha = (120 + 80 * abs(sin(t * 3.0 + i * 0.35))).toInt().coerceIn(0, 255)
            dotPaint.alpha = alpha
            canvas.drawCircle(startX + i * gap, centerY, dotRadius, dotPaint)
        }
        dotPaint.alpha = 255
        val isRtl = layoutDirection == View.LAYOUT_DIRECTION_RTL
        durationPaint.textAlign = if (isRtl) Paint.Align.LEFT else Paint.Align.RIGHT
        canvas.drawText(
            durationText,
            if (isRtl) 16f * density else width - 16f * density,
            centerY - (durationPaint.descent() + durationPaint.ascent()) / 2f,
            durationPaint,
        )
    }
}
