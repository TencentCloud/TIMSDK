package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout

import android.content.Context
import android.view.View
import android.widget.RelativeLayout
import com.tencent.qcloud.tuicore.util.ScreenUtil

open class GroupCallFlowLayout(context: Context) : RelativeLayout(context) {
    companion object {
        const val TAG = "GroupCallFlowLayout"
        const val DEFAULT_INDEX: Int = -99
    }

    public var showLargeViewIndex = DEFAULT_INDEX
    private var screenWidth: Int = 0
    private val changeList = ArrayList<View>()

    init {
        screenWidth = ScreenUtil.getScreenWidth(context)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.makeMeasureSpec(screenWidth, MeasureSpec.EXACTLY)
        var height = MeasureSpec.makeMeasureSpec(screenWidth + screenWidth / 3, MeasureSpec.EXACTLY)
        if (showLargeViewIndex < 0) {
            height = if (childCount <= 2) {
                MeasureSpec.makeMeasureSpec(screenWidth / 2 + getTopMargin(childCount), MeasureSpec.EXACTLY)
            } else {
                MeasureSpec.makeMeasureSpec(screenWidth, MeasureSpec.EXACTLY)
            }
        }
        setMeasuredDimension(width, height)

        for (i in 0 until childCount) {
            val child: View = getChildAt(i)
            val childSize = MeasureSpec.makeMeasureSpec(getMeasureSize(i, childCount), MeasureSpec.EXACTLY)
            measureChild(child, childSize, childSize)
        }
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val params = getLocation(childCount)

        if (showLargeViewIndex > 0 && childCount <= 4) {
            for (i in 0 until childCount) {
                val child = getChildAt(i)
                if (i != showLargeViewIndex) {
                    changeList.add(child)
                } else {
                    changeList.add(0, child)
                }
            }

            for (i in 0 until changeList.size) {
                val view = changeList[i]
                val pos = params[i]
                view.layout(pos.x, pos.y, view.measuredWidth + pos.x, view.measuredHeight + pos.y)
            }
            changeList.clear()
            return
        }

        val topMargin = getTopMargin(childCount)

        for (i in 0 until childCount) {
            val child = getChildAt(i)
            val pos = params[i]
            child.layout(
                pos.x, pos.y + topMargin,
                child.measuredWidth + pos.x, child.measuredHeight + pos.y + topMargin
            )
        }
    }

    public fun setLargeViewIndex(index: Int) {
        showLargeViewIndex = if (index == showLargeViewIndex) {
            DEFAULT_INDEX
        } else {
            index
        }
        requestLayout()
    }

    private fun getMeasureSize(index: Int, count: Int): Int {
        return when {
            count <= 4 && showLargeViewIndex == index -> screenWidth
            count <= 4 && showLargeViewIndex < 0 -> screenWidth / 2
            count > 4 && showLargeViewIndex == index -> screenWidth / 3 * 2
            else -> screenWidth / 3
        }
    }

    private fun getTopMargin(count: Int): Int {
        return if (count <= 2 && showLargeViewIndex < 0) {
            screenWidth / 4
        } else {
            0
        }
    }

    private fun getLocation(count: Int): List<Position> {
        val width = screenWidth / 3
        val height = screenWidth / 3

        var currentIndex = 0
        var lastFrame = 0
        var segment: SegmentStyle = getSegment(count, currentIndex)

        val list = ArrayList<Position>()
        while (currentIndex < count) {
            when (segment) {
                SegmentStyle.FULL_WIDTH -> {
                    list.add(fullWidth(0, lastFrame, width, height))
                    lastFrame += height * 3
                    currentIndex += 1
                }
                SegmentStyle.FIFTY_FIFTY -> {
                    list.addAll(fiftyFifty(0, lastFrame, width, height))
                    lastFrame += height * 3
                    currentIndex += 4
                }
                SegmentStyle.THREE_ONE_THIRDS -> {
                    list.addAll(threeOneThird(0, lastFrame, width, height))
                    lastFrame += height
                    currentIndex += 3
                }
                SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER -> {
                    list.addAll(twoThirdsOneThirdCenter(0, lastFrame, width, height))
                    lastFrame += height * 2
                    currentIndex += 3
                }
                SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT -> {
                    list.addAll(twoThirdsOneThirdRight(0, lastFrame, width, height))
                    lastFrame += height * 2
                    currentIndex += 3
                }
                SegmentStyle.ONE_THIRD_TWO_THIRDS -> {
                    list.addAll(oneThirdTwoThirds(0, lastFrame, width, height))
                    lastFrame += height * 2
                    currentIndex += 3
                }
                SegmentStyle.ONE_THIRD -> {
                    list.addAll(oneThird(0, lastFrame, width, height))
                    lastFrame += height * 3
                    currentIndex += 3
                }
                else -> {}
            }
            segment = getSegment(count, currentIndex)
        }
        return list
    }

