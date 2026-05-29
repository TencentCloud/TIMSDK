/*
 * Copyright (c) 2025 Tencent
 * All rights reserved.
 *
 * Author: eddardliu
 */

package io.trtc.tuikit.atomicx.imageuploader.impl

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.interfaces.ITUINotification
import io.trtc.tuikit.atomicx.imageuploader.ImageUploaderConfig
import io.trtc.tuikit.atomicx.imageuploader.ImageUploaderListener
import io.trtc.tuikit.atomicx.imageuploader.util.ImageCosUploaderManager
import io.trtc.tuikit.atomicx.imageuploader.view.SystemImagePickerActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

internal class ImageUploaderImpl(private val listener: ImageUploaderListener?) : ITUINotification {

    companion object {
        internal const val EXTRA_SHOWS_CAMERA_ITEM = "shows_camera_item"
        internal const val EXTRA_CROP_OVERLAY_SHAPE = "crop_overlay_shape"

        internal const val EVENT_KEY_SINGLE_IMAGE_PICKER = "event_key_image_uploader"
        internal const val EVENT_SUB_KEY_PICK_RESULT = "event_sub_key_pick_result"
        internal const val EVENT_PARAM_RESULT_PATH = "result_path"
    }

    private var cosUploadURL: String? = null
    private val uploadManager = ImageCosUploaderManager()
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    fun pick(context: Context, config: ImageUploaderConfig, cosUploadURL: String?) {
        this.cosUploadURL = cosUploadURL
        TUICore.registerEvent(EVENT_KEY_SINGLE_IMAGE_PICKER, EVENT_SUB_KEY_PICK_RESULT, this)

        val intent = Intent(context, SystemImagePickerActivity::class.java).apply {
            putExtra(EXTRA_SHOWS_CAMERA_ITEM, config.showsCameraItem)
            putExtra(EXTRA_CROP_OVERLAY_SHAPE, config.cropOverlayShape.name)
            if (context !is Activity) {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        }
        context.startActivity(intent)
    }

    override fun onNotifyEvent(key: String?, subKey: String?, param: MutableMap<String, Any>?) {
        if (key != EVENT_KEY_SINGLE_IMAGE_PICKER || subKey != EVENT_SUB_KEY_PICK_RESULT) {
            return
        }

        TUICore.unRegisterEvent(EVENT_KEY_SINGLE_IMAGE_PICKER, EVENT_SUB_KEY_PICK_RESULT, this)
        val localPath = param?.get(EVENT_PARAM_RESULT_PATH) as? String
        listener?.onPickCompleted(localPath)

        if (!localPath.isNullOrEmpty() && !cosUploadURL.isNullOrEmpty()) {
            scope.launch {
                val statusCode = uploadManager.uploadFile(localPath, cosUploadURL!!)
                listener?.onCosUploadCompleted(statusCode)
            }
        }
    }
}
