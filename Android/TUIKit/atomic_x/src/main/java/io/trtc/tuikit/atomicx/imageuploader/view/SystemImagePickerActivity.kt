/*
 * Copyright (c) 2025 Tencent
 * All rights reserved.
 *
 * Author: eddardliu
 */

package io.trtc.tuikit.atomicx.imageuploader.view

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import androidx.activity.OnBackPressedCallback
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import com.tencent.qcloud.tuicore.TUICore
import io.trtc.tuikit.atomicx.imageuploader.CropOverlayShape
import io.trtc.tuikit.atomicx.imageuploader.impl.ImageUploaderImpl
import io.trtc.tuikit.atomicx.imageuploader.util.ImageUploaderUtil
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class SystemImagePickerActivity : AppCompatActivity() {

    companion object {
        private const val CROP_VIEW_ANIMATION_DURATION = 200L
    }

    private lateinit var rootContainer: FrameLayout
    private lateinit var cropViewContainer: FrameLayout

    private var bottomSheetView: ImageSourceBottomSheet? = null
    private var showsCameraItem: Boolean = false
    private var cropOverlayShape: CropOverlayShape = CropOverlayShape.CIRCLE
    private var cameraPhotoUri: Uri? = null

    private val pickMedia: ActivityResultLauncher<PickVisualMediaRequest> =
        registerForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri ->
            if (uri != null) {
                handleImageSelected(uri)
            } else {
                finishWithResult(null)
            }
        }

    private val pickImage: ActivityResultLauncher<Intent> =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            if (result.resultCode == RESULT_OK) {
                result.data?.data?.let { uri ->
                    handleImageSelected(uri)
                } ?: finishWithResult(null)
            } else {
                finishWithResult(null)
            }
        }

    private val takePicture: ActivityResultLauncher<Uri> =
        registerForActivityResult(ActivityResultContracts.TakePicture()) { success ->
            if (success && cameraPhotoUri != null) {
                handleImageSelected(cameraPhotoUri!!)
            } else {
                finishWithResult(null)
            }
        }

    private val requestCameraPermission: ActivityResultLauncher<String> =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            if (granted) {
                launchCamera()
            } else {
                finishWithResult(null)
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )

        if (intent == null) {
            finish()
            return
        }

        parseIntentExtras()
        setupViews()
        setupBackPressedCallback()
        showBottomSheet()
    }

    private fun parseIntentExtras() {
        showsCameraItem = intent.getBooleanExtra(ImageUploaderImpl.EXTRA_SHOWS_CAMERA_ITEM, false)
        val shapeName = intent.getStringExtra(ImageUploaderImpl.EXTRA_CROP_OVERLAY_SHAPE)
        cropOverlayShape = try {
            shapeName?.let { CropOverlayShape.valueOf(it) } ?: CropOverlayShape.CIRCLE
        } catch (_: IllegalArgumentException) {
            CropOverlayShape.CIRCLE
        }
    }

    private fun setupViews() {
        rootContainer = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }

        cropViewContainer = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            visibility = View.GONE
        }

        rootContainer.addView(cropViewContainer)

        if (!showsCameraItem) {
            setContentView(rootContainer)
            return
        }

        bottomSheetView = ImageSourceBottomSheet(this, object : ImageSourceBottomSheet.Listener {
            override fun onCameraClick() {
                bottomSheetView?.hide {
                    if (ContextCompat.checkSelfPermission(this@SystemImagePickerActivity, Manifest.permission.CAMERA)
                            == PackageManager.PERMISSION_GRANTED) {
                        launchCamera()
                    } else {
                        requestCameraPermission.launch(Manifest.permission.CAMERA)
                    }
                }
            }

            override fun onAlbumClick() {
                bottomSheetView?.hide { launchImagePicker() }
            }

            override fun onCancelClick() {
                bottomSheetView?.hide { finishWithResult(null) }
            }
        })
        rootContainer.addView(bottomSheetView)
        
        setContentView(rootContainer)
    }

    private fun showBottomSheet() {
        if (showsCameraItem) {
            bottomSheetView?.show()
        } else {
            launchImagePicker()
        }
    }

    private fun launchCamera() {
        val photoFile = createImageFile()
        cameraPhotoUri = FileProvider.getUriForFile(this, "${packageName}.imageuploader.fileprovider", photoFile)
        takePicture.launch(cameraPhotoUri)
    }

    private fun createImageFile(): File {
        val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
        val storageDir = getExternalFilesDir(Environment.DIRECTORY_PICTURES)
        return File.createTempFile("IMG_${timeStamp}_", ".jpg", storageDir)
    }

    private fun launchImagePicker() {
        if (ActivityResultContracts.PickVisualMedia.isPhotoPickerAvailable(this)) {
            pickMedia.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly))
        } else {
            val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
            pickImage.launch(intent)
        }
    }

    private fun handleImageSelected(uri: Uri) {
        val bitmap = ImageUploaderUtil.loadBitmapFromUri(this, uri)
        if (bitmap != null) {
            showCropView(bitmap)
        } else {
            finishWithResult(null)
        }
    }

    private fun showCropView(bitmap: Bitmap) {
        cropViewContainer.removeAllViews()
        val cropView = ImageCropView(
            context = this, bitmap = bitmap, overlayShape = cropOverlayShape,
            listener = object : ImageCropView.Listener {
                override fun onConfirm(croppedBitmap: Bitmap) {
                    val path = ImageUploaderUtil.saveImageToTempPath(this@SystemImagePickerActivity, croppedBitmap)
                    finishWithResult(path)
                }

                override fun onClose() {
                    hideCropView()
                }
            }
        ).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }

        cropViewContainer.visibility = View.VISIBLE
        cropViewContainer.addView(cropView)
    }

    private fun hideCropView() {
        cropViewContainer.animate()
            .alpha(0f).setDuration(CROP_VIEW_ANIMATION_DURATION).withEndAction { finishWithResult(null)}.start()
    }

    private fun finishWithResult(localPath: String?) {
        val params = HashMap<String, Any>()
        if (localPath != null) {
            params[ImageUploaderImpl.EVENT_PARAM_RESULT_PATH] = localPath
        }
        TUICore.notifyEvent(
            ImageUploaderImpl.EVENT_KEY_SINGLE_IMAGE_PICKER,
            ImageUploaderImpl.EVENT_SUB_KEY_PICK_RESULT,
            params
        )
        finish()
    }

    private fun setupBackPressedCallback() {
        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                when {
                    cropViewContainer.visibility == View.VISIBLE -> hideCropView()
                    bottomSheetView?.visibility == View.VISIBLE -> bottomSheetView?.hide { finishWithResult(null) }
                    else -> finishWithResult(null)
                }
            }
        })
    }
}