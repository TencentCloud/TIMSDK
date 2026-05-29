/*
 * Copyright (c) 2025 Tencent
 * All rights reserved.
 *
 * Author: eddardliu
 */

package io.trtc.tuikit.atomicx.imageuploader.view

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.RectF
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.theme.ThemeStore
import io.trtc.tuikit.atomicx.imageuploader.CropOverlayShape
import io.trtc.tuikit.atomicx.imageuploader.util.ImageUploaderUtil
import kotlin.math.max
import kotlin.math.min

private data class ImageTransform(
    var zoomScale: Float = 1f,
    var minZoomScale: Float = 1f,
    var offsetX: Float = 0f,
    var offsetY: Float = 0f
)

private data class TouchState(
    var lastTouchX: Float = 0f,
    var lastTouchY: Float = 0f,
    var lastPointerCount: Int = 0,
    var lastFocusX: Float = 0f,
    var lastFocusY: Float = 0f
)

private data class CropInfo(
    var imageAreaHeight: Float = 0f,
    val cropSize: RectF = RectF()
)

class ImageCropView(
    context: Context,
    private val bitmap: Bitmap,
    private val overlayShape: CropOverlayShape,
    private val listener: Listener
) : FrameLayout(context) {

    companion object {
        private const val CROP_SIZE_RATIO = 0.9f
        private const val MAX_ZOOM = 5f
        private const val MASK_OPACITY_NORMAL = 0.85f
        private const val MASK_OPACITY_ACTIVE = 0.2f
        private const val MASK_OPACITY_RESTORE_DELAY = 1500L
        private const val MASK_OPACITY_ANIMATION_DURATION = 300L
        private const val BOTTOM_BAR_HEIGHT = 56
    }

    interface Listener {
        fun onConfirm(croppedBitmap: Bitmap)
        fun onClose()
    }

    private val themeStore = ThemeStore.shared(context)
    private val colorTokens get() = themeStore.themeState.value.currentTheme.tokens.color
    private val fontTokens get() = themeStore.themeState.value.currentTheme.tokens.font
    private val imageTransform = ImageTransform()
    private val touchState = TouchState()
    private val cropInfo = CropInfo()

    private lateinit var imageView: ImageView
    private lateinit var overlayView: CropOverlayView
    private lateinit var cancelButton: TextView
    private lateinit var confirmButton: TextView

    private var maskRestoreRunnable: Runnable? = null

    private val scaleGestureDetector = ScaleGestureDetector(context, object : ScaleGestureDetector.SimpleOnScaleGestureListener() {
        override fun onScale(detector: ScaleGestureDetector): Boolean {
            val scaleFactor = detector.scaleFactor
            val focusX = detector.focusX
            val focusY = detector.focusY

            val newZoom = (imageTransform.zoomScale * scaleFactor).coerceIn(imageTransform.minZoomScale, MAX_ZOOM)
            val zoomRatio = newZoom / imageTransform.zoomScale

            imageTransform.offsetX = focusX - (focusX - imageTransform.offsetX) * zoomRatio
            imageTransform.offsetY = focusY - (focusY - imageTransform.offsetY) * zoomRatio

            imageTransform.zoomScale = newZoom
            constrainOffset()
            updateImageTransform()
            overlayView.setMaskOpacity(MASK_OPACITY_ACTIVE)
            scheduleMaskRestore()

            return true
        }
    })

    init {
        setBackgroundColor(android.graphics.Color.BLACK)
        setupViews()
        imageView.setImageBitmap(bitmap)
        post {
            calculateCropSize()
            initializeTransform()
            overlayView.setCropInfo(cropInfo.cropSize, overlayShape, cropInfo.imageAreaHeight)
        }
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        scaleGestureDetector.onTouchEvent(event)

        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                touchState.lastTouchX = event.x
                touchState.lastTouchY = event.y
                touchState.lastPointerCount = 1
                overlayView.setMaskOpacity(MASK_OPACITY_ACTIVE)
            }
            MotionEvent.ACTION_POINTER_DOWN -> {
                touchState.lastPointerCount = event.pointerCount
                touchState.lastFocusX = calculateFocusX(event)
                touchState.lastFocusY = calculateFocusY(event)
            }
            MotionEvent.ACTION_MOVE -> {
                if (event.pointerCount == 1 && !scaleGestureDetector.isInProgress) {
                    val dx = event.x - touchState.lastTouchX
                    val dy = event.y - touchState.lastTouchY
                    imageTransform.offsetX += dx
                    imageTransform.offsetY += dy
                    constrainOffset()
                    updateImageTransform()
                    touchState.lastTouchX = event.x
                    touchState.lastTouchY = event.y
                } else if (event.pointerCount > 1) {
                    val focusX = calculateFocusX(event)
                    val focusY = calculateFocusY(event)
                    if (touchState.lastPointerCount == event.pointerCount) {
                        val dx = focusX - touchState.lastFocusX
                        val dy = focusY - touchState.lastFocusY
                        imageTransform.offsetX += dx
                        imageTransform.offsetY += dy
                        constrainOffset()
                        updateImageTransform()
                    }
                    touchState.lastFocusX = focusX
                    touchState.lastFocusY = focusY
                    touchState.lastPointerCount = event.pointerCount
                }
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                scheduleMaskRestore()
            }
            MotionEvent.ACTION_POINTER_UP -> {
                touchState.lastPointerCount = event.pointerCount - 1
                if (touchState.lastPointerCount == 1) {
                    val upIndex = event.actionIndex
                    val remainingIndex = if (upIndex == 0) 1 else 0
                    touchState.lastTouchX = event.getX(remainingIndex)
                    touchState.lastTouchY = event.getY(remainingIndex)
                }
            }
        }
        return true
    }

    private fun setupViews() {
        imageView = ImageView(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT
            )
            scaleType = ImageView.ScaleType.MATRIX
        }
        addView(imageView)

        overlayView = CropOverlayView(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT
            )
        }
        addView(overlayView)

        setupBottomBar()
    }

    private fun setupBottomBar() {
        val bottomBar = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            val horizontalPadding = context.resources.getDimensionPixelSize(R.dimen.spacing_16)
            setPadding(horizontalPadding, 0, horizontalPadding, 0)
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                ImageUploaderUtil.dpToPx(context, BOTTOM_BAR_HEIGHT)
            ).apply {
                gravity = Gravity.BOTTOM
            }
        }

        cancelButton = TextView(context).apply {
            setText(R.string.image_uploader_cancel)
            setTextColor(colorTokens.textColorButton)
            textSize = fontTokens.regular16.size
            setOnClickListener { listener.onClose() }
        }

        val spacer = View(context).apply {
            layoutParams = LinearLayout.LayoutParams(0, 0, 1f)
        }

        confirmButton = TextView(context).apply {
            setText(R.string.image_uploader_done)
            setTextColor(colorTokens.textColorButton)
            textSize = fontTokens.regular16.size
            val background = GradientDrawable().apply {
                setColor(colorTokens.buttonColorPrimaryDefault)
                cornerRadius = context.resources.getDimension(R.dimen.radius_6)
            }
            setBackground(background)
            val horizontalPadding = context.resources.getDimensionPixelSize(R.dimen.spacing_16)
            val verticalPadding = context.resources.getDimensionPixelSize(R.dimen.spacing_8)
            setPadding(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding)
            setOnClickListener { performCrop() }
        }

        bottomBar.addView(cancelButton)
        bottomBar.addView(spacer)
        bottomBar.addView(confirmButton)

        addView(bottomBar)

        ViewCompat.setOnApplyWindowInsetsListener(this) { _, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            setPadding(0, systemBars.top, 0, systemBars.bottom)
            insets
        }
    }

    private fun performCrop() {
        val croppedBitmap = try {
            val rectInContentX = cropInfo.cropSize.left - imageTransform.offsetX
            val rectInContentY = cropInfo.cropSize.top - imageTransform.offsetY

            val rectInImageX = (rectInContentX / imageTransform.zoomScale).toInt()
            val rectInImageY = (rectInContentY / imageTransform.zoomScale).toInt()
            val rectInImageWidth = (cropInfo.cropSize.width() / imageTransform.zoomScale).toInt()
            val rectInImageHeight = (cropInfo.cropSize.height() / imageTransform.zoomScale).toInt()

            val clampedX = rectInImageX.coerceIn(0, bitmap.width - 1)
            val clampedY = rectInImageY.coerceIn(0, bitmap.height - 1)
            val clampedWidth = rectInImageWidth.coerceIn(1, bitmap.width - clampedX)
            val clampedHeight = rectInImageHeight.coerceIn(1, bitmap.height - clampedY)

            Bitmap.createBitmap(bitmap, clampedX, clampedY, clampedWidth, clampedHeight)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }

        if (croppedBitmap != null) {
            listener.onConfirm(croppedBitmap)
        }
    }

    private fun calculateCropSize() {
        val bottomBarHeight = ImageUploaderUtil.dpToPx(context, BOTTOM_BAR_HEIGHT).toFloat()
        cropInfo.imageAreaHeight = height - bottomBarHeight

        val containerWidth = width.toFloat()
        val containerHeight = cropInfo.imageAreaHeight

        val cropWidth = min(containerWidth, containerHeight) * CROP_SIZE_RATIO

        when (overlayShape) {
            CropOverlayShape.CIRCLE -> {
                val size = cropWidth
                val left = (containerWidth - size) / 2
                val top = (containerHeight - size) / 2
                cropInfo.cropSize.set(left, top, left + size, top + size)
            }
            else -> {
                val aspectRatio = when (overlayShape) {
                    CropOverlayShape.RECTANGLE_1_1 -> 1f
                    CropOverlayShape.RECTANGLE_4_3 -> 4f / 3f
                    CropOverlayShape.RECTANGLE_3_4 -> 3f / 4f
                    CropOverlayShape.RECTANGLE_16_9 -> 16f / 9f
                    CropOverlayShape.RECTANGLE_9_16 -> 9f / 16f
                    else -> 1f
                }
                var cropHeight = cropWidth / aspectRatio
                val maxHeight = containerHeight * CROP_SIZE_RATIO

                if (cropHeight > maxHeight) {
                    cropHeight = maxHeight
                    val adjustedWidth = minOf(maxHeight * aspectRatio, containerWidth.toFloat())
                    val left = (containerWidth - adjustedWidth) / 2
                    val top = (containerHeight - cropHeight) / 2
                    cropInfo.cropSize.set(left, top, left + adjustedWidth, top + cropHeight)
                } else {
                    val left = (containerWidth - cropWidth) / 2
                    val top = (containerHeight - cropHeight) / 2
                    cropInfo.cropSize.set(left, top, left + cropWidth, top + cropHeight)
                }
            }
        }
    }

    private fun initializeTransform() {
        val imageWidth = bitmap.width.toFloat()
        val imageHeight = bitmap.height.toFloat()

        val zoomToFitWidth = cropInfo.cropSize.width() / imageWidth
        val zoomToFitHeight = cropInfo.cropSize.height() / imageHeight
        imageTransform.minZoomScale = max(zoomToFitWidth, zoomToFitHeight)
        imageTransform.zoomScale = imageTransform.minZoomScale

        val scaledWidth = imageWidth * imageTransform.zoomScale
        val scaledHeight = imageHeight * imageTransform.zoomScale
        imageTransform.offsetX = (width - scaledWidth) / 2
        imageTransform.offsetY = (cropInfo.imageAreaHeight - scaledHeight) / 2

        updateImageTransform()
    }

    private fun updateImageTransform() {
        val matrix = Matrix()
        matrix.postScale(imageTransform.zoomScale, imageTransform.zoomScale)
        matrix.postTranslate(imageTransform.offsetX, imageTransform.offsetY)
        imageView.imageMatrix = matrix
    }

    private fun constrainOffset() {
        val scaledWidth = bitmap.width * imageTransform.zoomScale
        val scaledHeight = bitmap.height * imageTransform.zoomScale

        val minOffsetX = cropInfo.cropSize.right - scaledWidth
        val maxOffsetX = cropInfo.cropSize.left
        val minOffsetY = cropInfo.cropSize.bottom - scaledHeight
        val maxOffsetY = cropInfo.cropSize.top

        imageTransform.offsetX = if (minOffsetX <= maxOffsetX) {
            imageTransform.offsetX.coerceIn(minOffsetX, maxOffsetX)
        } else {
            (cropInfo.cropSize.left + cropInfo.cropSize.right - scaledWidth) / 2
        }

        imageTransform.offsetY = if (minOffsetY <= maxOffsetY) {
            imageTransform.offsetY.coerceIn(minOffsetY, maxOffsetY)
        } else {
            (cropInfo.cropSize.top + cropInfo.cropSize.bottom - scaledHeight) / 2
        }
    }

    private fun scheduleMaskRestore() {
        maskRestoreRunnable?.let { removeCallbacks(it) }
        maskRestoreRunnable = Runnable {
            overlayView.animateMaskOpacity(MASK_OPACITY_NORMAL)
        }
        postDelayed(maskRestoreRunnable, MASK_OPACITY_RESTORE_DELAY)
    }

    private fun calculateFocusX(event: MotionEvent): Float {
        var sum = 0f
        for (i in 0 until event.pointerCount) {
            sum += event.getX(i)
        }
        return sum / event.pointerCount
    }

    private fun calculateFocusY(event: MotionEvent): Float {
        var sum = 0f
        for (i in 0 until event.pointerCount) {
            sum += event.getY(i)
        }
        return sum / event.pointerCount
    }

    private inner class CropOverlayView (context: Context) : View(context) {
        private val maskPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = colorTokens.bgColorMask
            alpha = (255 * MASK_OPACITY_NORMAL).toInt()
        }

        private val clearPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            xfermode = PorterDuffXfermode(PorterDuff.Mode.CLEAR)
        }

        private val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = android.graphics.Color.WHITE
            style = Paint.Style.STROKE
            strokeWidth = ImageUploaderUtil.dpToPx(context, 1).toFloat()
        }

        private var cropRect = RectF()
        private var shape = CropOverlayShape.CIRCLE
        private var imageHeight = 0f
        private var maskOpacity = MASK_OPACITY_NORMAL

        fun setCropInfo(cropRect: RectF, shape: CropOverlayShape, imageAreaHeight: Float) {
            this.cropRect = cropRect
            this.shape = shape
            this.imageHeight = imageAreaHeight
            invalidate()
        }

        fun setMaskOpacity(opacity: Float) {
            maskOpacity = opacity
            maskPaint.alpha = (255 * opacity).toInt()
            invalidate()
        }

        fun animateMaskOpacity(targetOpacity: Float) {
            val animator = ValueAnimator.ofFloat(maskOpacity, targetOpacity)
            animator.duration = MASK_OPACITY_ANIMATION_DURATION
            animator.addUpdateListener { animation ->
                setMaskOpacity(animation.animatedValue as Float)
            }
            animator.start()
        }

        override fun onDraw(canvas: Canvas) {
            super.onDraw(canvas)

            val saveCount = canvas.saveLayer(0f, 0f, width.toFloat(), height.toFloat(), null)

            canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), maskPaint)

            if (shape == CropOverlayShape.CIRCLE) {
                val centerX = cropRect.centerX()
                val centerY = cropRect.centerY()
                val radius = cropRect.width() / 2
                canvas.drawCircle(centerX, centerY, radius, clearPaint)
                canvas.drawCircle(centerX, centerY, radius, borderPaint)
            } else {
                canvas.drawRect(cropRect, clearPaint)
                canvas.drawRect(cropRect, borderPaint)
            }

            canvas.restoreToCount(saveCount)
        }
    }
}
