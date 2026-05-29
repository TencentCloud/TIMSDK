package com.tencent.qcloud.tuikit.timcommon.util.keyboard

import android.R
import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Rect
import android.os.Build
import android.view.View
import android.view.ViewTreeObserver
import android.view.WindowManager
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

class KeyboardHeightObserver(activity: Activity) {
    private val activity: Activity
    private val rootView: View?
    private val preferences: SharedPreferences
    private var keyboardHeight = 0
    private var lastDispatchedHeight = 0
    private var lastDispatchedVisible = false
    private var listener: OnKeyboardHeightChangeListener? = null
    private var globalLayoutListener: ViewTreeObserver.OnGlobalLayoutListener? = null

    interface OnKeyboardHeightChangeListener {
        fun onKeyboardHeightChanged(height: Int, isVisible: Boolean)

        fun onKeyboardHeightChanging(currentHeight: Int) {
        }
    }

    init {
        this.activity = activity
        this.rootView = activity.getWindow().getDecorView().findViewById<View?>(R.id.content)
        this.preferences = activity.getSharedPreferences(PREFERENCE_NAME, Context.MODE_PRIVATE)
        this.keyboardHeight = loadSavedKeyboardHeight()
    }

    fun setOnKeyboardHeightChangeListener(listener: OnKeyboardHeightChangeListener?) {
        this.listener = listener
    }

    private var isEdgeToEdge = false

    fun isEdgeToEdge(): Boolean {
        return isEdgeToEdge
    }

    private var imeAnimationRunning: Boolean = false
    private var pendingHideRunnable: Runnable? = null
    private var pendingShowRunnable: Runnable? = null

    private fun dispatchChanged(height: Int, isVisible: Boolean) {
        lastDispatchedHeight = height
        lastDispatchedVisible = isVisible
        listener?.onKeyboardHeightChanged(height, isVisible)
    }

    private fun cancelPendingHide(view: View) {
        pendingHideRunnable?.let { view.removeCallbacks(it) }
        pendingHideRunnable = null
    }

    private fun cancelPendingShow(view: View) {
        pendingShowRunnable?.let { view.removeCallbacks(it) }
        pendingShowRunnable = null
    }

    private fun scheduleShowDispatch(view: View, delayMs: Long = 200) {
        cancelPendingShow(view)
        val r = Runnable {
            pendingShowRunnable = null
            if (imeAnimationRunning) {
                return@Runnable
            }
            val h = keyboardHeight
            if (h <= 0) {
                return@Runnable
            }
            dispatchChanged(h, true)
        }
        pendingShowRunnable = r
        view.postDelayed(r, delayMs)
    }

    private fun scheduleHideDispatch(view: View, delayMs: Long = 80) {
        cancelPendingHide(view)
        val r = Runnable {
            pendingHideRunnable = null
            if (imeAnimationRunning) {
                return@Runnable
            }
            dispatchChanged(0, false)
        }
        pendingHideRunnable = r
        view.postDelayed(r, delayMs)
    }

    fun start() {
        if (rootView != null) {
            rootView.post {
                isEdgeToEdge = checkEdgeToEdge(rootView)
            }
        }
        setupWindowInsetsListener()
    }

    private fun checkEdgeToEdge(view: View): Boolean {
        val viewLocation = IntArray(2)
        view.getLocationOnScreen(viewLocation)
        val viewBottom = viewLocation[1] + view.height

        val screenHeight = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            activity.windowManager.currentWindowMetrics.bounds.height()
        } else {
            val display = activity.windowManager.defaultDisplay
            val realMetrics = android.util.DisplayMetrics()
            display.getRealMetrics(realMetrics)
            realMetrics.heightPixels
        }
        
