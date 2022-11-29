package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.waveview.VoiceWaveView

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.os.Handler
import android.os.Parcelable
import android.util.AttributeSet
import android.view.Gravity
import android.view.View
import com.tencent.qcloud.tuikit.tuichat.R
import java.util.*

class VoiceWaveView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = 0
) : View(context, attrs, defStyle) {

    var bodyWaveList = LinkedList<Int>()
        private set
    var headerWaveList = LinkedList<Int>()
        private set
    var footerWaveList = LinkedList<Int>()
        private set

    private var waveList = LinkedList<Int>()

    /**
     * 线间距 px
     */
    var lineSpace: Float = 10f
    /**
     * 线宽 px
     */
    var lineWidth: Float = 20f

    /**
     * 动画持续时间
     */
    var duration: Long = Long.MAX_VALUE
    /**
     * 线颜色
     */
    var lineColor: Int = Color.BLUE
    var paintLine: Paint? = null
    var paintPathLine: Paint? = null

    private var valueAnimator = ValueAnimator.ofFloat(0f, 1f)

    private var valueAnimatorOffset: Float = 1f

    private var valHandler = Handler()
    val linePath = Path()

    @Volatile
    var isStart: Boolean = false
        private set

    /**
     * 跳动模式
     */
    var waveMode: WaveMode = WaveMode.UP_DOWN

    /**
     * 线条样式
     */
    var lineType: LineType = LineType.BAR_CHART

    /**
     * 显示位置
     */
    var showGravity: Int = Gravity.LEFT or Gravity.BOTTOM

    private var runnable: Runnable? = null


    init {
        attrs?.let {
            val typedArray = context.theme.obtainStyledAttributes(
                attrs,
                R.styleable.VoiceWaveView, 0, 0
            )

            lineWidth = typedArray.getDimension(R.styleable.VoiceWaveView_lineWidth, 5f)
            lineSpace = typedArray.getDimension(R.styleable.VoiceWaveView_lineSpace, 5f)
            duration = typedArray.getInt(R.styleable.VoiceWaveView_duration, 200).toLong()
            showGravity = typedArray.getInt(R.styleable.VoiceWaveView_android_gravity, Gravity.LEFT or Gravity.BOTTOM)
            lineColor = typedArray.getInt(R.styleable.VoiceWaveView_lineColor, Color.BLUE)
            val mode = typedArray.getInt(R.styleable.VoiceWaveView_waveMode, 0)
            when (mode) {
                0 -> waveMode = WaveMode.UP_DOWN
                1 -> waveMode = WaveMode.LEFT_RIGHT
            }

            val lType = typedArray.getInt(R.styleable.VoiceWaveView_lineType, 0)
            when (lType) {
                0 -> lineType = LineType.BAR_CHART
                1 -> lineType = LineType.LINE_GRAPH
            }

            typedArray.recycle()
        }

        paintLine = Paint()
        paintLine?.isAntiAlias = true
        paintLine?.strokeCap = Paint.Cap.ROUND

        paintPathLine = Paint()
        paintPathLine?.isAntiAlias = true
        paintPathLine?.setStyle(Paint.Style.STROKE);
    }

    /**
     * 线的高度 0,100 百分数
     */
    fun addBody(num: Int) {
        checkNum(num)
        bodyWaveList.add(num)
    }

    /**
     * 头部线的高度 0,100 百分数
     */
    fun addHeader(num: Int) {
        checkNum(num)
        headerWaveList.add(num)
    }

    /**
     * 尾部线的高度 0,100 百分数
     */
    fun addFooter(num: Int) {
        checkNum(num)
        footerWaveList.add(num)
    }

    private fun checkNum(num: Int) {
        if (num < 0 || num > 100) {
            throw Exception("num must between 0 and 100")
        }
    }

    /**
     * 开始
     */
    fun start() {
        if (isStart) {
            return
        }
        isStart = true
        if (waveMode == WaveMode.UP_DOWN) {
            valueAnimator.duration = duration
            valueAnimator.repeatMode = ValueAnimator.REVERSE
            valueAnimator.repeatCount = ValueAnimator.INFINITE
            valueAnimator.addUpdateListener {
                valueAnimatorOffset = it.getAnimatedValue() as Float
                invalidate()
            }
            valueAnimator.start()
        } else if (waveMode == WaveMode.LEFT_RIGHT) {
            runnable = object : Runnable {
                override fun run() {
                    val last = bodyWaveList.pollLast()
                    bodyWaveList.addFirst(last)
                    invalidate()
                    valHandler.postDelayed(this, duration);
                }
            }
            valHandler.post(runnable as Runnable)
        } else {

        }
    }

    override fun onDraw(canvas: Canvas?) {
        super.onDraw(canvas)

        waveList.clear()
        waveList.addAll(headerWaveList)
        waveList.addAll(bodyWaveList)
        waveList.addAll(footerWaveList)

        linePath.reset()
        paintPathLine?.strokeWidth = lineWidth
        paintPathLine?.color = lineColor

        paintLine?.strokeWidth = lineWidth
        paintLine?.color = lineColor
        for (i in waveList.indices) {
            var startX = 0f
            var startY = 0f
            var endX = 0f
            var endY = 0f

            var offset = 1f
            if (i >= headerWaveList.size && i < (waveList.size - footerWaveList.size)) {//模式1 ，排除掉头尾
                offset = valueAnimatorOffset
            }

            val lineHeight = waveList[i] / 100.0 * measuredHeight * offset

            val absoluteGravity = Gravity.getAbsoluteGravity(showGravity, layoutDirection);

            when (absoluteGravity and Gravity.HORIZONTAL_GRAVITY_MASK) {
                Gravity.CENTER_HORIZONTAL -> {
                    val lineSize = waveList.size
                    val allLineWidth = lineSize * (lineSpace + lineWidth)
                    if (allLineWidth < measuredWidth) {
                        startX = (i * (lineSpace + lineWidth) + lineWidth / 2) + ((measuredWidth - allLineWidth) / 2)
                    } else {
                        startX = i * (lineSpace + lineWidth) + lineWidth / 2
                    }
                    endX = startX
                }

                Gravity.RIGHT -> {
                    val lineSize = waveList.size
                    val allLineWidth = lineSize * (lineSpace + lineWidth)
                    if (allLineWidth < measuredWidth) {
                        startX = (i * (lineSpace + lineWidth) + lineWidth / 2) + (measuredWidth - allLineWidth)
                    } else {
                        startX = i * (lineSpace + lineWidth) + lineWidth / 2
                    }
                    endX = startX
                }

                Gravity.LEFT -> {
                    startX = i * (lineSpace + lineWidth) + lineWidth / 2
                    endX = startX
                }
            }


            when (showGravity and Gravity.VERTICAL_GRAVITY_MASK) {
                Gravity.TOP -> {
                    startY = 0f
                    endY = lineHeight.toFloat()
                }

                Gravity.CENTER_VERTICAL -> {
                    startY = (measuredHeight / 2 - lineHeight / 2).toFloat()
                    endY = (measuredHeight / 2 + lineHeight / 2).toFloat()
                }

                Gravity.BOTTOM -> {
                    startY = (measuredHeight - lineHeight).toFloat()
                    endY = measuredHeight.toFloat()
                }

            }
            if (lineType == LineType.BAR_CHART) {
                paintLine?.let {
                    canvas?.drawLine(
                        startX,
                        startY,
                        endX,
                        endY,
                        it
                    )
                }
            }
            if (lineType == LineType.LINE_GRAPH) {
                if (i == 0) {
                    linePath.moveTo(startX, startY)
                    val pathEndX = endX + (lineWidth / 2) + (lineSpace / 2)
                    linePath.lineTo(pathEndX, endY)
                } else {
                    linePath.lineTo(startX, startY)
                    val pathEndX = endX + (lineWidth / 2) + (lineSpace / 2)
                    linePath.lineTo(pathEndX, endY)
                }
            }
        }
        if (lineType == LineType.LINE_GRAPH) {
            paintPathLine?.let { canvas?.drawPath(linePath, it) }
        }
    }

    /**
     * 停止 onDestroy call
     */
    fun stop() {
        isStart = false
        if (runnable != null) {
            valHandler.removeCallbacks(runnable!!)
        }
        valueAnimator.cancel()
        waveList.clear()
        bodyWaveList.clear()
        headerWaveList.clear()
        footerWaveList.clear()
        linePath.reset()
    }

    override fun onSaveInstanceState(): Parcelable? {
        //TODO onSaveInstanceState
        return super.onSaveInstanceState()
    }

    override fun onRestoreInstanceState(state: Parcelable?) {
        //TODO onRestoreInstanceState
        super.onRestoreInstanceState(state)
    }
}