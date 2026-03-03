package io.trtc.tuikit.atomicx.callview.public.controls

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import com.tencent.cloud.tuikit.engine.call.TUICallEngine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.qcloud.tuicore.permission.PermissionCallback
import com.trtc.tuikit.common.imageloader.ImageLoader
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.callview.core.common.Constants.BLUR_LEVEL_CLOSE
import io.trtc.tuikit.atomicx.callview.core.common.Constants.BLUR_LEVEL_HIGH
import io.trtc.tuikit.atomicx.callview.core.common.utils.Logger
import io.trtc.tuikit.atomicx.callview.core.common.utils.PermissionRequest
import io.trtc.tuikit.atomicx.callview.core.common.widget.ControlButton
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.device.DeviceStatus
import io.trtc.tuikit.atomicxcore.api.device.DeviceStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class VideoCallerWaitingView(context: Context) : RelativeLayout(context) {
    private var subscribeStateJob: Job? = null

    private lateinit var buttonCancel: ControlButton
    private lateinit var buttonSwitchCamera: ControlButton
    private lateinit var buttonCamera: ControlButton
    private lateinit var buttonBlurBackground: ControlButton

    private var isEnableBlurBackground:Boolean = false

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        this.layoutParams?.width = LayoutParams.MATCH_PARENT
        this.layoutParams?.height = LayoutParams.MATCH_PARENT
        initView()
        registerCameraObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        subscribeStateJob?.cancel()
    }

    private fun registerCameraObserver() {
        subscribeStateJob = CoroutineScope(Dispatchers.Main).launch {
            DeviceStore.shared().deviceState.cameraStatus.collect { cameraStatus ->
                val isCameraOpened = (cameraStatus == DeviceStatus.ON)
                buttonCamera.imageView.isActivated = isCameraOpened
            }
        }
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.callview_function_view_video_inviting, this)
        buttonCancel = findViewById(R.id.cb_cancel)
        buttonCamera = findViewById(R.id.cb_camera)
        buttonSwitchCamera = findViewById(R.id.cb_switch_camera)
        buttonBlurBackground = findViewById(R.id.cb_blur)

        buttonSwitchCamera.visibility = VISIBLE
        buttonCamera.visibility = VISIBLE

        val isCameraOpened = DeviceStore.shared().deviceState.cameraStatus.value == DeviceStatus.ON
        buttonCamera.imageView.isActivated = isCameraOpened
        initViewListener()
    }

    private fun initViewListener() {
        buttonCancel.setOnClickListener {
            buttonCancel.imageView.roundPercent = 1.0f
            buttonCancel.imageView.setBackgroundColor(ContextCompat.getColor(context, R.color.callview_button_bg_red))
            ImageLoader.loadGif(context, buttonCancel.imageView, R.drawable.callview_hangup_loading)
            disableButton(buttonCamera)
            disableButton(buttonSwitchCamera)
            disableButton(buttonBlurBackground)
            CallStore.shared.hangup(null)
        }
        buttonSwitchCamera.setOnClickListener {
            if (!buttonSwitchCamera.isEnabled) {
                return@setOnClickListener
            }
            val isFrontCamera = DeviceStore.shared().deviceState.isFrontCamera.value
            DeviceStore.shared().switchCamera(!isFrontCamera)
        }
        buttonCamera.setOnClickListener {
            if (!buttonCamera.isEnabled) {
                return@setOnClickListener
            }
            val isCameraOpened = (DeviceStore.shared().deviceState.cameraStatus.value == DeviceStatus.ON)
            buttonCamera.imageView.isActivated = !isCameraOpened
            buttonSwitchCamera.imageView.isActivated = !isCameraOpened
            buttonBlurBackground.imageView.isActivated = !isCameraOpened

            if (isCameraOpened) {
                DeviceStore.shared().closeLocalCamera()
                buttonCamera.textView.text = context.resources.getString(R.string.callview_toast_disable_camera)
            } else {
                openLocalCamera()
            }
        }
        buttonBlurBackground.setOnClickListener {
            if (!buttonBlurBackground.isEnabled) {
                return@setOnClickListener
            }
            enableBlurBackground(!isEnableBlurBackground)
        }
    }

    private fun disableButton(button: View) {
        button.isEnabled = false
        button.alpha = 0.8f
    }

    private fun enableBlurBackground(enable: Boolean) {
        Logger.i("setBlurBackground, enable: $enable")
        val level = if (enable) BLUR_LEVEL_HIGH else BLUR_LEVEL_CLOSE
        buttonBlurBackground.isActivated = enable
        isEnableBlurBackground = enable
        TUICallEngine.createInstance(context).setBlurBackground(level, object : TUICommonDefine.Callback {
            override fun onSuccess() {
                Logger.i("setBlurBackground success.")
            }

            override fun onError(errCode: Int, errMsg: String?) {
                buttonBlurBackground.isActivated = false
                isEnableBlurBackground = false
                Logger.e("setBlurBackground failed, errCode: $errCode, errMsg: $errMsg")
            }
        })
    }

    private fun openLocalCamera() {
        PermissionRequest.requestCameraPermission(context, object : PermissionCallback() {
            override fun onGranted() {
                val isFrontCamera = DeviceStore.shared().deviceState.isFrontCamera.value
                DeviceStore.shared().openLocalCamera(isFrontCamera, null)
                buttonCamera.textView.text = context.resources.getString(R.string.callview_toast_enable_camera)
            }

            override fun onDenied() {
                Logger.e("openCamera failed, errMsg: camera permission denied")
            }
        })
    }
}