        return Math.abs(screenHeight - viewBottom) < 50
    }

    fun stop() {
        if (globalLayoutListener != null && rootView != null) {
            rootView.getViewTreeObserver().removeOnGlobalLayoutListener(globalLayoutListener)
            globalLayoutListener = null
        }
        if (rootView != null) {
            KeyboardAdjustHelper.detachKeyboardAdjustments(rootView)
            ViewCompat.setOnApplyWindowInsetsListener(rootView, null)
        }
    }

    fun getKeyboardHeight(): Int {
        return if (keyboardHeight > 0) keyboardHeight else this.defaultKeyboardHeight
    }

    private val defaultKeyboardHeight: Int
        get() {
            val density = activity.getResources().getDisplayMetrics().density
            return (DEFAULT_KEYBOARD_HEIGHT_DP * density).toInt()
        }

    private fun loadSavedKeyboardHeight(): Int {
        return preferences.getInt(KEY_KEYBOARD_HEIGHT, 0)
    }

    private fun saveKeyboardHeight(height: Int) {
        if (height > 0 && height != keyboardHeight) {
            preferences.edit().putInt(KEY_KEYBOARD_HEIGHT, height).apply()
        }
    }

    private fun setupWindowInsetsListener() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            activity.window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
        }

        val view = rootView ?: return

        fun getAdjustedHeight(height: Int, insets: WindowInsetsCompat?): Int {
            if (!isEdgeToEdge && insets != null) {
                val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
                return (height - systemBars.bottom).coerceAtLeast(0)
            }
            return height
        }

        ViewCompat.setOnApplyWindowInsetsListener(view) { v, insets ->
            val imeInsets = insets.getInsets(WindowInsetsCompat.Type.ime())
            val imeHeight = getAdjustedHeight(imeInsets.bottom, insets)
            val imeVisible = imeHeight > 0

            if (imeVisible) {
                cancelPendingHide(view)
                cancelPendingShow(view)
                this.keyboardHeight = imeHeight
                if (imeAnimationRunning) {
                } else if (!lastDispatchedVisible) {
                    // Some devices report the final IME height in onApplyWindowInsets BEFORE the IME show animation starts.
                    // If we dispatch the final height immediately, UI may jump for 1-2 frames when the animation progress
                    // starts from 0. Defer the show dispatch slightly; if an IME animation starts, it will be cancelled
                    // and the final state will be delivered by onEnd.
                    scheduleShowDispatch(view)
                } else {
                    dispatchChanged(imeHeight, true)
                }
            } else {
                cancelPendingShow(view)
                // Some devices report imeBottom=0 BEFORE the IME hide animation starts.
                // If we dispatch height=0 immediately, UI may flicker for 1-2 frames.
                // Defer the hide dispatch a little; if an IME animation starts, it will be cancelled
                // and the final state will be delivered by onEnd.
                scheduleHideDispatch(view)
            }
            insets
        }

        KeyboardAdjustHelper.attachKeyboardAdjustments(view, object : KeyBoardAdjustListener {
            override fun onStart(isVisible: Boolean, keyboardHeight: Float) {
                imeAnimationRunning = true
                cancelPendingHide(view)
                cancelPendingShow(view)
                val insets = ViewCompat.getRootWindowInsets(view)
                val adjustedHeight = getAdjustedHeight(keyboardHeight.toInt(), insets)
                if (adjustedHeight > 0) {
                    saveKeyboardHeight(adjustedHeight)
                }
            }

            override fun onProgress(isVisible: Boolean, currentKeyboardHeight: Float) {
                val insets = ViewCompat.getRootWindowInsets(view)
                val adjustedHeight = getAdjustedHeight(currentKeyboardHeight.toInt(), insets)
                listener?.onKeyboardHeightChanging(adjustedHeight)
            }

            override fun onEnd(isVisible: Boolean, keyboardHeight: Float) {
                val insets = ViewCompat.getRootWindowInsets(view)
                val adjustedHeight = getAdjustedHeight(keyboardHeight.toInt(), insets)
                imeAnimationRunning = false
                
                if (adjustedHeight > 0) {
                    this@KeyboardHeightObserver.keyboardHeight = adjustedHeight
                }
                dispatchChanged(if (isVisible) adjustedHeight else 0, isVisible)
            }
        })
    }

    private fun setupGlobalLayoutListener() {
        globalLayoutListener = object : ViewTreeObserver.OnGlobalLayoutListener {
            private var previousKeyboardHeight = 0
            private var wasKeyboardVisible = false

            override fun onGlobalLayout() {
                val rect = Rect()
                rootView!!.getWindowVisibleDisplayFrame(rect)

                val screenHeight = rootView.getRootView().getHeight()
                val heightDiff = screenHeight - rect.bottom

                val navigationBarHeight: Int = navigationBarHeight
                val statusBarHeight: Int = statusBarHeight

                val keyboardHeightEstimate = heightDiff - navigationBarHeight

                val isKeyboardVisible = keyboardHeightEstimate > screenHeight * 0.15

                if (isKeyboardVisible) {
                    if (keyboardHeightEstimate != previousKeyboardHeight) {
                        previousKeyboardHeight = keyboardHeightEstimate
                        keyboardHeight = keyboardHeightEstimate
                        saveKeyboardHeight(keyboardHeightEstimate)
                    }
                }

                if (listener != null) {
                    listener!!.onKeyboardHeightChanging(if (isKeyboardVisible) keyboardHeightEstimate else 0)
                }

                if (isKeyboardVisible != wasKeyboardVisible ||
                    (isKeyboardVisible && keyboardHeightEstimate != previousKeyboardHeight)
                ) {
                    wasKeyboardVisible = isKeyboardVisible

                    if (listener != null) {
                        listener!!.onKeyboardHeightChanged(
                            if (isKeyboardVisible) keyboardHeightEstimate else keyboardHeight,
                            isKeyboardVisible
                        )
                    }
                }
            }
        }

        rootView!!.getViewTreeObserver().addOnGlobalLayoutListener(globalLayoutListener)
    }

    private val navigationBarHeight: Int
        get() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val window = activity.getWindow()
                if (window != null) {
                    val decorView = window.getDecorView()
                    if (decorView != null) {
                        val insets = ViewCompat.getRootWindowInsets(decorView)
                        if (insets != null) {
                            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
                            return systemBars.bottom
                        }
                    }
                }
            }

            val resourceId = activity.getResources().getIdentifier("navigation_bar_height", "dimen", "android")
            if (resourceId > 0) {
                return activity.getResources().getDimensionPixelSize(resourceId)
            }
            return 0
        }

    private val statusBarHeight: Int
        get() {
            val resourceId = activity.getResources().getIdentifier("status_bar_height", "dimen", "android")
            if (resourceId > 0) {
                return activity.getResources().getDimensionPixelSize(resourceId)
            }
            return 0
        }

    companion object {
        private const val PREFERENCE_NAME = "keyboard_height"
        private const val KEY_KEYBOARD_HEIGHT = "keyboard_height"
        private const val DEFAULT_KEYBOARD_HEIGHT_DP = 267
    }
}