package io.trtc.tuikit.atomicx.albumpicker.view.common

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.graphics.Typeface
import android.net.Uri
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.lifecycle.findViewTreeLifecycleOwner
import androidx.lifecycle.lifecycleScope
import io.trtc.tuikit.albumpickercore.AlbumListView
import io.trtc.tuikit.albumpickercore.AlbumPickerMediaGridConfig
import io.trtc.tuikit.albumpickercore.AlbumPickerMediaGridView
import io.trtc.tuikit.albumpickercore.AlbumPickerStore
import io.trtc.tuikit.albumpickercore.store.AlbumMediaModel
import io.trtc.tuikit.albumpickercore.store.AlbumPickerMediaProcessListener
import io.trtc.tuikit.albumpickercore.store.AlbumPickerMediaType
import io.trtc.tuikit.albumpickercore.store.SelectedMediaItem
import io.trtc.tuikit.albumpickercore.util.AlbumPickerUtil
import io.trtc.tuikit.atomicx.albumpicker.AlbumMedia
import io.trtc.tuikit.atomicx.albumpicker.AlbumMediaType
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerConfig
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerListener
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerMediaFilter
import io.trtc.tuikit.atomicx.albumpicker.AlbumPickerStyle
import io.trtc.tuikit.atomicx.albumpicker.R
import io.trtc.tuikit.atomicx.albumpicker.util.AlbumPickerPermissionRequester
import io.trtc.tuikit.atomicx.albumpicker.util.AlbumPickerWindowHelper
import io.trtc.tuikit.atomicx.albumpicker.util.PermissionState
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

