package io.trtc.tuikit.atomicx.floatwindow

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import io.trtc.tuikit.atomicx.common.permission.PermissionRequester
import com.tencent.cloud.tuikit.engine.common.ContextProvider
import io.trtc.tuikit.atomicx.common.util.ScreenUtil
import io.trtc.tuikit.atomicx.common.util.TUIBuild
import java.util.concurrent.CopyOnWriteArrayList
import kotlin.math.abs

class FloatWindowManager private constructor() {

    companion object {
        private const val CLICK_ACTION_MAX_MOVE_DISTANCE_PX = 10
        private val VIEW_MARGIN_EDGE_PX = ScreenUtil.dip2px(10f)

        @Volatile
        private var sInstance: FloatWindowManager? = null

        @JvmStatic
        fun sharedInstance(): FloatWindowManager {
            return sInstance ?: synchronized(FloatWindowManager::class.java) {
                sInstance ?: FloatWindowManager().also { sInstance = it }
            }
        }
    }

    private val appContext: Context? = ContextProvider.getApplicationContext()
    private var rootView: FrameLayout? = null
    private var windowManager: WindowManager? = null
    private var windowLayoutParams: WindowManager.LayoutParams? = null
    private var originalLayoutParams: WindowManager.LayoutParams? = null
    private val observerList: MutableList<FloatWindowObserver> = CopyOnWriteArrayList()
    private var orientationReceiver: OrientationReceiver? = null

    private var touchDownPointX: Float = 0f
    private var touchDownPointY: Float = 0f
    private var currentTouchX: Float = 0f
    private var currentTouchY: Float = 0f

    private var isActionDrag: Boolean = false
    private var isShowing: Boolean = false

    fun addObserver(observer: FloatWindowObserver?) {
        if (observer == null || observerList.contains(observer)) {
            return
        }
        observerList.add(observer)
    }

    fun removeObserver(observer: FloatWindowObserver?) {
        if (observer == null) {
            return
        }
        observerList.remove(observer)
    }

    fun show(floatView: View) {
        if (isShowing) {
            return
        }
        val requester = PermissionRequester.newInstance(PermissionRequester.FLOAT_PERMISSION)
        if (!requester.has()) {
            requester.request()
            return
        }
        isShowing = true
        rootView = FrameLayout(appContext!!).apply {
            setOnTouchListener(FloatRootViewTouchListener())
            addView(floatView)
        }
        windowManager = appContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        updateWindowLayoutParams()
        windowManager?.addView(rootView, windowLayoutParams)
        registerReceiver()
    }

    fun dismiss() {
        if (!isShowing) {
            return
        }
        unregisterReceiver()
        isShowing = false
        rootView?.let {
            it.removeAllViews()
            windowManager?.removeView(it)
            rootView = null
        }
    }

    fun isShowing(): Boolean {
        return isShowing
    }

    fun isPictureInPictureSupported(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false
        }
        return appContext?.packageManager?.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE) == true
    }

    private fun updateWindowLayoutParams() {
        windowLayoutParams = WindowManager.LayoutParams().apply {
            type = if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_PHONE
            }
            flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS

            gravity = Gravity.RIGHT or Gravity.TOP
            x = VIEW_MARGIN_EDGE_PX
            y = ScreenUtil.getScreenHeight(appContext!!) / 4
            width = WindowManager.LayoutParams.WRAP_CONTENT
            height = WindowManager.LayoutParams.WRAP_CONTENT
            format = PixelFormat.TRANSPARENT
        }
    }

    private inner class FloatRootViewTouchListener : View.OnTouchListener {
        override fun onTouch(v: View, event: MotionEvent): Boolean {
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    touchDownPointX = event.rawX
                    touchDownPointY = event.rawY
                    currentTouchX = touchDownPointX
                    currentTouchY = touchDownPointY

                    originalLayoutParams = windowLayoutParams
                    isActionDrag = false
                }

                MotionEvent.ACTION_MOVE -> {
                    windowLayoutParams?.let {
                        it.x += (currentTouchX - event.rawX).toInt()
                        it.y += (event.rawY - currentTouchY).toInt()
                    }

                    updateLayout()
                    updateFlagOfDragAction(event.rawX, event.rawY)
                    currentTouchX = event.rawX
                    currentTouchY = event.rawY
                }

                MotionEvent.ACTION_UP -> {
                    if (isActionDrag) {
                        autoMoveToScreenEdge()
                    } else {
                        moveBackToOriginalPosition()
                        handleClickAction()
                    }
                }
            }
            return true
        }
    }

    private fun updateFlagOfDragAction(xMovePoint: Float, yMovePoint: Float) {
        val xDistance = abs(xMovePoint - touchDownPointX)
        val yDistance = abs(yMovePoint - touchDownPointY)
        if (xDistance >= CLICK_ACTION_MAX_MOVE_DISTANCE_PX || yDistance >= CLICK_ACTION_MAX_MOVE_DISTANCE_PX) {
            isActionDrag = true
        }
    }

    private fun handleClickAction() {
        for (observer in observerList) {
            observer.onFloatWindowClick()
        }
    }

    private fun moveBackToOriginalPosition() {
        rootView?.let {
            windowLayoutParams = originalLayoutParams
            windowManager?.updateViewLayout(it, windowLayoutParams)
        }
    }

    private fun autoMoveToScreenEdge() {
        rootView?.let {
            windowLayoutParams?.let { params ->
                params.x = if (params.x > (getMaxPositionX() shr 1)) {
                    getMaxPositionX()
                } else {
                    VIEW_MARGIN_EDGE_PX
                }
                windowManager?.updateViewLayout(it, params)
            }
        }
    }

    private fun updateLayout() {
        rootView?.let { rootView ->
            windowLayoutParams?.let { params ->
                params.x = params.x.coerceIn(VIEW_MARGIN_EDGE_PX, getMaxPositionX())
                params.y = params.y.coerceIn(VIEW_MARGIN_EDGE_PX, getMaxPositionY())
                windowManager?.updateViewLayout(rootView, params)
            }
        }
    }

    private fun getMaxPositionX(): Int {
        return ScreenUtil.getScreenWidth(appContext!!) - (rootView?.width ?: 0) - VIEW_MARGIN_EDGE_PX
    }

    private fun getMaxPositionY(): Int {
        return ScreenUtil.getScreenHeight(appContext!!) - (rootView?.height ?: 0) - VIEW_MARGIN_EDGE_PX
    }

    private fun registerReceiver() {
        if (orientationReceiver != null) {
            return
        }
        orientationReceiver = OrientationReceiver()
        val filter = IntentFilter()
        filter.addAction(Intent.ACTION_CONFIGURATION_CHANGED)
        appContext?.registerReceiver(orientationReceiver, filter)
    }

    private fun unregisterReceiver() {
        orientationReceiver?.let {
            appContext?.unregisterReceiver(it)
            orientationReceiver = null
        }
    }

    private inner class OrientationReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (Intent.ACTION_CONFIGURATION_CHANGED == intent.action) {
                updateWindowLayoutParams()
                updateLayout()
            }
        }
    }
}
