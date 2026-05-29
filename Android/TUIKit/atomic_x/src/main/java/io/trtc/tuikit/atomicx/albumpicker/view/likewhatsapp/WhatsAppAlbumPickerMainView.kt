package io.trtc.tuikit.atomicx.albumpicker.view.likewhatsapp

import android.app.Activity
import android.content.Context
import android.graphics.Rect
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.lifecycle.findViewTreeLifecycleOwner
import io.trtc.tuikit.albumpickercore.AlbumListView
import io.trtc.tuikit.albumpickercore.AlbumPickerStore
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerConfig
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerListener
import io.trtc.tuikit.atomicx.albumpicker.R
import io.trtc.tuikit.atomicx.albumpicker.util.AlbumPickerWindowHelper
import io.trtc.tuikit.atomicx.albumpicker.view.common.AlbumPickerMainViewCommon
import io.trtc.tuikit.atomicx.albumpicker.view.common.AlbumPickerThemeInternal

internal class WhatsAppAlbumPickerMainView(
    private val context: Context,
    private val store: AlbumPickerStore,
    private val previewView: WhatsAppAlbumPickerPreviewView,
    config: AlbumPickerConfig,
    listener: AlbumPickerListener?,
) : LinearLayout(context) {
    companion object {
        private const val ALBUM_LIST_SIZE_RATIO = 0.6
    }

    private val activity = context as? Activity
    private val common: AlbumPickerMainViewCommon
    private lateinit var bottomBar: WhatsAppBottomBarView
    private var isAddingMore = false

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

        if (AlbumPickerThemeInternal.confirmButtonIcon == null) {
            AlbumPickerThemeInternal.confirmButtonIcon =
                ContextCompat.getDrawable(context, R.drawable.album_picker_ic_send)
        }

        common = AlbumPickerMainViewCommon(context, store, this, config, listener)
    }

    fun setup() {
        bottomBar =
            WhatsAppBottomBarView(context, store, listener = bottomBarListener).apply {
                visibility = View.GONE
            }

        previewView.listener = previewListener
        common.listener = commonListener
        common.setup(
            bottomBarView = bottomBar,
            tapMediaToSelect = true,
            albumListViewFactory = ::createAlbumListView,
        )
    }

    private val bottomBarListener =
        object : WhatsAppBottomBarView.Listener {
            override fun onClickSend(textMessage: String?) {
                common.deliverResult(textMessage)
            }

            override fun onPreviewClick() {
                val selected = store.state.selectedMedias.value.map { it.media }
                if (selected.isEmpty()) return
                store.updateCurrentPreviewMedia(selected.first())
                store.updatePreviewMedias(selected)
                bottomBar.hideSelectedThumbnails()
                previewView.show()
            }
        }

    private val previewListener =
        object : WhatsAppAlbumPickerPreviewView.Listener {
            override fun onClickSend(textMessage: String?) {
                common.deliverResult(textMessage)
            }

            override fun onAddMore() {
                isAddingMore = true
                previewView.hide()
                bottomBar.showSelectedThumbnails(
                    store.state.selectedMedias.value.map { it.media.uri },
                )
            }

            override fun onDismiss() {
                if (isAddingMore) {
                    isAddingMore = false
                    return
                }
                common.removeCapturedMedias()
            }
        }

    private val commonListener =
        object : AlbumPickerMainViewCommon.Listener {
            override fun onShowPreview(isPreviewFromSelection: Boolean) {
                bottomBar.hideSelectedThumbnails()
                previewView.show()
            }
        }

    private fun createAlbumListView(topOffset: Int): AlbumListView {
        val displayMetrics = context.resources.displayMetrics
        val width = (displayMetrics.widthPixels * ALBUM_LIST_SIZE_RATIO).toInt()
        val height = (displayMetrics.heightPixels * ALBUM_LIST_SIZE_RATIO).toInt()
        val left = (displayMetrics.widthPixels - width) / 2
        val rect = Rect(left, topOffset, left + width, topOffset + height)
        return AlbumListView(context, store, rect)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        common.onAttachedToWindow()
        val containerView = parent as? View ?: return
        AlbumPickerWindowHelper.applySoftInputMode(activity, containerView, this, previewView) {
            bottomBar.collapse()
        }
        val lifecycleOwner = findViewTreeLifecycleOwner() ?: return
        (context as? ComponentActivity)?.onBackPressedDispatcher
            ?.addCallback(lifecycleOwner, backPressedCallback)
    }

    override fun onDetachedFromWindow() {
        val containerView = parent as? View
        super.onDetachedFromWindow()
        common.onDetachedFromWindow()
        backPressedCallback.remove()
        if (containerView != null) {
            AlbumPickerWindowHelper.restoreSoftInputMode(activity, containerView, this, previewView)
        }
    }

    private fun handleBackPressed(): Boolean {
        if (previewView.isVisible) {
            previewView.hide()
            return true
        }

        if (bottomBar.isInAddMoreMode()) {
            bottomBar.hideSelectedThumbnails()
            return true
        }

        if (bottomBar.collapse()) {
            return true
        }

        return common.handleBackPressed()
    }
}