internal class AlbumPickerMainViewCommon(
    private val context: Context,
    private val store: AlbumPickerStore,
    private val contentView: LinearLayout,
    private val config: AlbumPickerConfig,
    private val albumPickerListener: AlbumPickerListener?,
) {
    interface Listener {
        fun onShowPreview(isPreviewFromSelection: Boolean)
    }

    companion object {
        private const val BANNER_ICON_SIZE_DP = 16
        private const val DEFAULT_MAX_SELECTION_COUNT = 99
        private const val MIN_ITEMS_PER_ROW = 2
        private const val MAX_ITEMS_PER_ROW = 5
    }

    var listener: Listener? = null

    private val isWithVideo = config.mediaFilter != AlbumPickerMediaFilter.IMAGE_ONLY
    private val isWithImage = config.mediaFilter != AlbumPickerMediaFilter.VIDEO_ONLY
    private val theme = AlbumPickerThemeInternal
    private var tapMediaToSelect: Boolean = false
    private val activity = context as? Activity

    private fun defaultItemsPerRow(): Int = when (config.style) {
        AlbumPickerStyle.LIKE_WHATSAPP -> 3
        AlbumPickerStyle.LIKE_WECHAT -> 4
    }

    private lateinit var headerLayout: FrameLayout
    private lateinit var selectMoreBanner: LinearLayout
    private lateinit var settingsBanner: LinearLayout
    private lateinit var mediaGridView: AlbumPickerMediaGridView

    private var bottomBarView: View? = null
    private var albumListViewFactory: ((topOffset: Int) -> AlbumListView)? = null
    private var albumListView: AlbumListView? = null

    private var camera: AlbumPickerCamera? = null
    private var permissionRequester: AlbumPickerPermissionRequester? = null
    private val capturedMediaIds: MutableSet<String> = mutableSetOf()
    private var selectionObserverJob: Job? = null

    fun setup(
        bottomBarView: View? = null,
        albumListViewFactory: ((topOffset: Int) -> AlbumListView)? = null,
        tapMediaToSelect: Boolean = false,
    ) {
        this.tapMediaToSelect = tapMediaToSelect
        this.bottomBarView = bottomBarView
        this.albumListViewFactory = albumListViewFactory
        registerActivityResultLaunchers()
        setupViews()
    }

    fun onAttachedToWindow() {
        loadAlbumsWithPermissionCheck()
        AlbumPickerWindowHelper.applyNavigationBarColor(activity, theme.backgroundColor)
        startObservingSelectionLimit()
    }

    fun onDetachedFromWindow() {
        camera?.unregister()
        permissionRequester?.unregister()
        selectionObserverJob?.cancel()
        selectionObserverJob = null
        AlbumPickerWindowHelper.restoreNavigationBarColor(activity)
    }

    fun handleBackPressed(): Boolean = albumListView?.tryDismissPopupPanel() == true

    fun deliverResult(textMessage: String? = null) {
        clearCapturedMediaIds()
        val selectedMedias = store.state.selectedMedias.value.filter { !it.isPendingRemoval }
        store.updateSelectedMedias(selectedMedias)
        val albumMedias = selectedMedias.map { convertToAlbumMedia(it) }

        val scope = contentView.findViewTreeLifecycleOwner()?.lifecycleScope
        albumPickerListener?.onPickConfirm(albumMedias, textMessage)

        scope?.launch(Dispatchers.IO) {
            store.processSelectedMedias(createMediaProcessListener(albumMedias))
        }
    }

    fun removeCapturedMedias() {
        if (capturedMediaIds.isEmpty()) return
        val currentSelected = store.state.selectedMedias.value
        store.updateSelectedMedias(currentSelected.filter { it.media.id !in capturedMediaIds })
        capturedMediaIds.clear()
    }

    private fun convertToAlbumMedia(item: SelectedMediaItem): AlbumMedia {
        val isVideo = item.media.type == AlbumPickerMediaType.VIDEO
        return AlbumMedia(
            id = item.media.id.toULongOrNull() ?: 0u,
            uri = item.media.uri,
            mediaType = if (isVideo) AlbumMediaType.VIDEO else AlbumMediaType.IMAGE,
            duration = item.media.duration.toLong(),
        )
    }

    private fun createMediaProcessListener(albumMedias: List<AlbumMedia>):
        AlbumPickerMediaProcessListener = object : AlbumPickerMediaProcessListener {
            override fun onMediaProcessing(media: AlbumMediaModel, progress: Float, error: Boolean) {
                val albumMedia = albumMedias.find { it.id == (media.id.toULongOrNull() ?: 0u) } ?: return
                albumMedia.mediaPath = media.mediaPath
                albumMedia.videoThumbnailPath = media.videoThumbnailPath
                albumPickerListener?.onMediaProcessing(albumMedia, progress, error)
            }

            override fun onMediaProcessed() {
                albumPickerListener?.onMediaProcessed()
            }
        }

    private fun registerActivityResultLaunchers() {
        val registry = (context as? ComponentActivity)?.activityResultRegistry ?: return

        camera =
            AlbumPickerCamera(
                context, registry,
                isWithImage = isWithImage, isWithVideo = isWithVideo,
                onCaptureResult = ::onCameraCaptureResult,
            )

        permissionRequester =
            AlbumPickerPermissionRequester(registry, context) {
                updateLimitedAccessBanner()
                store.loadAllAlbums(isWithVideo = isWithVideo, isWithImage = isWithImage)
            }
    }

    private fun onCameraCaptureResult(medias: List<AlbumMedia>) {
        val capturedMediaModels = medias.map { convertToAlbumMediaModel(it) }
        capturedMediaModels.forEach { capturedMediaIds.add(it.id) }
        val currentSelected = store.state.selectedMedias.value
        val newItems = capturedMediaModels.map { SelectedMediaItem(media = it, isPendingRemoval = false) }
        store.updateSelectedMedias(currentSelected + newItems)

        val selected = store.state.selectedMedias.value.map { it.media }
        if (selected.isEmpty()) return
        store.updateCurrentPreviewMedia(capturedMediaModels.first())
        store.updatePreviewMedias(selected)
        listener?.onShowPreview(isPreviewFromSelection = true)
    }

    private fun setupViews() {
        setupHeader()
        setupBanners()
        setupMediaGridView()

        contentView.addView(headerLayout)
        contentView.addView(selectMoreBanner)
        contentView.addView(mediaGridView)
        contentView.addView(settingsBanner)
        bottomBarView?.let { contentView.addView(it) }
    }

    private fun setupHeader() {
        val spacing = context.resources.getDimensionPixelSize(R.dimen.spacing_8)

        headerLayout =
            FrameLayout(context).apply {
                layoutParams =
                    LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                    )
                setPadding(
                    spacing, AlbumPickerWindowHelper.getStatusBarHeight(context) + spacing,
                    spacing, spacing,
                )
            }

        val iconSize = context.resources.getDimensionPixelSize(R.dimen.spacing_24)
        val closeButton =
            ImageView(context).apply {
                setImageResource(R.drawable.album_picker_ic_close)
                setColorFilter(theme.textColor)
                layoutParams =
                    FrameLayout.LayoutParams(iconSize, iconSize)
                        .apply { gravity = Gravity.START or Gravity.CENTER_VERTICAL }
                setOnClickListener { albumPickerListener?.onCancel() }
            }
        headerLayout.addView(closeButton)
        headerLayout.post { setupAlbumListView() }
    }

    private fun setupAlbumListView() {
        val topOffset = headerLayout.bottom
        val dm = context.resources.displayMetrics

        val albumListView =
            albumListViewFactory?.invoke(topOffset)
                ?: AlbumListView(context, store, Rect(0, topOffset, dm.widthPixels, dm.heightPixels))

        this.albumListView = albumListView
        headerLayout.addView(albumListView)
    }

    private fun setupBanners() {
        val iconTextSpacing = context.resources.getDimensionPixelSize(R.dimen.spacing_4)
        val iconIconSpacing = context.resources.getDimensionPixelSize(R.dimen.spacing_8)

        selectMoreBanner =
            createBannerItem(
                R.drawable.album_picker_ic_warning,
                R.string.album_picker_select_more_photos,
                iconTextSpacing,
                iconIconSpacing,
            ) {
                permissionRequester?.requestPermissions()
            }.apply { visibility = View.GONE }

        settingsBanner =
            createBannerItem(
                R.drawable.album_picker_ic_settings,
                R.string.album_picker_go_to_settings,
                iconTextSpacing,
                iconIconSpacing,
            ) {
                context.startActivity(
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.fromParts("package", context.packageName, null)
                    },
                )
            }.apply { visibility = View.GONE }
    }

    private fun setupMediaGridView() {
        mediaGridView =
            AlbumPickerMediaGridView(
                context = context, store = store,
                config =
                    AlbumPickerMediaGridConfig(
                        itemsPerRow = (config.itemsPerRow ?: defaultItemsPerRow()).
                        coerceIn(MIN_ITEMS_PER_ROW, MAX_ITEMS_PER_ROW),
                        showsCameraItem = config.showsCameraItem,
                        tapToSelect = tapMediaToSelect,
                    ),
                listener = mediaGridListener,
            ).apply {
                layoutParams =
                    LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f)
                clipToPadding = false
            }
    }

    private val mediaGridListener =
        object : AlbumPickerMediaGridView.Listener {
            override fun onCameraClick() {
                camera?.launch()
            }

            override fun onImageClick(mediaModel: AlbumMediaModel) {
                val previewMedias = store.state.currentAlbum.value.mediaModels
                store.updateCurrentPreviewMedia(mediaModel)
                store.updatePreviewMedias(previewMedias)
                listener?.onShowPreview(isPreviewFromSelection = false)
            }
        }

    private fun loadAlbumsWithPermissionCheck() {
        val permissionState = permissionRequester?.currentPermissionState() ?: return
        val notDetermined = permissionState == PermissionState.NOT_DETERMINED
        val limited =
            permissionState == PermissionState.LIMITED || permissionState == PermissionState.DENIED
        val photoPickerAvail = ActivityResultContracts.PickVisualMedia.isPhotoPickerAvailable(context)

        if (notDetermined || (!photoPickerAvail && limited)) {
            permissionRequester?.requestPermissions()
        } else {
            updateLimitedAccessBanner()
            store.loadAllAlbums(isWithVideo = isWithVideo, isWithImage = isWithImage)
        }
    }

    private fun updateLimitedAccessBanner() {
        val permissionState = permissionRequester?.currentPermissionState() ?: return
        val limited =
            permissionState == PermissionState.LIMITED || permissionState == PermissionState.DENIED
        val photoPickerAvail = ActivityResultContracts.PickVisualMedia.isPhotoPickerAvailable(context)

        if (!limited) {
            selectMoreBanner.visibility = View.GONE
            settingsBanner.visibility = View.GONE
            return
        }

        selectMoreBanner.visibility = if (photoPickerAvail) View.VISIBLE else View.GONE
        settingsBanner.visibility = View.VISIBLE
        repositionSettingsBanner(photoPickerAvail)
    }

    private fun repositionSettingsBanner(photoPickerAvail: Boolean) {
        contentView.removeView(settingsBanner)
        val insertIndex =
            if (photoPickerAvail) {
                findInsertIndexBeforeBottomBar()
            } else {
                contentView.indexOfChild(selectMoreBanner) + 1
            }
        contentView.addView(settingsBanner, insertIndex)
    }

    private fun findInsertIndexBeforeBottomBar(): Int {
        val bottomBar = bottomBarView ?: return contentView.childCount
        val index = contentView.indexOfChild(bottomBar)
        return if (index >= 0) index else contentView.childCount
    }

    private fun clearCapturedMediaIds() {
        capturedMediaIds.clear()
    }

    private fun startObservingSelectionLimit() {
        val maxCount = config.maxSelectionCount ?: DEFAULT_MAX_SELECTION_COUNT
        val lifecycleOwner = contentView.findViewTreeLifecycleOwner() ?: return
        selectionObserverJob?.cancel()
        selectionObserverJob =
            lifecycleOwner.lifecycleScope.launch {
                store.state.selectedMedias.collect { selectedItems ->
                    if (selectedItems.size > maxCount) {
                        store.updateSelectedMedias(selectedItems.take(maxCount))
                    }
                }
            }
    }

    private fun convertToAlbumMediaModel(albumMedia: AlbumMedia): AlbumMediaModel =
        AlbumMediaModel(
            id = albumMedia.id.toString(),
            uri = albumMedia.uri ?: Uri.EMPTY,
            type =
                if (albumMedia.mediaType == AlbumMediaType.VIDEO)
                    AlbumPickerMediaType.VIDEO else AlbumPickerMediaType.PHOTO,
            mediaPath = albumMedia.mediaPath,
            videoThumbnailPath = albumMedia.videoThumbnailPath,
        )

    private fun createBannerItem(
        iconRes: Int,
        textRes: Int,
        iconTextSpacing: Int,
        iconIconSpacing: Int,
        onClick: () -> Unit,
    ): LinearLayout {
        val vPad = context.resources.getDimensionPixelSize(R.dimen.spacing_8)
        val banner =
            LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setBackgroundColor(theme.backgroundColorSecondary)
                setPadding(iconIconSpacing, vPad, iconIconSpacing, vPad)
                layoutParams =
                    LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                    )
                setOnClickListener { onClick() }
            }
        banner.addView(createBannerIcon(iconRes))
        banner.addView(createBannerText(textRes, iconTextSpacing))
        return banner
    }

    private fun createBannerIcon(iconRes: Int): ImageView {
        val s = AlbumPickerUtil.dpToPx(context, BANNER_ICON_SIZE_DP)
        return ImageView(context).apply {
            setImageResource(iconRes)
            setColorFilter(theme.textColorSecondary)
            layoutParams = LinearLayout.LayoutParams(s, s)
        }
    }

    private fun createBannerText(textRes: Int, marginStart: Int): TextView =
        TextView(context).apply {
            setText(textRes)
            setTextColor(theme.textColorSecondary)
            textSize = theme.smallFontSize
            typeface = Typeface.DEFAULT_BOLD
            layoutParams =
                LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
                    .apply { this.marginStart = marginStart }
        }
}
