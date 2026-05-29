package io.trtc.tuikit.atomicx.albumpicker.view.likewhatsapp

import android.animation.AnimatorSet
import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.Outline
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.ViewOutlineProvider
import android.view.animation.DecelerateInterpolator
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import io.trtc.tuikit.albumpickercore.AlbumPickerStore
import io.trtc.tuikit.albumpickercore.store.SelectedMediaItem
import io.trtc.tuikit.albumpickercore.util.AlbumPickerUtil
import io.trtc.tuikit.atomicx.albumpicker.R
import io.trtc.tuikit.atomicx.albumpicker.view.common.AlbumPickerThemeInternal
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

internal class WhatsAppBottomBarView(
    context: Context,
    private val store: AlbumPickerStore,
    private val isPreview: Boolean = false,
    private val listener: Listener? = null,
) : LinearLayout(context) {
    interface Listener {
        fun onClickSend(textMessage: String?)

        fun onPreviewClick() {}

        fun onAddMore() {}
    }

    companion object {
        private const val BAR_HEIGHT_DP = 56
        private const val ANIMATION_DURATION_MS = 200L

        private const val THUMBNAIL_SIZE_DP = 36
        private const val THUMBNAIL_FRONT_BORDER_DP = 2
        private const val THUMBNAIL_CONTAINER_EXTRA_DP = 10
        private const val BACK_THUMBNAIL_ROTATION = -10f

        private const val INPUT_HEIGHT_DP = 36

        private const val SEND_BUTTON_SIZE_DP = 42
        private const val SEND_ICON_SIZE_DP = 20
        private const val BADGE_SIZE_DP = 22
        private const val BADGE_OFFSET_DP = 2
        private const val BADGE_BORDER_WIDTH_DP = 2

        private const val SELECTED_THUMBNAIL_SIZE_DP = 48
        private const val THUMBNAIL_LIST_HEIGHT_DP = 64
        private const val CONFIRM_BUTTON_SIZE_DP = 42
        private const val CONFIRM_ICON_SIZE_DP = 20

        private const val ADD_MEDIA_BUTTON_SIZE_DP = 36
        private const val ADD_MEDIA_ICON_SIZE_DP = 22

        private const val GLIDE_OVERRIDE_SIZE = 200
    }

    private val theme = AlbumPickerThemeInternal

    private val bgColor =
        if (isPreview)
            AlbumPickerThemeInternal.darkBackground else theme.backgroundColor

    private val bgColorSecondary =
        if (isPreview)
            AlbumPickerThemeInternal.darkBackgroundSecondary else
            theme.backgroundColorSecondary

    private val txtColor =
        if (isPreview)
            AlbumPickerThemeInternal.darkTextColor else theme.textColor

    private val txtColorSecondary =
        if (isPreview)
            AlbumPickerThemeInternal.darkTextColorSecondary else theme.textColorSecondary

    private lateinit var inputRow: LinearLayout
    private lateinit var captionInput: EditText
    private lateinit var sendButton: FrameLayout

    private var thumbnailContainer: FrameLayout? = null
    private var thumbnailBackView: ImageView? = null
    private var thumbnailFrontView: ImageView? = null
    private var badgeView: TextView? = null
    private var addMoreRow: LinearLayout? = null
    private var selectedThumbnailAdapter: SelectedMediaAdapter? = null
    private var isExpanded = false
    private var isAddMoreMode = false
    private var expandAnimator: AnimatorSet? = null
    private var thumbnailContainerSize = 0

    private var itemSpacing = 0
    private var observeJob: Job? = null

    init {
        setupViews()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        startObserving()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        stopObserving()
    }

    fun collapse(): Boolean {
        val dismissed = dismissKeyboard()
        if (!isPreview && isExpanded) {
            animateThumbnail(expand = false)
            return true
        }
        return dismissed
    }

    fun isInAddMoreMode(): Boolean = isAddMoreMode

    @SuppressLint("NotifyDataSetChanged")
    fun showSelectedThumbnails(uris: List<Uri>) {
        if (isPreview || uris.isEmpty()) {
            return
        }
        isAddMoreMode = true
        selectedThumbnailAdapter?.updateData(uris)
        inputRow.visibility = GONE
        addMoreRow?.visibility = VISIBLE
        scrollToLastItem()
    }

    fun hideSelectedThumbnails() {
        if (!isAddMoreMode) {
            return
        }
        isAddMoreMode = false
        addMoreRow?.visibility = GONE
        inputRow.visibility = VISIBLE
    }

    private fun getTextMessage(): String? =
        captionInput.text?.toString()?.takeIf {
            it.isNotBlank()
        }

    private fun startObserving() {
        stopObserving()
        val lifecycleOwner = context as? LifecycleOwner ?: return
        observeJob =
            lifecycleOwner.lifecycleScope.launch {
                store.state.selectedMedias.collectLatest { selectedMedias ->
                    onSelectedMediasChanged(selectedMedias)
                }
            }
    }

    private fun stopObserving() {
        observeJob?.cancel()
        observeJob = null
    }

    private suspend fun onSelectedMediasChanged(selectedMedias: List<SelectedMediaItem>) {
        val activeMedias =
            if (isPreview) {
                selectedMedias.filter { !it.isPendingRemoval }
            } else {
                selectedMedias
            }

        if (activeMedias.isEmpty()) {
            if (!isPreview) visibility = GONE
            return
        }

        if (!isPreview) visibility = VISIBLE

        val front = activeMedias.firstOrNull()?.media
        val back = if (activeMedias.size > 1) activeMedias.last().media else null

        if (!isPreview) {
            val frontBmp = withContext(Dispatchers.IO) { store.loadMediaThumbnail(front?.uri) }
            val backBmp =
                if (back != null) {
                    withContext(Dispatchers.IO) { store.loadMediaThumbnail(back.uri) }
                } else null
            if (!isAttachedToWindow) return
            updateState(activeMedias.size, frontBmp, backBmp)
        } else {
            updateState(activeMedias.size, null, null)
        }

        updateSelectedThumbnailsIfVisible(activeMedias.map { it.media.uri })
    }

    private fun updateSelectedThumbnailsIfVisible(uris: List<Uri>) {
        if (!isAddMoreMode) {
            return
        }
        if (uris.isEmpty()) {
            hideSelectedThumbnails()
        } else {
            selectedThumbnailAdapter?.updateData(uris)
            scrollToLastItem()
        }
    }

    private fun updateState(count: Int, frontThumbnail: Bitmap?, backThumbnail: Bitmap?) {
        if (!isPreview) {
            frontThumbnail?.let { thumbnailFrontView?.setImageBitmap(it) }
            thumbnailBackView?.visibility = if (count > 1) VISIBLE else GONE
            if (count > 1) backThumbnail?.let { thumbnailBackView?.setImageBitmap(it) }
        }
        updateBadge(count)
    }

    private fun updateBadge(count: Int) {
        val badge = badgeView ?: return
        if (count > 0) {
            badge.text = count.toString()
            badge.visibility = VISIBLE
        } else {
            badge.visibility = GONE
        }
    }

    private fun setupViews() {
        val barHeight = AlbumPickerUtil.dpToPx(context, BAR_HEIGHT_DP)
        val hPad = resources.getDimensionPixelSize(R.dimen.spacing_8)
        itemSpacing = hPad

        orientation = VERTICAL
        layoutParams =
            if (isPreview) {
                FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
                    .apply { gravity = Gravity.BOTTOM }
            } else {
                LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
            }
        setBackgroundColor(bgColor)

        if (!isPreview) {
            setupAddMoreRow()
            addView(addMoreRow)
        }

        inputRow =
            LinearLayout(context).apply {
                orientation = HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, barHeight)
                setPadding(hPad, 0, hPad, 0)
            }

        if (isPreview) {
            inputRow.addView(createAddMediaButton())
        } else {
            setupThumbnail()
            inputRow.addView(thumbnailContainer)
        }
        inputRow.addView(createCaptionInput())
        inputRow.addView(createSendButton())
        addView(inputRow)
    }

    private fun createAddMediaButton(): ImageView {
        val btnSize = AlbumPickerUtil.dpToPx(context, ADD_MEDIA_BUTTON_SIZE_DP)
        val iconSize = AlbumPickerUtil.dpToPx(context, ADD_MEDIA_ICON_SIZE_DP)
        val iconPad = (btnSize - iconSize) / 2
        return ImageView(context).apply {
            layoutParams = LayoutParams(btnSize, btnSize).apply { marginEnd = itemSpacing }
            setImageResource(R.drawable.album_picker_ic_add_media)
            setColorFilter(txtColor)
            scaleType = ImageView.ScaleType.CENTER_INSIDE
            setPadding(iconPad, iconPad, iconPad, iconPad)
            setOnClickListener { listener?.onAddMore() }
        }
    }

    private fun setupThumbnail() {
        val thumbSize = AlbumPickerUtil.dpToPx(context, THUMBNAIL_SIZE_DP)
        val corner = AlbumPickerUtil.dpToPx(context, theme.smallRadius).toFloat()
        val border = AlbumPickerUtil.dpToPx(context, THUMBNAIL_FRONT_BORDER_DP)
        thumbnailContainerSize =
            AlbumPickerUtil.dpToPx(context, THUMBNAIL_SIZE_DP + THUMBNAIL_CONTAINER_EXTRA_DP)
        val outlineProvider = RoundedOutlineProvider(corner)

        thumbnailContainer = FrameLayout(context).apply {
                layoutParams = LayoutParams(thumbnailContainerSize, thumbnailContainerSize)
                clipChildren = false
                clipToPadding = false
                setOnClickListener { listener?.onPreviewClick() }
            }

        val backLayoutParams = FrameLayout.LayoutParams(thumbSize, thumbSize).apply {
                gravity = Gravity.BOTTOM or Gravity.START
            }

        thumbnailBackView = createRoundedImageView(thumbSize, outlineProvider).apply {
                layoutParams = backLayoutParams
                rotation = BACK_THUMBNAIL_ROTATION
                visibility = GONE
            }

        val frontWrapper = createFrontWrapper(thumbSize, corner, border)
        val frontLayoutParams = FrameLayout.LayoutParams(thumbSize, thumbSize).apply {
            gravity = Gravity.CENTER }
        thumbnailFrontView = createRoundedImageView(thumbSize, outlineProvider).apply {
                layoutParams = frontLayoutParams }
        frontWrapper.addView(thumbnailFrontView)

        thumbnailContainer?.addView(thumbnailBackView)
        thumbnailContainer?.addView(frontWrapper)
    }

    private fun createFrontWrapper(thumbSize: Int, corner: Float, border: Int): FrameLayout {
        val size = thumbSize + border * 2
        val wrapperLayoutParams = FrameLayout.LayoutParams(size, size).apply {
            gravity = Gravity.BOTTOM or Gravity.END }
        val wrapperBackground =
            GradientDrawable().apply {
                setColor(bgColor)
                setCornerRadius(corner + border)
            }
        return FrameLayout(context).apply {
            layoutParams = wrapperLayoutParams
            background = wrapperBackground
        }
    }

    private fun createCaptionInput(): EditText {
        val inputHeight = AlbumPickerUtil.dpToPx(context, INPUT_HEIGHT_DP)
        val cornerRadius = inputHeight / 2f
        val horizontalPadding = context.resources.getDimensionPixelSize(R.dimen.spacing_12)
        val inputLayoutParams =
            LayoutParams(0, inputHeight, 1f).apply {
                marginStart = itemSpacing
                marginEnd = itemSpacing
            }
        val inputBackground =
            GradientDrawable().apply {
                setColor(bgColorSecondary)
                setCornerRadius(cornerRadius)
            }

        captionInput =
            EditText(context).apply {
                layoutParams = inputLayoutParams
                hint = context.getString(R.string.album_picker_add_caption)
                setHintTextColor(txtColorSecondary)
                setTextColor(txtColor)
                textSize = theme.normalFontSize
                isSingleLine = true
                setPadding(horizontalPadding, 0, horizontalPadding, 0)
                gravity = Gravity.CENTER_VERTICAL
                background = inputBackground
                if (!isPreview) {
                    setOnFocusChangeListener { _, hasFocus -> animateThumbnail(expand = hasFocus) }
                }
            }
        return captionInput
    }

    private fun createSendButton(): FrameLayout {
        val btnSize = AlbumPickerUtil.dpToPx(context, SEND_BUTTON_SIZE_DP)

        sendButton =
            FrameLayout(context).apply {
                layoutParams = LayoutParams(btnSize, btnSize)
                background = ovalDrawable(theme.currentPrimaryColor)
                setOnClickListener { listener?.onClickSend(getTextMessage()) }
            }
        sendButton.addView(createSendIcon())
        sendButton.addView(createBadgeView())
        return sendButton
    }

    private fun createSendIcon(): ImageView {
        val iconSize = AlbumPickerUtil.dpToPx(context, SEND_ICON_SIZE_DP)
        val iconLayoutParams = FrameLayout.LayoutParams(iconSize, iconSize).apply {
            gravity = Gravity.CENTER }
        return ImageView(context).apply {
            layoutParams = iconLayoutParams
            setImageResource(R.drawable.album_picker_ic_send)
        }
    }

    private fun ovalDrawable(color: Int): GradientDrawable =
        GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(color)
        }

    private fun createBadgeView(): TextView {
        val size = AlbumPickerUtil.dpToPx(context, BADGE_SIZE_DP)
        val offset = AlbumPickerUtil.dpToPx(context, BADGE_OFFSET_DP)
        val borderWidth = AlbumPickerUtil.dpToPx(context, BADGE_BORDER_WIDTH_DP)
        val inverseBg = theme.textColor
        val textColor = theme.backgroundColor
        val borderColor = textColor

        val badgeLayoutParams =
            FrameLayout.LayoutParams(size, size).apply {
                gravity = Gravity.TOP or Gravity.END
                topMargin = -offset
                marginEnd = -offset
            }

        badgeView =
            TextView(context).apply {
                layoutParams = badgeLayoutParams
                this.gravity = Gravity.CENTER
                textSize = theme.smallFontSize
                setTextColor(textColor)
                typeface = Typeface.DEFAULT_BOLD
                background = ovalDrawableWithStroke(inverseBg, borderWidth, borderColor)
                visibility = GONE
            }
        return badgeView!!
    }

    private fun ovalDrawableWithStroke(color: Int, strokeWidth: Int, strokeColor: Int): GradientDrawable =
        GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(color)
            setStroke(strokeWidth, strokeColor)
        }

    private fun setupAddMoreRow() {
        val listHeight = AlbumPickerUtil.dpToPx(context, THUMBNAIL_LIST_HEIGHT_DP)
        val spacing = resources.getDimensionPixelSize(R.dimen.spacing_8)

        selectedThumbnailAdapter = SelectedMediaAdapter()

        val thumbnailList =
            RecyclerView(context).apply {
                layoutParams = LayoutParams(0, LayoutParams.MATCH_PARENT, 1f)
                layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
                adapter = selectedThumbnailAdapter
                setPadding(spacing, spacing, spacing, spacing)
                clipToPadding = false
            }

        val confirmBtn = createConfirmButton(spacing)

        addMoreRow =
            LinearLayout(context).apply {
                orientation = HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, listHeight)
                visibility = GONE
                addView(thumbnailList)
                addView(confirmBtn)
            }
    }

    private fun createConfirmButton(margin: Int): FrameLayout {
        val btnSize = AlbumPickerUtil.dpToPx(context, CONFIRM_BUTTON_SIZE_DP)
        val iconSize = AlbumPickerUtil.dpToPx(context, CONFIRM_ICON_SIZE_DP)
        val confirmIconLayoutParams = FrameLayout.LayoutParams(iconSize, iconSize).apply {
            gravity = Gravity.CENTER }
        val icon =
            ImageView(context).apply {
                setImageResource(R.drawable.album_picker_ic_done)
                layoutParams = confirmIconLayoutParams
            }
        return FrameLayout(context).apply {
            layoutParams = LayoutParams(btnSize, btnSize).apply { marginEnd = margin }
            background = ovalDrawable(theme.currentPrimaryColor)
            setOnClickListener { listener?.onPreviewClick() }
            addView(icon)
        }
    }

    private fun scrollToLastItem() {
        val list = addMoreRow?.getChildAt(0) as? RecyclerView ?: return
        val count = selectedThumbnailAdapter?.itemCount ?: return
        if (count > 0) {
            list.post { list.smoothScrollToPosition(count - 1) }
        }
    }

    private fun animateThumbnail(expand: Boolean) {
        if (isPreview) {
            return
        }
        if (expand && isExpanded) {
            return
        }
        if (!expand && !isExpanded) {
            return
        }
        isExpanded = expand
        expandAnimator?.cancel()

        val container = thumbnailContainer ?: return
        val containerLp = container.layoutParams as LayoutParams
        val inputLp = captionInput.layoutParams as LayoutParams

        val targetSize = if (expand) 0 else thumbnailContainerSize
        val targetMargin = if (expand) 0 else itemSpacing
        val maxSize = thumbnailContainerSize.coerceAtLeast(1)

        val sizeAnim =
            ValueAnimator.ofInt(containerLp.width, targetSize).apply {
                addUpdateListener { v ->
                    val value = v.animatedValue as Int
                    containerLp.width = value
                    containerLp.height = value
                    container.layoutParams = containerLp
                    container.alpha = value.toFloat() / maxSize
                }
            }
        val marginAnim =
            ValueAnimator.ofInt(inputLp.marginStart, targetMargin).apply {
                addUpdateListener { v ->
                    inputLp.marginStart = v.animatedValue as Int
                    captionInput.layoutParams = inputLp
                }
            }

        expandAnimator =
            AnimatorSet().apply {
                playTogether(sizeAnim, marginAnim)
                duration = ANIMATION_DURATION_MS
                interpolator = DecelerateInterpolator()
                start()
            }
    }

    private fun dismissKeyboard(): Boolean {
        if (!captionInput.hasFocus()) {
            return false
        }
        captionInput.clearFocus()
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.hideSoftInputFromWindow(captionInput.windowToken, 0)
        return true
    }

    private inner class SelectedMediaAdapter : RecyclerView.Adapter<SelectedMediaAdapter.VH>() {
        private var items: List<Uri> = emptyList()

        @SuppressLint("NotifyDataSetChanged")
        fun updateData(uris: List<Uri>) {
            items = uris
            notifyDataSetChanged()
        }

        override fun getItemCount() = items.size

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
            val size = AlbumPickerUtil.dpToPx(context, SELECTED_THUMBNAIL_SIZE_DP)
            val corner = AlbumPickerUtil.dpToPx(context, theme.smallRadius).toFloat()
            val spacing = context.resources.getDimensionPixelSize(R.dimen.spacing_6)
            val iv =
                ImageView(context).apply {
                    layoutParams =
                        RecyclerView.LayoutParams(size, size).apply { marginEnd = spacing }
                    scaleType = ImageView.ScaleType.CENTER_CROP
                    outlineProvider = RoundedOutlineProvider(corner)
                    clipToOutline = true
                }
            return VH(iv)
        }

        override fun onBindViewHolder(holder: VH, position: Int) {
            Glide.with(context).load(items[position])
                .override(GLIDE_OVERRIDE_SIZE, GLIDE_OVERRIDE_SIZE)
                .centerCrop().into(holder.itemView as ImageView)
        }

        inner class VH(
            itemView: View,
        ) : RecyclerView.ViewHolder(itemView)
    }

    private fun createRoundedImageView(size: Int, outlineProvider: ViewOutlineProvider): ImageView =
        ImageView(context).apply {
            scaleType = ImageView.ScaleType.CENTER_CROP
            clipToOutline = true
            this.outlineProvider = outlineProvider
            setBackgroundColor(bgColorSecondary)
        }

    private class RoundedOutlineProvider(
        private val radius: Float,
    ) : ViewOutlineProvider() {
        override fun getOutline(view: View, outline: Outline) {
            outline.setRoundRect(0, 0, view.width, view.height, radius)
        }
    }
}
