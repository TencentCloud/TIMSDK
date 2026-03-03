package io.trtc.tuikit.atomicx.karaoke.view

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Typeface
import android.text.TextPaint
import android.util.TypedValue
import android.view.View
import androidx.core.content.ContextCompat
import com.tencent.trtc.TXChorusMusicPlayer
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.karaoke.store.KaraokeStore
import io.trtc.tuikit.atomicx.karaoke.store.utils.LyricAlign

val TXChorusMusicPlayer.TXLyricLine.fullContent: String
    get() = characterArray.joinToString("") { it.utf8Character }

class LyricView(
    context: Context,
    private val store: KaraokeStore,
) : View(context) {
    private var currentProgressMs: Long = 0L
    private var currentLineIndex: Int = 0
    private var highlightTextSizeSp: Float = 14f
    private var nextLineTextSizeSp: Float = 10f
    private var lineSpace: Float = spToPx(nextLineTextSizeSp) * 1.8f
    private val colorBlue = ContextCompat.getColor(context, R.color.karaoke_lyric_blue)
    private val colorWhite = ContextCompat.getColor(context, R.color.karaoke_white)
    private val colorGrey = ContextCompat.getColor(context, R.color.karaoke_lyric_grey)
    private var lyricAlign: LyricAlign = LyricAlign.RIGHT

    private val paintCurrentLine = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
        color = colorWhite
        textAlign = Paint.Align.RIGHT
        textSize = spToPx(highlightTextSizeSp)
        typeface = Typeface.DEFAULT_BOLD
    }
    private val paintHighlightedLine = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
        color = colorBlue
        textAlign = Paint.Align.RIGHT
        textSize = spToPx(highlightTextSizeSp)
        typeface = Typeface.DEFAULT_BOLD
    }
    private val paintNextLine = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
        color = colorGrey
        textAlign = Paint.Align.RIGHT
        textSize = spToPx(nextLineTextSizeSp)
        typeface = Typeface.DEFAULT
    }

    init {
        updatePaintAlign()
        updatePaintTextSize()
    }

    fun setLyricAlign(align: LyricAlign) {
        if (lyricAlign != align) {
            lyricAlign = align
            updatePaintAlign()
            invalidate()
        }
    }

    private fun updatePaintAlign() {
        val align = when (lyricAlign) {
            LyricAlign.RIGHT -> Paint.Align.RIGHT
            LyricAlign.CENTER -> Paint.Align.CENTER
        }
        paintCurrentLine.textAlign = align
        paintHighlightedLine.textAlign = align
        paintNextLine.textAlign = align
    }

    fun setLyricTextSize(highlightSp: Float, nextLineSp: Float) {
        highlightTextSizeSp = highlightSp
        nextLineTextSizeSp = nextLineSp
        updatePaintTextSize()
        invalidate()
    }

    private fun updatePaintTextSize() {
        paintCurrentLine.textSize = spToPx(highlightTextSizeSp)
        paintHighlightedLine.textSize = spToPx(highlightTextSizeSp)
        paintNextLine.textSize = spToPx(nextLineTextSizeSp)
        lineSpace = spToPx(nextLineTextSizeSp) * 1.8f
    }

    fun spToPx(sp: Float): Float {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_SP,
            sp,
            context.resources.displayMetrics
        )
    }

    fun setPlayProgress(progressMs: Long) {
        currentProgressMs = progressMs
        store.songLyrics.value?.let { mLyricList ->
            if (mLyricList.isEmpty()) return@let
            val newIndex = mLyricList.indexOfLast { it.startTimeMs <= progressMs }
            currentLineIndex = if (newIndex != -1) newIndex else 0
        }
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val mLyricList = store.songLyrics.value ?: return
        if (currentLineIndex !in mLyricList.indices) return

        val mViewWidth = width.toFloat()
        val mViewHeight = height.toFloat()
        val mTextX = when (lyricAlign) {
            LyricAlign.RIGHT -> mViewWidth
            LyricAlign.CENTER -> mViewWidth / 2
        }

        val line1Y = mViewHeight / 2
        val line2Y = line1Y + lineSpace

        val currentLineData = mLyricList[currentLineIndex]
        val currentLineText = currentLineData.fullContent
        val currentLineWidth = paintCurrentLine.measureText(currentLineText)

        val nextLineIndex = currentLineIndex + 1
        val nextLineText =
            if (nextLineIndex in mLyricList.indices) mLyricList[nextLineIndex].fullContent else ""

        if (currentLineWidth > mViewWidth) {
            val fittingChars = paintCurrentLine.breakText(currentLineText, true, mViewWidth, null)
            val line1 = currentLineText.substring(0, fittingChars)
            val line2 = currentLineText.substring(fittingChars)

            val line1Duration =
                currentLineData.characterArray.take(fittingChars).sumOf { it.durationMs }
            val timeInLine = (currentProgressMs - currentLineData.startTimeMs).coerceAtLeast(0)

            if (timeInLine < line1Duration) {
                val progress = if (line1Duration > 0) timeInLine.toFloat() / line1Duration else 0f
                drawSingleLineHighlight(canvas, line1, progress, line1Y, mTextX)
                drawTruncatedLine(canvas, line2, line2Y, mTextX, false)
            } else {
                val line2Duration = (currentLineData.durationMs - line1Duration).coerceAtLeast(1)
                val timeInLine2 = timeInLine - line1Duration
                val progress = timeInLine2.toFloat() / line2Duration
                drawSingleLineHighlight(canvas, line2, progress, line1Y, mTextX)
                drawTruncatedLine(canvas, nextLineText, line2Y, mTextX, true)
            }
        } else {
            val progress = calcCurrentLineProgress(currentProgressMs, currentLineData)
            drawSingleLineHighlight(canvas, currentLineText, progress, line1Y, mTextX)
            drawTruncatedLine(canvas, nextLineText, line2Y, mTextX, true)
        }
    }

    private fun drawSingleLineHighlight(
        canvas: Canvas,
        text: String,
        progress: Float,
        y: Float,
        x: Float
    ) {
        canvas.drawText(text, x, y, paintCurrentLine)

        val textWidth = paintCurrentLine.measureText(text)
        val highlightWidth = textWidth * progress.coerceIn(0f, 1f)
        val textLeft = when (lyricAlign) {
            LyricAlign.RIGHT -> x - textWidth
            LyricAlign.CENTER -> x - textWidth / 2
        }
        canvas.save()
        val clipPath = Path()
        clipPath.addRect(
            textLeft, y - paintCurrentLine.textSize,
            textLeft + highlightWidth, y + paintCurrentLine.descent(), Path.Direction.CW
        )
        canvas.clipPath(clipPath)

        canvas.drawText(text, x, y, paintHighlightedLine)
        canvas.restore()
    }

    private fun drawTruncatedLine(
        canvas: Canvas,
        text: String,
        y: Float,
        x: Float,
        truncate: Boolean
    ) {
        if (text.isEmpty()) return

        if (truncate && paintNextLine.measureText(text) > width && width > 0) {
            val ellipsis = "..."
            val ellipsisWidth = paintNextLine.measureText(ellipsis)
            val availableWidth = width - ellipsisWidth
            val fittingChars = paintNextLine.breakText(text, true, availableWidth, null)
            val truncatedText = text.substring(0, fittingChars) + ellipsis
            canvas.drawText(truncatedText, x, y, paintNextLine)
        } else {
            canvas.drawText(text, x, y, paintNextLine)
        }
    }

    companion object {
        fun calcCurrentLineProgress(
            currentTimeMillis: Long,
            txLyricLine: TXChorusMusicPlayer.TXLyricLine,
        ): Float {
            val lineDuration = txLyricLine.durationMs
            if (lineDuration <= 0) {
                return if (currentTimeMillis > txLyricLine.startTimeMs) 1f else 0f
            }
            val offsetTime = currentTimeMillis - txLyricLine.startTimeMs
            val progress = offsetTime / lineDuration.toFloat()
            return progress.coerceIn(0f, 1f)
        }
    }
}