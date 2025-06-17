package com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.multicall

import android.content.Context
import android.util.AttributeSet
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.animation.AlphaAnimation
import android.view.animation.Animation
import android.widget.ImageView
import android.widget.LinearLayout
import androidx.constraintlayout.utils.widget.ImageFilterView
import com.tencent.qcloud.tuikit.tuicallkit.R

class MultiCallLoadingView(context: Context, attrs: AttributeSet?) : LinearLayout(context, attrs) {
    private var leftDot: ImageView
    private var centerDot: ImageView
    private var rightDot: ImageView

    private var isLoading = false

    init {
        this.orientation = HORIZONTAL
        this.gravity = Gravity.CENTER
        this.layoutParams = LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        leftDot = createImageView()
        centerDot = createImageView()
        rightDot = createImageView()
        addView(leftDot)
        addView(centerDot)
        addView(rightDot)
    }

    private fun createImageView(): ImageView {
        val lp = LayoutParams(24, 24)
        lp.marginEnd = 24
        val imageView = ImageFilterView(context)
        imageView.layoutParams = lp
        imageView.roundPercent = 1f
        imageView.setBackgroundColor(resources.getColor(R.color.tuicallkit_color_white))
        return imageView
    }

    private fun createAnimation(startAlpha: Float, endAlpha: Float): Animation {
        val animation = AlphaAnimation(startAlpha, endAlpha)
        animation.duration = DURATION
        return animation
    }

    private fun startAnimation1() {
        startAnimation(leftDot, 1.0f, 0.2f)
        centerDot.startAnimation(createAnimation(0.6f, 1.0f))
        rightDot.startAnimation(createAnimation(0.2f, 0.6f))
    }

    private fun startAnimation2() {
        leftDot.startAnimation(createAnimation(0.2f, 0.2f))
        startAnimation(centerDot, 1.0f, 0.6f)
        rightDot.startAnimation(createAnimation(0.6f, 1.0f))
    }

    private fun startAnimation3() {
        leftDot.startAnimation(createAnimation(0.2f, 0.2f))
        centerDot.startAnimation(createAnimation(0.6f, 0.6f))
        startAnimation(rightDot, 1.0f, 0.6f)
    }

    private fun startAnimation4() {
        startAnimation(leftDot, 0.2f, 1.0f)
        centerDot.startAnimation(createAnimation(0.6f, 0.6f))
        rightDot.startAnimation(createAnimation(0.6f, 0.2f))
    }

    private fun startAnimation(view: View?, fromAlpha: Float, toAlpha: Float) {
        val animation = createAnimation(fromAlpha, toAlpha)
        animation.setAnimationListener(object : Animation.AnimationListener {
            override fun onAnimationStart(animation: Animation) {}
            override fun onAnimationEnd(animation: Animation) {
                if (!isLoading) {
                    return
                }
                when {
                    view === leftDot && fromAlpha > toAlpha -> startAnimation2()
                    view === leftDot && fromAlpha < toAlpha -> startAnimation1()
                    view === centerDot -> startAnimation3()
                    view === rightDot -> startAnimation4()
                }
            }

            override fun onAnimationRepeat(animation: Animation) {}
        })
        view!!.startAnimation(animation)
    }

    fun startLoading() {
        isLoading = true
        startAnimation1()
    }

    fun stopLoading() {
        isLoading = false
        leftDot.clearAnimation()
        centerDot.clearAnimation()
        rightDot.clearAnimation()
    }

    companion object {
        private const val DURATION: Long = 500
    }
}