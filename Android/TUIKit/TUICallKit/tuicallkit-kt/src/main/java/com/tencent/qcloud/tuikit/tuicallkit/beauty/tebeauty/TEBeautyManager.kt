package com.tencent.qcloud.tuikit.tuicallkit.beauty.tebeauty

import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import com.tencent.cloud.tuikit.engine.call.TUICallEngine
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.interfaces.TUIServiceCallback
import com.tencent.trtc.TRTCCloudDef
import com.tencent.trtc.TRTCCloudListener.TRTCVideoFrameListener
import com.tencent.cloud.tuikit.engine.common.ContextProvider
import java.lang.ref.WeakReference

object TEBeautyManager {
    private const val TE_BEAUTY_EXTENSION = "TEBeautyExtension"

    private var listenerRef: WeakReference<OnBeautyViewListener>? = null
    private var lastParamList: String? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private var isResourceLoaded = false

    private val trtcVideoFrameListener = object : TRTCVideoFrameListener {
        override fun onGLContextCreated() {
            if (isResourceLoaded) {
                mainHandler.post {
                    ContextProvider.getApplicationContext()?.apply { initBeautyKit(this, false) }
                }
            }
        }

        override fun onProcessVideoFrame(
            srcFrame: TRTCCloudDef.TRTCVideoFrame,
            dstFrame: TRTCCloudDef.TRTCVideoFrame
        ): Int {
            val params = mapOf(
                "srcTextureId" to srcFrame.texture.textureId,
                "frameWidth" to srcFrame.width,
                "frameHeight" to srcFrame.height
            )
            dstFrame.texture.textureId = TUICore.callService(TE_BEAUTY_EXTENSION, "processVideoFrame", params) as Int
            return 0
        }

        override fun onGLContextDestory() {
            val lastParam = exportParam()
            destroyBeautyKit()
            mainHandler.post {
                lastParamList = lastParam
                listenerRef?.get()?.onDestroyBeautyView()
            }
        }
    }

    fun isSupportTEBeauty(): Boolean = TUICore.getService(TE_BEAUTY_EXTENSION) != null

    fun setCustomVideoProcess() {
        if (isSupportTEBeauty()) {
            TUICallEngine.createInstance(ContextProvider.getApplicationContext()).trtcCloudInstance.setLocalVideoProcessListener(
                TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D,
                TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE,
                trtcVideoFrameListener
            )
        }
    }

    fun clearBeautyParams() {
        lastParamList = null
    }

    fun setListener(listener: OnBeautyViewListener?) {
        listenerRef = WeakReference(listener)
    }

    fun init(context: Context) {
        createBeautyKit(context)
    }

    private fun createBeautyKit(context: Context) {
        checkBeautyResource(context, object : TUIServiceCallback() {
            override fun onServiceCallback(errorCode: Int, errorMessage: String?, bundle: Bundle?) {
                if (errorCode == 0) {
                    initBeautyKit(context, true)
                }
            }
        })
    }

    private fun initBeautyKit(context: Context, createPanel: Boolean) {
        val params = mapOf(
            "context" to context,
            "lastParamList" to lastParamList
        )
        TUICore.callService(TE_BEAUTY_EXTENSION, "initBeautyKit", params, object : TUIServiceCallback() {
            override fun onServiceCallback(errorCode: Int, errorMessage: String?, bundle: Bundle?) {
                if (errorCode != 0) {
                    return
                }
                if (createPanel) {
                    mainHandler.post {
                        val beautyPanel = createTEBeautyPanel(context)
                        beautyPanel?.let {
                            listenerRef?.get()?.onCreateBeautyView(it)
                        }
                    }
                }
            }
        })
    }

    fun checkBeautyResource(context: Context, callback: TUIServiceCallback? = null) {

        val params = mapOf("context" to context)
        TUICore.callService(TE_BEAUTY_EXTENSION, "checkResource", params, object : TUIServiceCallback() {
            override fun onServiceCallback(errorCode: Int, errorMessage: String?, bundle: Bundle?) {
                isResourceLoaded = true
                callback?.onServiceCallback(errorCode, errorMessage, bundle)
            }
        })
    }

    fun exportParam(): String {
        lastParamList = TUICore.callService(TE_BEAUTY_EXTENSION, "exportParam", null)?.toString() ?: "null"
        return lastParamList ?: ""
    }

    private fun destroyBeautyKit() {
        TUICore.callService(TE_BEAUTY_EXTENSION, "destroyBeautyKit", null)
    }

    private fun createTEBeautyPanel(context: Context): View? {
        val param = mapOf(
            "context" to context,
            "lastParamList" to lastParamList
        )
        return TUICore.getExtensionList("TEBeautyExtension", param)
            .firstNotNullOfOrNull { extensionInfo ->
                (extensionInfo.data["beautyPanel"] as? View)
            }
    }

    interface OnBeautyViewListener {
        fun onCreateBeautyView(view: View)
        fun onDestroyBeautyView()
    }
}
