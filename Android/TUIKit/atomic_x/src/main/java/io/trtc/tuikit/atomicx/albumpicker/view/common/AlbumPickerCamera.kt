package io.trtc.tuikit.atomicx.albumpicker.view.common

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.GradientDrawable
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.MediaStore
import android.view.Gravity
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.ActivityResultRegistry
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.trtc.tuikit.albumpickercore.util.AlbumPickerUtil
import io.trtc.tuikit.atomicx.albumpicker.AlbumMedia
import io.trtc.tuikit.atomicx.albumpicker.AlbumMediaType
import io.trtc.tuikit.atomicx.albumpicker.R
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

internal class AlbumPickerCamera(
    private val context: Context,
    private val registry: ActivityResultRegistry,
    private val isWithImage: Boolean = true,
    private val isWithVideo: Boolean = true,
    private val onCaptureResult: (List<AlbumMedia>) -> Unit,
) {
    companion object {
        private const val OPTION_HEIGHT_DP = 56
        private const val CANCEL_MARGIN_TOP_DP = 8
        private const val THUMBNAIL_QUALITY = 80
        private const val CACHE_DIR_NAME = "album_picker_cache"

        private const val PHOTO_FILE_BASE_NAME = "camera_photo"
        private const val VIDEO_FILE_BASE_NAME = "camera_video"

        private const val KEY_CAMERA_CAPTURE = "album_picker_camera_capture"
        private const val KEY_VIDEO_CAPTURE = "album_picker_video_capture"
        private const val KEY_CAMERA_PERMISSION = "album_picker_camera_permission"
    }

    private val theme = AlbumPickerThemeInternal
    private val dateFormat = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US)
    private var captureOutputUri: Uri? = null
    private var captureOutputPath: String? = null

    private val cameraLauncher: ActivityResultLauncher<Intent> =
        registry.register(KEY_CAMERA_CAPTURE, ActivityResultContracts.StartActivityForResult()) {
            result -> if (result.resultCode != Activity.RESULT_OK) return@register
            val uri = captureOutputUri ?: return@register
            val id = "${System.currentTimeMillis()}_${UUID.randomUUID()}".hashCode().toULong()
            onCaptureResult(listOf(AlbumMedia(id = id, uri = uri, mediaPath = captureOutputPath)))
        }

    private val videoCaptureLauncher: ActivityResultLauncher<Intent> =
        registry.register(KEY_VIDEO_CAPTURE, ActivityResultContracts.StartActivityForResult()) {
            result -> if (result.resultCode != Activity.RESULT_OK) return@register
            val uri = captureOutputUri ?: return@register
            val id = "${System.currentTimeMillis()}_${UUID.randomUUID()}".hashCode().toULong()
            val thumbnailPath = extractVideoThumbnail(captureOutputPath)
            onCaptureResult(
                listOf(
                    AlbumMedia(
                        id = id, uri = uri, mediaPath = captureOutputPath,
                        mediaType = AlbumMediaType.VIDEO, videoThumbnailPath = thumbnailPath,
                    ),
                ),
            )
        }

    private val requestCameraPermissionLauncher: ActivityResultLauncher<String> =
        registry.register(
            KEY_CAMERA_PERMISSION,
            ActivityResultContracts.RequestPermission(),
        ) { granted ->
            if (granted) {
                showCameraOptions()
            }
        }

    fun launch() {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA)
            == PackageManager.PERMISSION_GRANTED
        ) {
            showCameraOptions()
        } else {
            requestCameraPermissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }

    fun unregister() {
        cameraLauncher.unregister()
        videoCaptureLauncher.unregister()
        requestCameraPermissionLauncher.unregister()
    }

    private fun showCameraOptions() {
        if (isWithImage && !isWithVideo) {
            launchPhotoCapture()
            return
        }
        if (isWithVideo && !isWithImage) {
            launchVideoCapture()
            return
        }

        val dialog = android.app.Dialog(context)
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog.setContentView(createDialogContent(dialog))
        dialog.window?.apply {
            setLayout(WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.WRAP_CONTENT)
            setGravity(Gravity.BOTTOM)
            setBackgroundDrawableResource(android.R.color.transparent)
            setWindowAnimations(android.R.style.Animation_InputMethod)
        }
        dialog.show()
    }

    private fun createDialogContent(dialog: android.app.Dialog): LinearLayout {
        val margin = context.resources.getDimensionPixelSize(R.dimen.spacing_8)
        val cancelMarginTop = AlbumPickerUtil.dpToPx(context, CANCEL_MARGIN_TOP_DP)

        val container =
            LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(margin, 0, margin, margin)
            }
        container.addView(createOptionsGroup(dialog))
        container.addView(
            createCancelButton(dialog).apply {
                val lp = layoutParams as LinearLayout.LayoutParams
                lp.topMargin = cancelMarginTop
                layoutParams = lp
            },
        )
        return container
    }

    private fun createRoundedBackground(): GradientDrawable {
        val cornerRadius = AlbumPickerUtil.dpToPx(context, theme.normalRadius).toFloat()
        return GradientDrawable().apply {
            setColor(theme.backgroundColorSecondary)
            this.cornerRadius = cornerRadius
        }
    }

    private fun createOptionsGroup(dialog: android.app.Dialog): LinearLayout {
        val itemHeight = AlbumPickerUtil.dpToPx(context, OPTION_HEIGHT_DP)

        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            background = createRoundedBackground()

            addView(
                createOptionItem(context.getString(R.string.album_picker_take_photo), itemHeight) {
                    dialog.dismiss()
                    launchPhotoCapture()
                },
            )
            addView(createDivider())
            addView(
                createOptionItem(context.getString(R.string.album_picker_record_video), itemHeight) {
                    dialog.dismiss()
                    launchVideoCapture()
                },
            )
        }
    }

    private fun createCancelButton(dialog: android.app.Dialog): TextView {
        val itemHeight = AlbumPickerUtil.dpToPx(context, OPTION_HEIGHT_DP)

        return createOptionItem(context.getString(android.R.string.cancel), itemHeight) {
            dialog.dismiss()
        }.apply {
            background = createRoundedBackground()
        }
    }

    private fun createDivider(): View =
        View(context).apply {
            setBackgroundColor(theme.backgroundColor)
            layoutParams =
                LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    AlbumPickerUtil.dpToPx(context, 1),
                )
        }

    private fun launchPhotoCapture() {
        val file = generateCacheFile(PHOTO_FILE_BASE_NAME, ".jpg")
        captureOutputPath = file.absolutePath
        captureOutputUri =
            FileProvider.getUriForFile(context, "${context.packageName}.albumpicker.fileprovider", file)
        val intent =
            Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, captureOutputUri)
            }
        cameraLauncher.launch(intent)
    }

    private fun launchVideoCapture() {
        val file = generateCacheFile(VIDEO_FILE_BASE_NAME, ".mp4")
        captureOutputPath = file.absolutePath
        captureOutputUri =
            FileProvider.getUriForFile(context, "${context.packageName}.albumpicker.fileprovider", file)
        val intent =
            Intent(MediaStore.ACTION_VIDEO_CAPTURE).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, captureOutputUri)
            }
        videoCaptureLauncher.launch(intent)
    }

    private fun extractVideoThumbnail(videoPath: String?): String? {
        videoPath ?: return null
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(videoPath)
            val frame =
                retriever.getFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                    ?: return null
            val thumbFile = generateCacheFile(VIDEO_FILE_BASE_NAME, "_thumb.jpg")
            FileOutputStream(thumbFile).use {
                frame.compress(Bitmap.CompressFormat.JPEG, THUMBNAIL_QUALITY, it)
            }
            frame.recycle()
            thumbFile.absolutePath
        } catch (_: Exception) {
            null
        } finally {
            retriever.release()
        }
    }

    private fun generateCacheFile(baseName: String, ext: String): File {
        val timestamp = dateFormat.format(Date())
        return File(ensureCacheDir(), "${timestamp}_${baseName}_${UUID.randomUUID()}$ext")
    }

    private fun ensureCacheDir(): File =
        File(context.cacheDir, CACHE_DIR_NAME).also {
            if (!it.exists()) {
                it.mkdirs()
            }
        }

    private fun createOptionItem(text: String, height: Int, onClick: () -> Unit): TextView =
        TextView(context).apply {
            this.text = text
            textSize = theme.bigFontSize
            setTextColor(theme.textColor)
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height)
            setOnClickListener { onClick() }
        }
}
