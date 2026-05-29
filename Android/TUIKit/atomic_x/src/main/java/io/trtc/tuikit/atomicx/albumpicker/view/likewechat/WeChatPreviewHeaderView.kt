package io.trtc.tuikit.atomicx.albumpicker.view.likewechat

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import io.trtc.tuikit.albumpickercore.AlbumPickerStore
import io.trtc.tuikit.albumpickercore.util.AlbumPickerUtil
import io.trtc.tuikit.atomicx.albumpicker.R
import io.trtc.tuikit.atomicx.albumpicker.util.AlbumPickerWindowHelper
import io.trtc.tuikit.atomicx.albumpicker.view.common.AlbumPickerThemeInternal
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch

internal class WeChatPreviewHeaderView(
    context: Context,
    private val store: AlbumPickerStore,
    private val onDismissListener: OnDismissListener,
) : FrameLayout(context) {
    fun interface OnDismissListener {
        fun onDismiss()
    }

    companion object {
        private const val HEADER_HEIGHT_DP = 44
        private const val BACK_ICON_SIZE_DP = 24
        private const val INDICATOR_SIZE_DP = 24
        private const val INDICATOR_BORDER_WIDTH_DP = 2
        private const val CHECKMARK_ICON_SIZE_DP = 16
    }

    private val state get() = store.state
    private val theme = AlbumPickerThemeInternal
    private val darkTextColor = AlbumPickerThemeInternal.darkTextColor

    var isPreviewFromSelection: Boolean = false

    private val pageIndicator: TextView
    private val selectIndicator: FrameLayout
    private val checkmarkIcon: ImageView

    private var observeJob: Job? = null

    init {
        val statusBarHeight = AlbumPickerWindowHelper.getStatusBarHeight(context)
        val headerHeight = AlbumPickerUtil.dpToPx(context, HEADER_HEIGHT_DP)
        val horizontalPadding = resources.getDimensionPixelSize(R.dimen.spacing_16)
        val darkBackground = AlbumPickerThemeInternal.darkBackground

        layoutParams =
            LayoutParams(LayoutParams.MATCH_PARENT, headerHeight + statusBarHeight).apply {
                gravity = Gravity.TOP
            }
        setPadding(horizontalPadding, statusBarHeight, horizontalPadding, 0)
        setBackgroundColor(darkBackground)

        addView(createBackButton())
        pageIndicator = createPageIndicator()
        addView(pageIndicator)
        val (button, indicator, doneIcon) = createSelectButton()
        selectIndicator = indicator
        checkmarkIcon = doneIcon
        addView(button)
    }

    fun startObserving() {
        val lifecycleOwner = context as? LifecycleOwner ?: return
        stopObserving()
        observeJob =
            lifecycleOwner.lifecycleScope.launch {
                combine(state.currentPreviewMedia, state.selectedMedias) { _, _ -> }
                    .collect {
                        updatePageIndicator()
                        updateSelectState()
                    }
            }
    }

    fun stopObserving() {
        observeJob?.cancel()
        observeJob = null
    }

    private fun createBackButton(): ImageView {
        val size = AlbumPickerUtil.dpToPx(context, BACK_ICON_SIZE_DP)
        return ImageView(context).apply {
            setImageResource(R.drawable.album_picker_ic_back)
            setColorFilter(darkTextColor)
            layoutParams =
                LayoutParams(size, size).apply {
                    gravity = Gravity.START or Gravity.CENTER_VERTICAL
                }
            setOnClickListener { onDismissListener.onDismiss() }
        }
    }

    private fun createPageIndicator(): TextView =
        TextView(context).apply {
            setTextColor(darkTextColor)
            textSize = theme.bigFontSize
            gravity = Gravity.CENTER
            layoutParams =
                LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT).apply {
                    gravity = Gravity.CENTER
                }
        }

    private fun createSelectButton(): Triple<LinearLayout, FrameLayout, ImageView> {
        val indicatorSize = AlbumPickerUtil.dpToPx(context, INDICATOR_SIZE_DP)
        val checkmarkIconSize = AlbumPickerUtil.dpToPx(context, CHECKMARK_ICON_SIZE_DP)
        val spacing = resources.getDimensionPixelSize(R.dimen.spacing_8)

        val indicator =
            FrameLayout(context).apply {
                layoutParams = LinearLayout.LayoutParams(indicatorSize, indicatorSize)
            }

        val checkmarkLayoutParams = LayoutParams(checkmarkIconSize, checkmarkIconSize).apply {
            gravity = Gravity.CENTER }
        val checkmark =
            ImageView(context).apply {
                setImageResource(R.drawable.album_picker_ic_done)
                layoutParams = checkmarkLayoutParams
                visibility = GONE
            }
        indicator.addView(checkmark)

        val textLayoutParams =
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply { marginStart = spacing }
        val selectText =
            TextView(context).apply {
                text = context.getString(R.string.album_picker_select)
                setTextColor(darkTextColor)
                textSize = theme.normalFontSize
                layoutParams = textLayoutParams
            }

        val buttonLayoutParams =
            LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT).apply {
                gravity = Gravity.END or Gravity.CENTER_VERTICAL
            }
        val button =
            LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                layoutParams = buttonLayoutParams
                setOnClickListener { onSelectClick() }
                addView(indicator)
                addView(selectText)
            }

        return Triple(button, indicator, checkmark)
    }

    private fun onSelectClick() {
        val currentMedia = state.currentPreviewMedia.value ?: return
        if (!isPreviewFromSelection) {
            store.toggleMediaSelection(currentMedia)
            return
        }
        val currentSelected = state.selectedMedias.value.toMutableList()
        val existingIndex = currentSelected.indexOfFirst { it.media.id == currentMedia.id }
        if (existingIndex < 0) return
        val item = currentSelected[existingIndex]
        currentSelected[existingIndex] = item.copy(isPendingRemoval = !item.isPendingRemoval)
        store.updateSelectedMedias(currentSelected)
    }

    @SuppressLint("SetTextI18n")
    private fun updatePageIndicator() {
        val currentMedia = state.currentPreviewMedia.value ?: return
        val previewList = state.previewMedias.value
        val currentIndex = previewList.indexOfFirst { it.id == currentMedia.id }
        if (currentIndex < 0) {
            return
        }
        pageIndicator.text = "${currentIndex + 1}/${previewList.size}"
    }

    private fun updateSelectState() {
        val currentMedia = state.currentPreviewMedia.value ?: return
        val selectedItem = state.selectedMedias.value.find { it.media.id == currentMedia.id }
        val isSelected = selectedItem != null && !selectedItem.isPendingRemoval

        val indicatorSize = AlbumPickerUtil.dpToPx(context, INDICATOR_SIZE_DP)
        val borderWidth = AlbumPickerUtil.dpToPx(context, INDICATOR_BORDER_WIDTH_DP)

        if (isSelected) {
            checkmarkIcon.visibility = VISIBLE
            selectIndicator.background =
                GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(theme.currentPrimaryColor)
                    setSize(indicatorSize, indicatorSize)
                }
        } else {
            checkmarkIcon.visibility = GONE
            selectIndicator.background =
                GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(Color.TRANSPARENT)
                    setStroke(borderWidth, darkTextColor)
                    setSize(indicatorSize, indicatorSize)
                }
        }
    }
}
