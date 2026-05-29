package io.trtc.tuikit.atomicx.albumpicker.view.likewechat

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import io.trtc.tuikit.albumpickercore.AlbumPickerStore
import io.trtc.tuikit.albumpickercore.util.AlbumPickerUtil
import io.trtc.tuikit.atomicx.albumpicker.R
import io.trtc.tuikit.atomicx.albumpicker.view.common.AlbumPickerThemeInternal
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

internal class WeChatBottomBarView(
    context: Context,
    private val store: AlbumPickerStore,
    private val isPreview: Boolean = false,
) : FrameLayout(context) {
    interface Listener {
        fun onClickSend()

        fun onPreviewClick() {}
    }

    companion object {
        private const val BAR_HEIGHT_DP = 44
    }

    var listener: Listener? = null

    private val theme = AlbumPickerThemeInternal

    private val bgColor =
        if (isPreview)
            AlbumPickerThemeInternal.darkBackground else theme.backgroundColor

    private val bgColorSecondary =
        if (isPreview)
            AlbumPickerThemeInternal.darkBackgroundSecondary else theme.backgroundColorSecondary

    private val txtColor =
        if (isPreview)
            AlbumPickerThemeInternal.darkTextColor else theme.textColor

    private val txtColorSecondary =
        if (isPreview)
            AlbumPickerThemeInternal.darkTextColorSecondary else theme.textColorSecondary

    private lateinit var sendText: TextView
    private var previewText: TextView? = null
    private var selectedCount: Int = 0
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

    private fun startObserving() {
        stopObserving()
        val lifecycleOwner = context as? LifecycleOwner ?: return
        observeJob =
            lifecycleOwner.lifecycleScope.launch {
                store.state.selectedMedias.collectLatest { selectedMedias ->
                    val count =
                        if (isPreview) {
                            selectedMedias.count { !it.isPendingRemoval }
                        } else {
                            selectedMedias.size
                        }
                    updateState(count)
                }
            }
    }

    private fun stopObserving() {
        observeJob?.cancel()
        observeJob = null
    }

    private fun setupViews() {
        val barHeight = AlbumPickerUtil.dpToPx(context, BAR_HEIGHT_DP)
        val horizontalPadding = resources.getDimensionPixelSize(R.dimen.spacing_16)

        layoutParams =
            if (isPreview) {
                LayoutParams(LayoutParams.MATCH_PARENT, barHeight).apply {
                    gravity = Gravity.BOTTOM
                }
            } else {
                LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, barHeight)
            }
        setBackgroundColor(bgColor)
        setPadding(horizontalPadding, 0, horizontalPadding, 0)

        if (!isPreview) {
            previewText = createPreviewText()
            addView(previewText)
        }

        sendText = createSendText()
        addView(sendText)

        updateState(0)
    }

    private fun createPreviewText(): TextView {
        val previewLayoutParams =
            LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT).apply {
                gravity = Gravity.START or Gravity.CENTER_VERTICAL
            }
        return TextView(context).apply {
            text = context.getString(R.string.album_picker_preview)
            textSize = theme.bigFontSize
            setTextColor(txtColorSecondary)
            gravity = Gravity.CENTER
            layoutParams = previewLayoutParams
            setOnClickListener {
                if (selectedCount > 0) listener?.onPreviewClick()
            }
        }
    }

    private fun createSendText(): TextView {
        val sendHPadding = resources.getDimensionPixelSize(R.dimen.spacing_10)
        val sendVPadding = resources.getDimensionPixelSize(R.dimen.spacing_4)
        val cornerRadius = AlbumPickerUtil.dpToPx(context, theme.smallRadius).toFloat()
        val sendLayoutParams =
            LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply {
                gravity = Gravity.END or Gravity.CENTER_VERTICAL
            }
        val sendBackground =
            GradientDrawable().apply {
                setColor(bgColorSecondary)
                this.cornerRadius = cornerRadius
            }
        return TextView(context).apply {
            text = context.getString(R.string.album_picker_send)
            textSize = theme.bigFontSize
            setTextColor(txtColorSecondary)
            gravity = Gravity.CENTER
            setPadding(sendHPadding, sendVPadding, sendHPadding, sendVPadding)
            layoutParams = sendLayoutParams
            background = sendBackground
            setOnClickListener {
                if (isPreview || selectedCount > 0) listener?.onClickSend()
            }
        }
    }

    @SuppressLint("SetTextI18n")
    private fun updateState(count: Int) {
        selectedCount = count
        val cornerRadius = AlbumPickerUtil.dpToPx(context, theme.smallRadius).toFloat()

        if (count > 0) {
            previewText?.text = "${context.getString(R.string.album_picker_preview)}($count)"
            previewText?.setTextColor(txtColor)

            sendText.text = "${context.getString(R.string.album_picker_send)}($count)"
            sendText.setTextColor(txtColor)
            sendText.background =
                GradientDrawable().apply {
                    setColor(theme.currentPrimaryColor)
                    this.cornerRadius = cornerRadius
                }
        } else {
            previewText?.text = context.getString(R.string.album_picker_preview)
            previewText?.setTextColor(txtColorSecondary)

            sendText.text = context.getString(R.string.album_picker_send)
            sendText.setTextColor(txtColorSecondary)
            sendText.background =
                GradientDrawable().apply {
                    setColor(bgColorSecondary)
                    this.cornerRadius = cornerRadius
                }
        }
    }
}
