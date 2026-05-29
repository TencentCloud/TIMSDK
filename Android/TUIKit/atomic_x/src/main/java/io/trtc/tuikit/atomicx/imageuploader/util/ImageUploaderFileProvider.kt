/*
 * Copyright (c) 2025 Tencent
 * All rights reserved.
 *
 * Author: eddardliu
 */

package io.trtc.tuikit.atomicx.imageuploader.util

import androidx.core.content.FileProvider

/**
 * Custom FileProvider for ImageUploaderFile module to avoid manifest merger conflicts.
 */
internal class ImageUploaderFileProvider : FileProvider()
