package io.trtc.tuikit.atomicx.albumpicker.view.likewhatsapp

import android.content.Context
import android.graphics.Color
import android.widget.FrameLayout
import androidx.lifecycle.findViewTreeLifecycleOwner
import androidx.lifecycle.lifecycleScope
import io.trtc.tuikit.albumpickercore.AlbumPickerStore
import io.trtc.tuikit.atomicx.albumpicker.view.common.AlbumPickerPreviewViewCommon
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

internal class WhatsAppAlbumPickerPreviewView(
    context: Context,
    private val store: AlbumPickerStore,
) : FrameLayout(context) {
    interface Listener {
        fun onClickSend(textMessage: String? = null)

        fun onAddMore() {}

        fun onDismiss() {}
    }

    var listener: Listener? = null
    private var previewMediasObserverJob: Job? = null

    private val bottomBarListener =
        object : WhatsAppBottomBarView.Listener {
            override fun onClickSend(textMessage: String?) {
                if (store.state.selectedMedias.value.any { !it.isPendingRemoval }) {
                    listener?.onClickSend(textMessage)
                }
            }

            override fun onAddMore() {
                listener?.onAddMore()
            }
        }

    private val headerView: WhatsAppPreviewHeaderView =
        WhatsAppPreviewHeaderView(context, WhatsAppPreviewHeaderView.OnDismissListener { hide() })
    private val bottomBar =
        WhatsAppBottomBarView(context, store, isPreview = true, listener = bottomBarListener)
    private val common =
        AlbumPickerPreviewViewCommon(
            container = this,
            store = store,
            showDeleteButton = true,
            headerView = headerView,
            bottomBarView = bottomBar,
        )

    init {
        setBackgroundColor(Color.BLACK)
    }

    fun show() {
        common.show()
        startObservingPreviewMedias()
    }

    fun hide() {
        stopObservingPreviewMedias()
        common.hide()
        listener?.onDismiss()
    }

    private fun startObservingPreviewMedias() {
        stopObservingPreviewMedias()
        val lifecycleOwner = findViewTreeLifecycleOwner() ?: return
        previewMediasObserverJob =
            lifecycleOwner.lifecycleScope.launch {
                store.state.previewMedias.collect { medias ->
                    if (medias.isEmpty() && visibility == VISIBLE) {
                        hide()
                    }
                }
            }
    }

    private fun stopObservingPreviewMedias() {
        previewMediasObserverJob?.cancel()
        previewMediasObserverJob = null
    }
}
