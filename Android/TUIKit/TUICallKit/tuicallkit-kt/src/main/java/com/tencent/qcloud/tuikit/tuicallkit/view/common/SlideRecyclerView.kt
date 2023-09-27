package com.tencent.qcloud.tuikit.tuicallkit.view.common

import android.content.Context
import android.graphics.Rect
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.VelocityTracker
import android.view.View
import android.view.ViewConfiguration
import android.view.ViewGroup
import android.widget.Scroller
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import kotlin.math.abs

class SlideRecyclerView @JvmOverloads constructor(context: Context?, attrs: AttributeSet? = null, defStyle: Int = 0) :
    RecyclerView(context!!, attrs, defStyle) {
    private var flingView: ViewGroup? = null
    private var velocityTracker: VelocityTracker? = null
    private val scroller: Scroller
    private var touchFrame: Rect? = null
    private var lastX: Float = 0f
    private var firstX: Float = 0f
    private var firstY: Float = 0f
    private val touchSlop: Int
    private var isSlide = false
    private var position: Int = 0
    private var menuViewWidth: Int = 0
    private var disableRecyclerViewSlide: Boolean = false

    init {
        touchSlop = ViewConfiguration.get(context).scaledTouchSlop
        scroller = Scroller(context)
    }

    fun disableRecyclerViewSlide(disable: Boolean) {
        disableRecyclerViewSlide = disable
    }

    override fun onInterceptTouchEvent(e: MotionEvent): Boolean {
        val x = e.x.toInt()
        val y = e.y.toInt()
        obtainVelocity(e)
        when (e.action) {
            MotionEvent.ACTION_DOWN -> {
                if (!scroller.isFinished) {
                    scroller.abortAnimation()
                }
                run {
                    lastX = x.toFloat()
                    firstX = lastX
                }
                firstY = y.toFloat()
                position = pointToPosition(x, y)
                if (position != INVALID_POSITION) {
                    val view: View? = flingView
                    flingView = getChildAt(
                        position - (layoutManager as LinearLayoutManager).findFirstVisibleItemPosition()
                    ) as ViewGroup
                    if (view != null && flingView !== view && view.scrollX != 0) {
                        view.scrollTo(0, 0)
                    }
                    menuViewWidth = if (flingView?.childCount == 2) {
                        flingView?.getChildAt(1)?.width ?: INVALID_CHILD_WIDTH
                    } else {
                        INVALID_CHILD_WIDTH
                    }
                }
            }

            MotionEvent.ACTION_MOVE -> {
                velocityTracker?.computeCurrentVelocity(1000)
                val xVelocity = (if (velocityTracker?.xVelocity != null) velocityTracker?.xVelocity else 0f) as Float
                val yVelocity = (if (velocityTracker?.yVelocity != null) velocityTracker?.yVelocity else 0f) as Float

                val topView = (layoutManager as LinearLayoutManager?)?.findViewByPosition(0)
                if (topView === flingView) {
                    isSlide = false
                } else if (abs(xVelocity) > SNAP_VELOCITY && abs(xVelocity) > abs(yVelocity)
                    || abs(x - firstX) >= touchSlop
                    && abs(x - firstX) > abs(y - firstY)
                ) {
                    isSlide = true
                    return true
                }
            }

            MotionEvent.ACTION_UP -> releaseVelocity()
            else -> {}
        }
        return super.onInterceptTouchEvent(e)
    }

    override fun onTouchEvent(e: MotionEvent): Boolean {
        if (isSlide && position != INVALID_POSITION) {
            val x = e.x
            obtainVelocity(e)
            when (e.action) {
                MotionEvent.ACTION_DOWN -> {}
                MotionEvent.ACTION_MOVE ->
                    flingView?.let {
                        if (menuViewWidth != INVALID_CHILD_WIDTH) {
                            val dx = Math.abs(it.scrollX + (lastX - x))
                            if (dx <= menuViewWidth && dx > 0) {
                                if (menuViewWidth != INVALID_CHILD_WIDTH) {
                                    val scrollX = it.scrollX
                                    velocityTracker?.computeCurrentVelocity(1000)
                                    if (isRTL) {
                                        openRightExtendView(scrollX)
                                    } else {
                                        openLeftExtendView(scrollX)
                                    }
                                    invalidate()
                                }
                                menuViewWidth = INVALID_CHILD_WIDTH
                                isSlide = false
                                position = INVALID_POSITION
                            }
                            lastX = x
                        }
                    }
                MotionEvent.ACTION_UP -> releaseVelocity()
                else -> {}
            }
            return true
        } else {
            closeMenu()
            releaseVelocity()
        }
        return super.onTouchEvent(e)
    }

    private fun openRightExtendView(scrollX: Int) {
        velocityTracker?.let {
            if (it.xVelocity >= SNAP_VELOCITY) {
                startScroll(scrollX, scrollX - menuViewWidth)
            } else if (it.xVelocity < -SNAP_VELOCITY) {
                startScroll(scrollX, -scrollX)
            } else if (scrollX >= menuViewWidth / 2) {
                startScroll(scrollX, scrollX - menuViewWidth)
            } else {
                startScroll(scrollX, -scrollX)
            }
        }
    }

    private fun openLeftExtendView(scrollX: Int) {
        velocityTracker?.let {
            if (it.xVelocity < -SNAP_VELOCITY) {
                startScroll(scrollX, menuViewWidth - scrollX)
            } else if (it.xVelocity >= SNAP_VELOCITY) {
                startScroll(scrollX, -scrollX)
            } else if (scrollX >= menuViewWidth / 2) {
                startScroll(scrollX, menuViewWidth - scrollX)
            } else {
                startScroll(scrollX, -scrollX)
            }
        }
    }

    private fun startScroll(startX: Int, dx: Int) {
        scroller.startScroll(startX, 0, dx, 0)
    }

    private fun releaseVelocity() {
        if (velocityTracker != null) {
            velocityTracker?.clear()
            velocityTracker?.recycle()
            velocityTracker = null
        }
    }

    private fun obtainVelocity(event: MotionEvent) {
        if (velocityTracker == null) {
            velocityTracker = VelocityTracker.obtain()
        }
        velocityTracker?.addMovement(event)
    }

    fun pointToPosition(x: Int, y: Int): Int {
        val firstPosition = (layoutManager as LinearLayoutManager?)?.findFirstVisibleItemPosition()
        firstPosition?.let {
            var frame = touchFrame
            if (frame == null) {
                touchFrame = Rect()
                frame = touchFrame
            }
            val count = childCount
            for (i in count - 1 downTo 0) {
                val child = getChildAt(i)
                if (child.visibility == View.VISIBLE) {
                    child.getHitRect(frame)
                    frame?.let {
                        if (it.contains(x, y)) {
                            return firstPosition + i
                        }
                    }
                }
            }
        }
        return INVALID_POSITION
    }

    override fun computeScroll() {
        if (scroller.computeScrollOffset()) {
            if (disableRecyclerViewSlide) {
                flingView?.scrollTo(0, 0)
            } else {
                flingView?.scrollTo(scroller.currX, scroller.currY)
            }
            invalidate()
        }
    }

    fun closeMenu() {
        if (flingView != null && flingView?.scrollX != 0) {
            flingView?.scrollTo(0, 0)
        }
    }

    private val isRTL: Boolean
        private get() {
            val configuration = context.resources.configuration
            val layoutDirection = configuration.layoutDirection
            return layoutDirection == View.LAYOUT_DIRECTION_RTL
        }

    companion object {
        private const val TAG = "SlideRecyclerView"
        private const val INVALID_POSITION = -1
        private const val INVALID_CHILD_WIDTH = -1
        private const val SNAP_VELOCITY = 600
    }
}