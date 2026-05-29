package io.trtc.tuikit.atomicx.albumpicker.view.likewechat

import android.content.Context
import android.widget.FrameLayout
import io.trtc.tuikit.albumpickercore.AlbumPickerStore
import io.trtc.tuikit.atomicx.albumpicker.view.common.AlbumPickerPreviewViewCommon
import io.trtc.tuikit.atomicx.albumpicker.view.common.AlbumPickerThemeInternal

internal class WeChatAlbumPickerPreviewView(
    context: Context,
    private val store: AlbumPickerStore,
) : FrameLayout(context) {
    interface Listener {
        fun onClickSend(textMessage: String? = null)

        fun onDismiss() {}
    }

    var listener: Listener? = null

    private val bottomBarListener =
        object : WeChatBottomBarView.Listener {
            override fun onClickSend() {
                if (store.state.selectedMedias.value.any { !it.isPendingRemoval }) {
                    listener?.onClickSend()
                }
            }
        }

    private val headerView: WeChatPreviewHeaderView =
        WeChatPreviewHeaderView(context, store, WeChatPreviewHeaderView.OnDismissListener { hide() })

    private val bottomBar =
        WeChatBottomBarView(context, store, isPreview = true).apply { this.listener = bottomBarListener }

    private val common =
        AlbumPickerPreviewViewCommon(container = this, store = store,
            headerView = headerView, bottomBarView = bottomBar)

    init {
        setBackgroundColor(AlbumPickerThemeInternal.darkBackground)
    }

    fun show(isPreviewFromSelection: Boolean = false) {
        headerView.isPreviewFromSelection = isPreviewFromSelection
        headerView.startObserving()
        common.show()
    }

    fun hide() {
        headerView.stopObserving()
        common.hide()
        listener?.onDismiss()
    }
}
