package com.tencent.qcloud.tuikit.tuicallkit.view.component.floatwindow

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.RectF
import android.graphics.drawable.BitmapDrawable
import android.util.AttributeSet
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import com.tencent.qcloud.tuikit.tuicallkit.R

class RoundShadowLayout(context: Context, attrs: AttributeSet?) : RelativeLayout(context, attrs) {
    private val radiusArray = FloatArray(8)

    private var shadowPaint: Paint = Paint()
    private var shadowRect: RectF = RectF()
    private var shadowPath: Path = Path()
    private var shadowRadius = 15f
    private var shadowColor = 0
    private var shadowX = 0f
    private var shadowY = 0f

    private var roundRadius = 32f
    private var roundPaint: Paint = Paint()
    private var roundRect: RectF = RectF()
    private var roundPath: Path = Path()

    constructor(context: Context) : this(context, null) {}

    init {
        shadowColor = ContextCompat.getColor(context, R.color.tuicallkit_color_bg_float_view)
        for (i in radiusArray.indices) {
            radiusArray[i] = roundRadius
        }
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        var width = 0
        var height = 0
        for (i in 0 until childCount) {
            val child = getChildAt(i)
            val lp = child.layoutParams
            val childWidthSpec = getChildMeasureSpec(widthMeasureSpec - shadowRadius.toInt() * 2, 0, lp.width)
            val childHeightSpec = getChildMeasureSpec(heightMeasureSpec - shadowRadius.toInt() * 2, 0, lp.height)
            measureChild(child, childWidthSpec, childHeightSpec)

            val mlp = child.layoutParams as MarginLayoutParams
            val childWidth = child.measuredWidth + mlp.leftMargin + mlp.rightMargin
            val childHeight = child.measuredHeight + mlp.topMargin + mlp.bottomMargin
            width = width.coerceAtLeast(childWidth)
            height = height.coerceAtLeast(childHeight)
        }
        setMeasuredDimension(
            width + paddingLeft + paddingRight + shadowRadius.toInt() * 2,
            height + paddingTop + paddingBottom + shadowRadius.toInt() * 2
        )
    }

    override fun onSizeChanged(width: Int, height: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(width, height, oldw, oldh)
        if (width > 0 && height > 0 && shadowRadius > 0) {
            setBackgroundCompat(width, height)
        }
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        for (i in 0 until childCount) {
            val child = getChildAt(i)
            val lp = child.layoutParams as MarginLayoutParams
            val lc = shadowRadius.toInt() + lp.leftMargin + paddingLeft
            val tc = shadowRadius.toInt() + lp.topMargin + paddingTop
            val rc = lc + child.measuredWidth
            val bc = tc + child.measuredHeight
            child.layout(lc, tc, rc, bc)
        }
    }

    override fun dispatchDraw(canvas: Canvas) {
        roundRect[shadowRadius, shadowRadius, width - shadowRadius] = height - shadowRadius
        canvas.saveLayer(roundRect, null, Canvas.ALL_SAVE_FLAG)
        super.dispatchDraw(canvas)
        roundPath.reset()
        roundPath.addRoundRect(roundRect, radiusArray, Path.Direction.CW)

        clipRound(canvas)
        canvas.restore()
    }

    private fun clipRound(canvas: Canvas) {
        roundPaint.color = Color.WHITE
        roundPaint.isAntiAlias = true
        roundPaint.style = Paint.Style.FILL
        roundPaint.xfermode = PorterDuffXfermode(PorterDuff.Mode.DST_OUT)
        val path = Path()
        path.addRect(0f, 0f, width.toFloat(), height.toFloat(), Path.Direction.CW)
        path.op(roundPath, Path.Op.DIFFERENCE)
        canvas.drawPath(path, roundPaint)
    }

    private fun setBackgroundCompat(width: Int, height: Int) {
        val bitmap: Bitmap = createShadowBitmap(width, height, shadowRadius, shadowX, shadowY, shadowColor)
        val drawable = BitmapDrawable(resources, bitmap)
        background = drawable
    }

    private fun createShadowBitmap(
        shadowWidth: Int, shadowHeight: Int, shadowRadius: Float, dx: Float, dy: Float, shadowColor: Int
    ): Bitmap {
        val output: Bitmap = Bitmap.createBitmap(shadowWidth, shadowHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        shadowRect[shadowRadius, shadowRadius, shadowWidth - shadowRadius] = shadowHeight - shadowRadius
        shadowRect.top += dy
        shadowRect.bottom -= dy
        shadowRect.left += dx
        shadowRect.right -= dx
        shadowPaint.isAntiAlias = true
        shadowPaint.style = Paint.Style.FILL
        shadowPaint.color = shadowColor
        if (!isInEditMode) {
            shadowPaint.setShadowLayer(shadowRadius, dx, dy, shadowColor)
        }
        shadowPath.reset()
        shadowPath.addRoundRect(shadowRect, radiusArray, Path.Direction.CW)
        canvas.drawPath(shadowPath, shadowPaint)
        return output
    }
}