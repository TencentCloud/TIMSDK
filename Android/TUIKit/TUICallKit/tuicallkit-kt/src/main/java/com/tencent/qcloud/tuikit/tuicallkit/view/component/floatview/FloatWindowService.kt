package com.tencent.qcloud.tuikit.tuicallkit.view.component.floatview

import android.animation.ValueAnimator
import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallkit.view.CallKitActivity
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.view.floatwindow.FloatingWindowView

class FloatWindowService : Service() {
    private var windowManager: WindowManager? = null
    private var windowLayoutParams: WindowManager.LayoutParams? = null
    private var screenWidth = 0
    private var callViewWidth = 0
    private var touchStartX = 0
    private var touchStartY = 0
    private var touchCurrentX = 0
    private var touchCurrentY = 0
    private var startX = 0
    private var startY = 0
    private var stopX = 0
    private var stopY = 0
    private var isMove = false

    companion object {
        private var callView: FloatingWindowView? = null
        fun startFloatService(callView: FloatingWindowView) {
            this.callView = callView
            this.callView?.setOnClickListener {
                stopService()
                if (TUICallState.instance.selfUser.get().callStatus.get() != TUICallDefine.Status.None) {
                    val intent = Intent(ServiceInitializer.getAppContext(), CallKitActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    ServiceInitializer.getAppContext().startActivity(intent)
                }
            }
            var serviceIntent = Intent(ServiceInitializer.getAppContext(), FloatWindowService::class.java)
            ServiceInitializer.getAppContext().startService(serviceIntent)
        }

        fun stopService() {
            if (callView != null) {
                callView?.clear()
            }
            var serviceIntent = Intent(ServiceInitializer.getAppContext(), FloatWindowService::class.java)
            ServiceInitializer.getAppContext().stopService(serviceIntent)
        }
    }

    override fun onCreate() {
        super.onCreate()
        initWindow()
    }

    override fun onBind(intent: Intent): IBinder {
        return FloatBinder()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return super.onStartCommand(intent, flags, startId)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (null != callView && callView!!.isAttachedToWindow) {
            windowManager?.removeView(callView)
        }
        callView = null
    }

    private fun initWindow() {
        windowManager = applicationContext.getSystemService(WINDOW_SERVICE) as WindowManager
        windowLayoutParams = viewParams
        screenWidth = windowManager!!.defaultDisplay.width
        if (null != callView) {
            callView!!.setBackgroundResource(R.drawable.tuicallkit_bg_floatwindow_left)
            windowManager!!.addView(callView, windowLayoutParams)
            callView!!.setOnTouchListener(FloatingListener())
        }
    }

    private val viewParams: WindowManager.LayoutParams
        private get() {
            windowLayoutParams = WindowManager.LayoutParams()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                windowLayoutParams!!.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                windowLayoutParams!!.type = WindowManager.LayoutParams.TYPE_PHONE
            }
            windowLayoutParams!!.flags = (WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                    or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                    or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
            windowLayoutParams!!.gravity = Gravity.LEFT or Gravity.TOP
            windowLayoutParams!!.x = 0
            windowLayoutParams!!.y = windowManager!!.defaultDisplay.height / 2
            windowLayoutParams!!.width = WindowManager.LayoutParams.WRAP_CONTENT
            windowLayoutParams!!.height = WindowManager.LayoutParams.WRAP_CONTENT
            windowLayoutParams!!.format = PixelFormat.TRANSPARENT
            return windowLayoutParams as WindowManager.LayoutParams
        }

    inner class FloatBinder : Binder() {
        val service: FloatWindowService
            get() = this@FloatWindowService
    }

    inner class FloatingListener : View.OnTouchListener {
        override fun onTouch(v: View, event: MotionEvent): Boolean {
            val action = event.action
            when (action) {
                MotionEvent.ACTION_DOWN -> {
                    isMove = false
                    touchStartX = event.rawX.toInt()
                    touchStartY = event.rawY.toInt()
                    startX = event.rawX.toInt()
                    startY = event.rawY.toInt()
                }

                MotionEvent.ACTION_MOVE -> {
                    touchCurrentX = event.rawX.toInt()
                    touchCurrentY = event.rawY.toInt()
                    if (windowLayoutParams != null && null != callView) {
                        windowLayoutParams!!.x += touchCurrentX - touchStartX
                        windowLayoutParams!!.y += touchCurrentY - touchStartY
                        windowManager!!.updateViewLayout(callView, windowLayoutParams)
                    }
                    touchStartX = touchCurrentX
                    touchStartY = touchCurrentY
                    stopX = event.rawX.toInt()
                    stopY = event.rawY.toInt()
                    if (Math.abs(startX - stopX) >= 5 || Math.abs(startY - stopY) >= 5) {
                        isMove = true
                        if (null != callView) {
                            callViewWidth = callView!!.width
                            if (touchCurrentX > screenWidth / 2) {
                                startScroll(stopX, screenWidth - callViewWidth, false)
                            } else {
                                startScroll(stopX, 0, true)
                            }
                        }
                    }
                }

                MotionEvent.ACTION_UP -> {
                    stopX = event.rawX.toInt()
                    stopY = event.rawY.toInt()
                    if (Math.abs(startX - stopX) >= 5 || Math.abs(startY - stopY) >= 5) {
                        isMove = true
                        if (null != callView) {
                            callViewWidth = callView!!.width
                            if (touchCurrentX > screenWidth / 2) {
                                startScroll(stopX, screenWidth - callViewWidth, false)
                            } else {
                                startScroll(stopX, 0, true)
                            }
                        }
                    }
                }

                else -> {}
            }
            return isMove
        }
    }

    private fun startScroll(start: Int, end: Int, isLeft: Boolean) {
        val valueAnimator = ValueAnimator.ofFloat(start.toFloat(), end.toFloat()).setDuration(300)
        valueAnimator.addUpdateListener(ValueAnimator.AnimatorUpdateListener { animation ->
            if (windowLayoutParams == null || callView == null) {
                return@AnimatorUpdateListener
            }
            callViewWidth = callView!!.width
            if (isLeft) {
                windowLayoutParams!!.x = (start * (1 - animation.animatedFraction)).toInt()
                callView!!.setBackgroundResource(R.drawable.tuicallkit_bg_floatwindow_left)
            } else {
                val end = (screenWidth - start - callViewWidth) * animation.animatedFraction
                windowLayoutParams!!.x = (start + end).toInt()
                callView!!.setBackgroundResource(R.drawable.tuicallkit_bg_floatwindow_right)
            }
            calculateHeight()
            windowManager!!.updateViewLayout(callView, windowLayoutParams)
        })
        valueAnimator.start()
    }

    private fun calculateHeight() {
        if (windowLayoutParams == null) {
            return
        }
        val height = callView!!.height
        val screenHeight = windowManager!!.defaultDisplay.height
        val resourceId = ServiceInitializer.getAppContext().resources
            .getIdentifier("status_bar_height", "dimen", "android")
        val statusBarHeight = ServiceInitializer.getAppContext().resources.getDimensionPixelSize(resourceId)
        if (windowLayoutParams!!.y < 0) {
            windowLayoutParams!!.y = 0
        } else if (windowLayoutParams!!.y > screenHeight - height - statusBarHeight) {
            windowLayoutParams!!.y = screenHeight - height - statusBarHeight
        }
    }

}