package io.trtc.tuikit.atomicx.albumpicker.view.common

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.content.Context
import android.view.Gravity
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.inputmethod.InputMethodManager
import android.widget.FrameLayout
import io.trtc.tuikit.albumpickercore.AlbumPickerPreviewPagerView
import io.trtc.tuikit.albumpickercore.AlbumPickerStore
import io.trtc.tuikit.albumpickercore.util.AlbumPickerUtil

internal class AlbumPickerPreviewViewCommon(
    private val container: FrameLayout,
    private val store: AlbumPickerStore,
    private val showDeleteButton: Boolean = false,
    private val headerView: View,
    private val bottomBarView: View,
) {
    companion object {
        private const val BAR_ANIMATION_DURATION_MS = 250L
        private const val THUMBNAIL_LIST_BOTTOM_MARGIN_DP = 20
    }

    private val context: Context get() = container.context
    private val state get() = store.state
    private val pagerView: AlbumPickerPreviewPagerView

    private var barsVisible = true
    private var barsAnimator: ValueAnimator? = null

    init {
        pagerView =
            AlbumPickerPreviewPagerView(context, store, showDeleteButton = showDeleteButton).apply {
                layoutParams =
                    FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT,
                    )
            }
        container.addView(pagerView)

        headerView.apply {
            layoutParams.let { it as FrameLayout.LayoutParams }.gravity = Gravity.TOP
        }
        container.addView(headerView)

        container.addView(bottomBarView)
        pagerView.setThumbnailListBottomMargin(
            AlbumPickerUtil.dpToPx(context, THUMBNAIL_LIST_BOTTOM_MARGIN_DP)
        )
        setupListeners()
    }

    fun show() {
        showBarsImmediate()
        container.visibility = View.VISIBLE
    }

    fun hide() {
        barsAnimator?.cancel()
        hideSoftKeyboard()
        container.visibility = View.GONE
        val currentSelected = state.selectedMedias.value
        val filtered = currentSelected.filter { !it.isPendingRemoval }
        if (filtered.size != currentSelected.size) {
            store.updateSelectedMedias(filtered)
        }
    }

    private fun setupListeners() {
        pagerView.setOnClickListener {
            hideSoftKeyboard()
            showBars()
        }

        pagerView.setOnLongClickListener {
            hideSoftKeyboard()
            hideBars()
            true
        }
    }

    private fun hideSoftKeyboard() {
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.hideSoftInputFromWindow(container.windowToken, 0)
    }

    private fun showBarsImmediate() {
        barsVisible = true
        headerView.alpha = 1f
        headerView.translationY = 0f
        bottomBarView.alpha = 1f
        bottomBarView.translationY = 0f
        pagerView.animateThumbnailListVisibility(1f, 0f)
    }

    private fun showBars() {
        if (barsVisible) {
            return
        }
        barsVisible = true
        barsAnimator?.cancel()

        val headerH = headerView.height.toFloat()
        val footerH = bottomBarView.height.toFloat()

        barsAnimator = createBarsAnimator(0f, 1f, headerH, footerH)
    }

    private fun hideBars() {
        if (!barsVisible) {
            return
        }
        barsVisible = false
        barsAnimator?.cancel()

        val headerH = headerView.height.toFloat()
        val footerH = bottomBarView.height.toFloat()

        barsAnimator = createBarsAnimator(1f, 0f, headerH, footerH)
    }

    private fun createBarsAnimator(from: Float, to: Float, headerH: Float, footerH: Float):
        ValueAnimator = ValueAnimator.ofFloat(from, to).apply {
            duration = BAR_ANIMATION_DURATION_MS
            interpolator = AccelerateDecelerateInterpolator()
            addUpdateListener { anim ->
                val fraction = anim.animatedValue as Float
                headerView.alpha = fraction
                headerView.translationY = -headerH * (1f - fraction)
                bottomBarView.alpha = fraction
                bottomBarView.translationY = footerH * (1f - fraction)
                pagerView.animateThumbnailListVisibility(fraction, footerH * (1f - fraction))
            }
            addListener(barsAnimatorEndListener)
            start()
        }

    private val barsAnimatorEndListener =
        object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                barsAnimator = null
            }
        }
}
