package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.component

import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.target.CustomTarget
import com.bumptech.glide.request.target.Target
import com.bumptech.glide.request.transition.Transition
import com.tencent.qcloud.tuicore.util.ToastUtil
import com.tencent.qcloud.tuikit.timcommon.component.photoview.PhotoView
import com.tencent.qcloud.tuikit.tuichat.util.FileUtil
import com.tencent.qcloud.tuikit.tuichat.util.PermissionHelper
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.R
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.util.TUIOfficialAccountLog
import java.io.File
import kotlin.concurrent.thread

class ImagePreviewActivity : AppCompatActivity() {

    companion object {
        private const val TAG = "ImagePreviewActivity"
        const val EXTRA_IMAGE_URL = "extra_image_url"
    }

    private lateinit var photoView: PhotoView
    private lateinit var downloadButton: ImageView
    private lateinit var progressBar: ProgressBar

    private var imageUrl: String? = null
    private var originalDownloadCallback: CustomTarget<Bitmap>? = null
    private var isSavingImage = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.official_account_activity_image_browse)

        photoView = findViewById(R.id.photo_view)
        downloadButton = findViewById(R.id.download_button)
        progressBar = findViewById(R.id.loading_progress)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        imageUrl = intent.getStringExtra(EXTRA_IMAGE_URL)
        if (imageUrl.isNullOrEmpty()) {
            Toast.makeText(this, R.string.official_account_load_official_account_info_failed, Toast.LENGTH_SHORT).show()
            finish()
            return
        }

        downloadButton.visibility = View.INVISIBLE
        downloadButton.isEnabled = false

        loadImage()
        initListeners()
    }

    private fun loadImage() {
        progressBar.visibility = View.VISIBLE
        Glide.with(this)
            .load(imageUrl)
            .diskCacheStrategy(DiskCacheStrategy.ALL)
            .listener(object : RequestListener<Drawable> {
                override fun onLoadFailed(
                    e: GlideException?,
                    model: Any?,
                    target: Target<Drawable>?,
                    isFirstResource: Boolean
                ): Boolean {
                    onLoadFailed(e?.message)
                    return false
                }

                override fun onResourceReady(
                    resource: Drawable?,
                    model: Any?,
                    target: Target<Drawable>?,
                    dataSource: DataSource?,
                    isFirstResource: Boolean
                ): Boolean {
                    progressBar.visibility = View.GONE
                    downloadButton.visibility = View.VISIBLE
                    downloadButton.isEnabled = true
                    return false
                }
            })
            .into(photoView)
    }


    private fun downloadImageToGallery() {
        if (imageUrl.isNullOrEmpty() || isSavingImage) {
            return
        }

        val startDownload = {
            isSavingImage = true
            downloadButton.isEnabled = false
            progressBar.visibility = View.VISIBLE

            originalDownloadCallback = object : CustomTarget<Bitmap>(SIZE_ORIGINAL, SIZE_ORIGINAL) {
                override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                    saveBitmapAsync(resource)
                }

                override fun onLoadCleared(placeholder: Drawable?) {}

                override fun onLoadFailed(errorDrawable: Drawable?) {
                    onSaveFinished(false)
                }
            }

            Glide.with(this).asBitmap().load(imageUrl).into(originalDownloadCallback!!)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startDownload()
        } else {
            PermissionHelper.requestPermission(
                PermissionHelper.PERMISSION_STORAGE,
                object : PermissionHelper.PermissionCallback {
                    override fun onGranted() {
                        startDownload()
                    }

                    override fun onDenied() {
                        ToastUtil.toastShortMessage(getString(com.tencent.qcloud.tuikit.tuichat.R.string.save_failed))
                    }
                })
        }
    }

    private fun saveBitmapAsync(bitmap: Bitmap) {
        thread {
            val pngPath = saveBitmapAsPng(bitmap)
            val success = pngPath?.let { FileUtil.saveImageToGallery(this, it) } ?: false
            runOnUiThread {
                onSaveFinished(success)
            }
        }
    }

    private fun saveBitmapAsPng(bitmap: Bitmap): String? {
        return try {
            val outputDir = File(cacheDir, "official_preview")
            if (!outputDir.exists()) {
                outputDir.mkdirs()
            }
            val outputFile = File(outputDir, "preview_${System.currentTimeMillis()}.png")
            outputFile.outputStream().use { fos ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, fos)
            }
            outputFile.absolutePath
        } catch (e: Exception) {
            TUIOfficialAccountLog.e(TAG, "saveBitmapAsPng failed: ${e.message}")
            null
        }
    }

    private fun onSaveFinished(success: Boolean) {
        progressBar.visibility = View.GONE
        isSavingImage = false
        originalDownloadCallback = null
        downloadButton.isEnabled = true
        if (success) {
            ToastUtil.toastShortMessage(getString(com.tencent.qcloud.tuikit.tuichat.R.string.save_success))
        } else {
            ToastUtil.toastShortMessage(getString(com.tencent.qcloud.tuikit.tuichat.R.string.save_failed))
        }
    }

    private fun initListeners() {
        downloadButton.setOnClickListener { downloadImageToGallery() }
    }

    private fun onLoadFailed(message: String?) {
        progressBar.visibility = View.GONE
        Toast.makeText(this, R.string.official_account_load_official_account_info_failed, Toast.LENGTH_SHORT).show()
        TUIOfficialAccountLog.e(TAG, "Load failed: $message")
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        originalDownloadCallback?.let { Glide.with(this).clear(it) }
        originalDownloadCallback = null
    }
}