    private fun oneThirdTwoThirds(x: Int, y: Int, width: Int, height: Int): List<Position> {
        val list = ArrayList<Position>()
        list.add(Position(0, y, width * 2, height * 2))
        list.add(Position(width * 2, y, width, height))
        list.add(Position(width * 2, y + height, width, height))
        return list
    }

    private fun threeOneThird(x: Int, y: Int, width: Int, height: Int): List<Position> {
        val list = ArrayList<Position>()
        list.add(Position(0, y, width, height))
        list.add(Position(width, y, width, height))
        list.add(Position(width * 2, y, width, height))
        return list
    }

    private fun fullWidth(x: Int, y: Int, width: Int, height: Int): Position = Position(0, y, width * 3, height * 3)

    private fun twoThirdsOneThirdCenter(x: Int, y: Int, width: Int, height: Int): List<Position> {
        val list = ArrayList<Position>()
        list.add(Position(0, y, width, height))
        list.add(Position(width, y, width * 2, height * 2))
        list.add(Position(0, y + width, width, height))
        return list
    }

    private fun twoThirdsOneThirdRight(x: Int, y: Int, width: Int, height: Int): List<Position> {
        val list = ArrayList<Position>()
        list.add(Position(0, y, width, height))
        list.add(Position(0, y + width, width, height))
        list.add(Position(width, y, width * 2, height * 2))
        return list
    }

    private fun fiftyFifty(x: Int, y: Int, childWidth: Int, childHeight: Int): List<Position> {
        val width = childWidth * 3 / 2
        val height = childHeight * 3 / 2

        val list = ArrayList<Position>()
        list.add(Position(0, y, width, height))
        list.add(Position(width, y, width, height))
        list.add(Position(0, y + width, width, height))
        list.add(Position(width, y + width, width, height))
        return list
    }

    private fun oneThird(x: Int, y: Int, childWidth: Int, childHeight: Int): List<Position> {
        val width = childWidth * 3 / 2
        val height = childHeight * 3 / 2

        val list = ArrayList<Position>()
        list.add(Position(0, y, width, height))
        list.add(Position(width, y, width, height))
        list.add(Position(width / 2, y + height, width, height))
        return list
    }

    private fun getSegment(count: Int, currentIndex: Int): SegmentStyle {
        var segment = SegmentStyle.THREE_ONE_THIRDS
        if (currentIndex == 0) {
            when {
                count == 1 -> segment = SegmentStyle.FULL_WIDTH
                count == 2 || count == 4 -> segment =
                    if (showLargeViewIndex >= 0) SegmentStyle.FULL_WIDTH else SegmentStyle.FIFTY_FIFTY
                count == 3 -> segment =
                    if (showLargeViewIndex >= 0) SegmentStyle.FULL_WIDTH else SegmentStyle.ONE_THIRD
                showLargeViewIndex == 0 -> segment = SegmentStyle.ONE_THIRD_TWO_THIRDS
                showLargeViewIndex == 1 -> segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER
                showLargeViewIndex == 2 -> segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT
            }
            return segment
        }
        when (count - currentIndex) {
            1 -> segment = when {
                count == 3 -> SegmentStyle.ONE_THIRD
                count > 4 && showLargeViewIndex == count - 1 -> SegmentStyle.ONE_THIRD_TWO_THIRDS
                count == 4 -> SegmentStyle.FIFTY_FIFTY
                count > 4 && showLargeViewIndex == currentIndex -> SegmentStyle.ONE_THIRD_TWO_THIRDS
                count > 4 && showLargeViewIndex == currentIndex + 1 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER
                count > 4 && showLargeViewIndex == currentIndex + 2 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT
                else -> SegmentStyle.THREE_ONE_THIRDS
            }
            2 -> segment = when {
                count == 4 -> SegmentStyle.FIFTY_FIFTY
                count > 4 && showLargeViewIndex == currentIndex -> SegmentStyle.ONE_THIRD_TWO_THIRDS
                count > 4 && showLargeViewIndex == currentIndex + 1 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER
                count > 4 && showLargeViewIndex == currentIndex + 2 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT
                else -> SegmentStyle.THREE_ONE_THIRDS
            }
            else -> segment =
                when {
                    count > 4 && showLargeViewIndex == currentIndex -> SegmentStyle.ONE_THIRD_TWO_THIRDS
                    count > 4 && showLargeViewIndex == currentIndex + 1 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER
                    count > 4 && showLargeViewIndex == currentIndex + 2 -> SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT
                    else -> SegmentStyle.THREE_ONE_THIRDS
                }
        }
        return segment
    }

    class Position(xx: Int, yy: Int, wWidth: Int, hHeight: Int) {
        var x = 0
        var y = 0
        var width = 0
        var height = 0

        init {
            x = xx
            y = yy
            width = wWidth
            height = hHeight
        }
    }

    enum class SegmentStyle {
        FULL_WIDTH,
        ONE_THIRD,
        FIFTY_FIFTY,
        THREE_ONE_THIRDS,
        ONE_THIRD_TWO_THIRDS,
        TWO_THIRDS_ONE_THIRD_CENTER,
        TWO_THIRDS_ONE_THIRD_RIGHT
    }
}