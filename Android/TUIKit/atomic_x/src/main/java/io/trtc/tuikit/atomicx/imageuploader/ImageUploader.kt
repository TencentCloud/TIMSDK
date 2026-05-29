/*
 * Copyright (c) 2025 Tencent
 * All rights reserved.
 *
 * Author: eddardliu
 */

package io.trtc.tuikit.atomicx.imageuploader

import android.content.Context
import io.trtc.tuikit.atomicx.imageuploader.impl.ImageUploaderImpl

enum class CropOverlayShape {
    CIRCLE,
    RECTANGLE_1_1,
    RECTANGLE_4_3,
    RECTANGLE_3_4,
    RECTANGLE_16_9,
    RECTANGLE_9_16;
}

data class ImageUploaderConfig(
    val showsCameraItem: Boolean = false,
    val cropOverlayShape: CropOverlayShape = CropOverlayShape.CIRCLE
)

interface ImageUploaderListener {
    fun onPickCompleted(localPath: String?)
    fun onCosUploadCompleted(statusCode: Int) {}
}

class ImageUploader(listener: ImageUploaderListener? = null) {
    private val impl = ImageUploaderImpl(listener)

    fun pick(
        context: Context,
        config: ImageUploaderConfig = ImageUploaderConfig(),
        cosUploadURL: String? = null
    ) {
        impl.pick(context, config, cosUploadURL)
    }
}
