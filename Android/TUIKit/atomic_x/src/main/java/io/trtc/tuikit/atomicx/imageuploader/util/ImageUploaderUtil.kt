/*
 * Copyright (c) 2025 Tencent
 * All rights reserved.
 *
 * Author: eddardliu
 */

package io.trtc.tuikit.atomicx.imageuploader.util

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.net.Uri
import android.util.Log
import android.util.TypedValue
import androidx.annotation.WorkerThread
import androidx.exifinterface.media.ExifInterface
import java.io.File
import java.io.FileOutputStream
import java.util.UUID
import kotlin.math.max

internal object ImageUploaderUtil {

    private const val TAG = "ImageUploaderUtil"
    private const val TEMP_DIR_NAME = "ImageUploaderTemp"
    private const val DEFAULT_MAX_DIMENSION = 4096

    // ==================== Public API ====================

    fun dpToPx(context: Context, dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp.toFloat(),
            context.resources.displayMetrics
        ).toInt()
    }

    @WorkerThread
    fun loadBitmapFromUri(
        context: Context,
        uri: Uri,
        maxDimension: Int = DEFAULT_MAX_DIMENSION
    ): Bitmap? {
        return try {
            val bitmap = decodeSampledBitmap(context, uri, maxDimension) ?: return null
            val orientation = getExifOrientation(context, uri)
            applyRotation(bitmap, orientation)
        } catch (e: Exception) {
            Log.e(TAG, "loadBitmapFromUri failed, uri=$uri, msg=${e.message}")
            null
        }
    }

    @WorkerThread
    fun saveImageToTempPath(context: Context, bitmap: Bitmap, quality: Int = 100): String? {
        return try {
            val tempDir = getTempDirectory(context)
            val fileName = "${UUID.randomUUID()}.jpg"
            val file = File(tempDir, fileName)

            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, quality, out)
            }

            file.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "saveImageToTempPath failed, msg=${e.message}")
            null
        }
    }

    // ==================== Private Helpers ====================

    private fun getTempDirectory(context: Context): File {
        val tempDir = File(context.cacheDir, TEMP_DIR_NAME)
        if (!tempDir.exists()) {
            tempDir.mkdirs()
        }
        return tempDir
    }

    private fun decodeSampledBitmap(context: Context, uri: Uri, maxDimension: Int): Bitmap? {
        val options = BitmapFactory.Options()

        options.inJustDecodeBounds = true
        context.contentResolver.openInputStream(uri)?.use { inputStream ->
            BitmapFactory.decodeStream(inputStream, null, options)
        }

        if (options.outWidth <= 0 || options.outHeight <= 0) {
            Log.e(TAG, "decodeSampledBitmap failed to get image dimensions, uri=$uri")
            return null
        }

        options.inSampleSize = calculateInSampleSize(options.outWidth, options.outHeight, maxDimension)
        options.inJustDecodeBounds = false

        return try {
            context.contentResolver.openInputStream(uri)?.use { inputStream ->
                BitmapFactory.decodeStream(inputStream, null, options)
            }
        } catch (e: Exception) {
            Log.e(TAG, "decodeSampledBitmap failed, uri=$uri, msg=${e.message}")
            null
        }
    }

    private fun calculateInSampleSize(width: Int, height: Int, maxDimension: Int): Int {
        val maxSide = max(width, height)
        var inSampleSize = 1

        while (maxSide / inSampleSize > maxDimension) {
            inSampleSize *= 2
        }

        return inSampleSize
    }

    private fun getExifOrientation(context: Context, uri: Uri): Int {
        return try {
            context.contentResolver.openInputStream(uri)?.use { inputStream ->
                val exif = ExifInterface(inputStream)
                exif.getAttributeInt(
                    ExifInterface.TAG_ORIENTATION,
                    ExifInterface.ORIENTATION_NORMAL
                )
            } ?: ExifInterface.ORIENTATION_NORMAL
        } catch (e: Exception) {
            Log.e(TAG, "getExifOrientation failed, uri=$uri, msg=${e.message}")
            ExifInterface.ORIENTATION_NORMAL
        }
    }

    private fun applyRotation(bitmap: Bitmap, orientation: Int): Bitmap {
        val matrix = Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.preScale(-1f, 1f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.preScale(1f, -1f)
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.postRotate(90f)
                matrix.preScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.postRotate(270f)
                matrix.preScale(-1f, 1f)
            }
            else -> return bitmap
        }

        return try {
            Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        } catch (e: Exception) {
            Log.e(TAG, "applyRotation failed, msg=${e.message}")
            bitmap
        }
    }
}
