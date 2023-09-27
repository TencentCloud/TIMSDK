package com.tencent.qcloud.tuikit.tuicallkit.view.common

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PaintFlagsDrawFilter
import android.graphics.Path
import android.graphics.RectF
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatImageView
import com.tencent.qcloud.tuikit.tuicallkit.R

open class RoundCornerImageView : AppCompatImageView {
    private var leftTopRadius = 0
    private var rightTopRadius = 0
    private var rightBottomRadius = 0
    private var leftBottomRadius = 0
    private val path = Path()
    private val rectF = RectF()
    private var radius = 0
    private val aliasFilter = PaintFlagsDrawFilter(
        0,
        Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG
    )

    constructor(context: Context) : super(context) {
        init(context, null)
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        init(context, attrs)
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(context, attrs, defStyleAttr) {}

    private fun init(context: Context, attrs: AttributeSet?) {
        setLayerType(LAYER_TYPE_HARDWARE, null)
        val defaultRadius = 0
        if (attrs != null) {
            val array = context.obtainStyledAttributes(attrs, R.styleable.RoundCornerImageView)
            radius = array.getDimensionPixelOffset(R.styleable.RoundCornerImageView_corner_radius, defaultRadius)
            leftTopRadius =
                array.getDimensionPixelOffset(R.styleable.RoundCornerImageView_left_top_radius, defaultRadius)
            rightTopRadius =
                array.getDimensionPixelOffset(R.styleable.RoundCornerImageView_right_top_radius, defaultRadius)
            rightBottomRadius =
                array.getDimensionPixelOffset(R.styleable.RoundCornerImageView_right_bottom_radius, defaultRadius)
            leftBottomRadius =
                array.getDimensionPixelOffset(R.styleable.RoundCornerImageView_left_bottom_radius, defaultRadius)
            array.recycle()
        }
        if (defaultRadius == leftTopRadius) {
            leftTopRadius = radius
        }
        if (defaultRadius == rightTopRadius) {
            rightTopRadius = radius
        }
        if (defaultRadius == rightBottomRadius) {
            rightBottomRadius = radius
        }
        if (defaultRadius == leftBottomRadius) {
            leftBottomRadius = radius
        }
    }

    fun setRadius(radius: Int) {
        this.radius = radius
        leftBottomRadius = radius
        rightBottomRadius = radius
        rightTopRadius = radius
        leftTopRadius = radius
    }

    fun getRadius(): Int {
        return radius
    }

    override fun onDraw(canvas: Canvas) {
        path.reset()
        canvas.drawFilter = aliasFilter
        rectF[0f, 0f, measuredWidth.toFloat()] = measuredHeight.toFloat()
        // left-top -> right-top -> right-bottom -> left-bottom
        // left-top -> right-top -> right-bottom -> left-bottom
        val radius = floatArrayOf(
            leftTopRadius.toFloat(),
            leftTopRadius.toFloat(),
            rightTopRadius.toFloat(),
            rightTopRadius.toFloat(),
            rightBottomRadius.toFloat(),
            rightBottomRadius.toFloat(),
            leftBottomRadius.toFloat(),
            leftBottomRadius.toFloat()
        )
        path.addRoundRect(rectF, radius, Path.Direction.CW)
        canvas.clipPath(path)
        super.onDraw(canvas)
    }
}