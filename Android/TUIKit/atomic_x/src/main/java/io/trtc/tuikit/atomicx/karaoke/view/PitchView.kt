package io.trtc.tuikit.atomicx.karaoke.view

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.Typeface.BOLD
import android.graphics.drawable.Drawable
import android.util.TypedValue
import android.view.View
import androidx.core.content.ContextCompat
import com.tencent.trtc.TXChorusMusicPlayer
import io.trtc.tuikit.atomicx.R
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.sin
import kotlin.random.Random

class PitchView(
    context: Context,
) : View(context) {

    private data class Butterfly(
        val drawable: Drawable, val x0: Float, val y0: Float, val angle: Float,
        val scale: Float, val baseRotation: Float, val startTime: Long, val lifeMs: Long
    )

    private val PITCH_TIME_TO_PIXELS_RATIO = 0.15f
    private val PITCH_LINE_HEIGHT_DP = 3f
    private val PITCH_DOT_RADIUS_DP = 4.5f
    private val PITCH_HIT_TOLERANCE = 0.0f
    private val SCORE_TEXT_SIZE_SP = 8f
    private val SCORE_LABEL_GAP_DP = 3f
    private val SCORE_BUBBLE_HEIGHT_DP = 12f
    private val DOT_ANIMATION_SMOOTHING_FACTOR = 0.2f
    private val lineColor = ContextCompat.getColor(context, R.color.karaoke_pitch_line)
    private val highlightColor = ContextCompat.getColor(context, R.color.karaoke_text_color_red)
    private val dotColor = ContextCompat.getColor(context, R.color.karaoke_white)
    private val scoreLineColor = ContextCompat.getColor(context, R.color.karaoke_color_grey_8c)
    private val scoreTextColor = ContextCompat.getColor(context, R.color.karaoke_pitch_score_text)
    private val linePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = dpToPx(PITCH_LINE_HEIGHT_DP)
        color = lineColor
        strokeCap = Paint.Cap.ROUND
    }
    private val highlightLinePaint = Paint(linePaint).apply { color = highlightColor }
    private val dotPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
        color = dotColor
        setShadowLayer(8f, 0f, 2f, 0x77000000)
    }
    private val scoreLinePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = scoreLineColor
        strokeWidth = dpToPx(1f)
        style = Paint.Style.STROKE
    }
    private val scoreTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = scoreTextColor
        style = Paint.Style.FILL
        textSize = spToPx(SCORE_TEXT_SIZE_SP)
        textAlign = Paint.Align.CENTER
        typeface = Typeface.create(Typeface.DEFAULT, BOLD)
    }
    private val scoreTagDrawable: Drawable? by lazy {
        ContextCompat.getDrawable(context, R.drawable.karaoke_score_bg)
    }
    private val butterflies = mutableListOf<Butterfly>()
    private val butterflyDrawables: List<Drawable?> by lazy {
        listOf(ContextCompat.getDrawable(context, R.drawable.karaoke_song_well_icon))
    }
    private val butterflyFlyDistance = dpToPx(52f)
    private val butterflyLife = 1350L
    private var pitchList: List<TXChorusMusicPlayer.TXReferencePitch> = emptyList()
    private var userPitch: Int = 0
    private var currentProgressMs: Long = 0L
    private var currentScore: Int = -1
    private var isScoringEnabled: Boolean = false
    private var hitProgress: FloatArray = FloatArray(0)
    private var pitchStartOffsetsPx: List<Float> = emptyList()
    private var minPitch: Int = 0
    private var maxPitch: Int = 100
    private var scrollOffset: Float = 0f
    private var currentDotTargetY: Float? = null
    private var currentDotAnimatedY: Float? = null
    private var lastHitSegmentIndexForButterfly = -1

    fun setPitchList(list: List<TXChorusMusicPlayer.TXReferencePitch>?) {
        val pitchList = list ?: emptyList()
        this@PitchView.pitchList = pitchList
        hitProgress = FloatArray(pitchList.size)

        if (pitchList.isEmpty()) {
            pitchStartOffsetsPx = emptyList()
        } else {
            minPitch = 0
            maxPitch = 100
            pitchStartOffsetsPx = pitchList.map { it.startTimeMs * PITCH_TIME_TO_PIXELS_RATIO }
        }
        resetState()
        invalidate()
    }

    fun setPlayProgress(progressMs: Long) {
        currentProgressMs = progressMs
        updateStateByProgress()
        invalidate()
    }

    fun setUserPitch(pitch: Int) {
        val newPitch = pitch.coerceIn(0, 100)
        if (userPitch != newPitch) {
            userPitch = newPitch
            invalidate()
        }
    }

    fun setScore(score: Int) {
        if (currentScore != score) {
            currentScore = score
            invalidate()
        }
    }

    fun setScoringEnabled(enabled: Boolean) {
        if (isScoringEnabled != enabled) {
            isScoringEnabled = enabled
            if (!enabled) {
                currentScore = -1
            }
            invalidate()
        }
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        if (width == 0 || height == 0) {
            return
        }

        val viewCenterX = width / 2f
        val viewHeight = height.toFloat()

        if (pitchList.isEmpty()) {
            canvas.drawLine(viewCenterX, 0f, viewCenterX, viewHeight, scoreLinePaint)
            drawUserPitchDot(canvas, viewCenterX)
            return
        }

        for (i in pitchList.indices) {
            val pitchData = pitchList[i]
            val lineLength = pitchData.durationMs * PITCH_TIME_TO_PIXELS_RATIO
            val startOffsetPx = pitchStartOffsetsPx[i]

            val x1 = viewCenterX + startOffsetPx - scrollOffset
            val x2 = x1 + lineLength

            if (x2 < 0 || x1 > width) {
                continue
            }

            val y = convertPitchToY(pitchData.referencePitch.toFloat())

            canvas.drawLine(x1, y, x2, y, linePaint)

            val hitRatio = hitProgress[i]
            if (hitRatio > 0) {
                val highlightWidth = (x2 - x1) * hitRatio
                canvas.drawLine(x1, y, x1 + highlightWidth, y, highlightLinePaint)
            }
        }

        canvas.drawLine(viewCenterX, 0f, viewCenterX, viewHeight, scoreLinePaint)
        drawUserPitchDot(canvas, viewCenterX)
        drawButterflies(canvas)
    }

    private fun resetState() {
        currentProgressMs = 0L
        userPitch = 0
        scrollOffset = 0f
        currentDotTargetY = null
        currentDotAnimatedY = null
        butterflies.clear()
        lastHitSegmentIndexForButterfly = -1
        currentScore = -1
        hitProgress.fill(0f)
    }

    private fun updateStateByProgress() {
        scrollOffset = currentProgressMs * PITCH_TIME_TO_PIXELS_RATIO

        val currentSegmentIndex = pitchList.indexOfFirst {
            currentProgressMs >= it.startTimeMs && currentProgressMs < (it.startTimeMs + it.durationMs)
        }

        if (currentSegmentIndex != -1) {
            checkPitchHit(currentSegmentIndex)
        } else {
            lastHitSegmentIndexForButterfly = -1
        }

        updateButterflies()
    }

    private fun checkPitchHit(currentSegmentIndex: Int) {
        if (userPitch < 0) return

        val segment = pitchList[currentSegmentIndex]
        val referencePitch = segment.referencePitch
        val pitchDifference = abs(userPitch - referencePitch)

        if (pitchDifference <= PITCH_HIT_TOLERANCE) {
            val progressInSegment = (currentProgressMs - segment.startTimeMs).toFloat()
            val currentHitRatio = (progressInSegment / segment.durationMs).coerceIn(0f, 1f)
            hitProgress[currentSegmentIndex] = hitProgress[currentSegmentIndex].coerceAtLeast(currentHitRatio)

            if (lastHitSegmentIndexForButterfly != currentSegmentIndex) {
                lastHitSegmentIndexForButterfly = currentSegmentIndex
                val y = convertPitchToY(referencePitch.toFloat())
                emitButterfly(width / 2f, y)
            }
        }
    }

    private fun drawUserPitchDot(canvas: Canvas, centerX: Float) {
        val defaultY = convertPitchToY(minPitch.toFloat())
        var animatedY = currentDotAnimatedY

        val finalTargetY = if (currentScore < 0) {
            defaultY
        } else {
            convertPitchToY(userPitch.toFloat())
        }

        if (animatedY == null) {
            animatedY = finalTargetY
        }

        val diff = finalTargetY - animatedY
        if (abs(diff) < 1f) {
            animatedY = finalTargetY
        } else {
            animatedY += diff * DOT_ANIMATION_SMOOTHING_FACTOR
            invalidate()
        }

        currentDotAnimatedY = animatedY
        canvas.drawCircle(centerX, animatedY, dpToPx(PITCH_DOT_RADIUS_DP), dotPaint)

        if (isScoringEnabled) {
            drawScoreTag(canvas, centerX, animatedY)
        }
    }

    private fun drawScoreTag(canvas: Canvas, centerX: Float, dotY: Float) {
        val tagDrawable = scoreTagDrawable ?: return
        val scoreText = if (currentScore < 0) "评分" else currentScore.toString()

        val tagHeight = dpToPx(SCORE_BUBBLE_HEIGHT_DP)
        val scale = tagHeight / tagDrawable.intrinsicHeight.toFloat()
        val tagWidth = tagDrawable.intrinsicWidth * scale

        val dotRadius = dpToPx(PITCH_DOT_RADIUS_DP)
        val labelGap = dpToPx(SCORE_LABEL_GAP_DP)

        val tagTop = (dotY - dotRadius - labelGap - tagHeight)
        tagDrawable.setBounds(
            (centerX - tagWidth / 2).toInt(),
            tagTop.toInt(),
            (centerX + tagWidth / 2).toInt(),
            (tagTop + tagHeight).toInt()
        )
        tagDrawable.draw(canvas)

        val textBaseY = tagTop + tagHeight / 2f + getTextHeightCenterOffset(scoreTextPaint)
        canvas.drawText(scoreText, centerX, textBaseY, scoreTextPaint)
    }

    private fun convertPitchToY(pitch: Float): Float {
        if (height == 0) return 0f

        val drawTop = height * 0.1f
        val drawHeight = height * 0.8f
        val pitchRange = (maxPitch - minPitch).toFloat().coerceAtLeast(1f)
        val clampedPitch = pitch.coerceIn(minPitch.toFloat(), maxPitch.toFloat())
        val percent = (clampedPitch - minPitch) / pitchRange
        return drawTop + (1.0f - percent) * drawHeight
    }

    private fun dpToPx(dp: Float): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, resources.displayMetrics)

    private fun spToPx(sp: Float): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, sp, resources.displayMetrics)

    private fun getTextHeightCenterOffset(paint: Paint): Float {
        val metrics = paint.fontMetrics
        return (metrics.descent - metrics.ascent) / 2 - metrics.descent
    }

    private fun emitButterfly(x: Float, y: Float) {
        val drawable = butterflyDrawables.filterNotNull().randomOrNull() ?: return
        val angle = 240f + (Random.nextFloat() - 0.5f) * 20f
        val scale = 1.00f + Random.nextFloat() * 0.34f
        val baseRotation = -15f + Random.nextFloat() * 30f
        butterflies.add(
            Butterfly(
                drawable = drawable, x0 = x, y0 = y, angle = angle, scale = scale,
                baseRotation = baseRotation, startTime = System.currentTimeMillis(), lifeMs = butterflyLife
            )
        )
    }

    private fun updateButterflies() {
        val now = System.currentTimeMillis()
        butterflies.removeAll { now - it.startTime > it.lifeMs }
    }

    private fun drawButterflies(canvas: Canvas) {
        val now = System.currentTimeMillis()
        for (b in butterflies) {
            val t = ((now - b.startTime).toFloat() / b.lifeMs).coerceIn(0f, 1f)
            val rad = Math.toRadians(b.angle.toDouble())
            val dx = butterflyFlyDistance * t * cos(rad).toFloat()
            val dy = butterflyFlyDistance * t * sin(rad).toFloat()
            val x = b.x0 + dx
            val y = b.y0 + dy
            val scale = b.scale * (1.00f - 0.14f * t)
            val d = b.drawable
            val w = d.intrinsicWidth * scale
            val h = d.intrinsicHeight * scale
            val alpha = (180 * (1 - t)).toInt().coerceIn(0, 255)
            canvas.save()
            canvas.translate(x, y)
            val swing = sin(t * Math.PI * 2.0 * 1.1f).toFloat() * 18f
            canvas.rotate(b.baseRotation + swing + b.angle)
            d.setBounds((-w / 2).toInt(), (-h / 2).toInt(), (w / 2).toInt(), (h / 2).toInt())
            d.alpha = alpha
            d.draw(canvas)
            canvas.restore()
        }
    }
}