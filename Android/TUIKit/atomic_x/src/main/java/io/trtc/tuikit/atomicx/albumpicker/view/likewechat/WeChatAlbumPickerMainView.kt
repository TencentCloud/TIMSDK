package io.trtc.tuikit.atomicx.albumpicker.view.likewechat

import android.content.Context
import android.graphics.Rect
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.core.view.isVisible
import androidx.lifecycle.findViewTreeLifecycleOwner
import io.trtc.tuikit.albumpickercore.AlbumListView
import io.trtc.tuikit.albumpickercore.AlbumPickerStore
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerConfig
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerListener
import io.trtc.tuikit.atomicx.albumpicker.R
import io.trtc.tuikit.atomicx.albumpicker.view.common.AlbumPickerMainViewCommon
import io.trtc.tuikit.atomicx.albumpicker.view.common.AlbumPickerThemeInternal

internal class WeChatAlbumPickerMainView(
    private val context: Context,
    private val store: AlbumPickerStore,
    private val previewView: WeChatAlbumPickerPreviewView,
    config: AlbumPickerConfig,
    listener: AlbumPickerListener?,
) : LinearLayout(context) {
    private val common: AlbumPickerMainViewCommon
    private val bottomBar: WeChatBottomBarView

    private val backPressedCallback =
        object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                if (!handleBackPressed()) {
                    isEnabled = false
                    (context as? ComponentActivity)?.onBackPressedDispatcher?.onBackPressed()
                    isEnabled = true
                }
            }
        }

    init {
        orientation = VERTICAL
        layoutParams =
            FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)

        common = AlbumPickerMainViewCommon(context, store, this, config, listener)
        bottomBar = WeChatBottomBarView(context, store)
    }

    fun setup() {
        bottomBar.listener = bottomBarListener
        previewView.listener = previewListener
        common.listener = commonListener
        common.setup(
            bottomBarView = bottomBar,
            albumListViewFactory = ::createAlbumListView,
        )
    }

    private val bottomBarListener =
        object : WeChatBottomBarView.Listener {
            override fun onClickSend() {
                common.deliverResult()
            }

            override fun onPreviewClick() {
                val selected = store.state.selectedMedias.value.map { it.media }
                if (selected.isEmpty()) return
                store.updateCurrentPreviewMedia(selected.first())
                store.updatePreviewMedias(selected)
                previewView.show(isPreviewFromSelection = true)
            }
        }

    private val previewListener =
        object : WeChatAlbumPickerPreviewView.Listener {
            override fun onClickSend(textMessage: String?) {
                common.deliverResult(textMessage)
            }

            override fun onDismiss() {
                common.removeCapturedMedias()
            }
        }

    private val commonListener =
        object : AlbumPickerMainViewCommon.Listener {
            override fun onShowPreview(isPreviewFromSelection: Boolean) {
                previewView.show(isPreviewFromSelection = isPreviewFromSelection)
            }
        }

    private fun createAlbumListView(topOffset: Int): AlbumListView {
        val displayMetrics = context.resources.displayMetrics
        val rect = Rect(0, topOffset, displayMetrics.widthPixels, displayMetrics.heightPixels)
        return AlbumListView(context, store, rect).apply {
            setBackgroundResource(R.drawable.album_picker_bg_rounded_pill)
            background.setTint(AlbumPickerThemeInternal.backgroundColorSecondary)
            val hPad = context.resources.getDimensionPixelSize(R.dimen.spacing_16)
            val vPad = context.resources.getDimensionPixelSize(R.dimen.spacing_4)
            setPadding(hPad, vPad, hPad, vPad)
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        common.onAttachedToWindow()
        val lifecycleOwner = findViewTreeLifecycleOwner() ?: return
        (context as? ComponentActivity)?.onBackPressedDispatcher
            ?.addCallback(lifecycleOwner, backPressedCallback)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        common.onDetachedFromWindow()
        backPressedCallback.remove()
    }

    private fun handleBackPressed(): Boolean {
        if (previewView.isVisible) {
            previewView.hide()
            return true
        }
        return common.handleBackPressed()
    }
}
