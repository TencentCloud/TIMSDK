package io.trtc.tuikit.atomicx.callview.public.smartcellularswitchrecommendation

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.widget.Button
import android.widget.ImageView
import com.google.android.material.bottomsheet.BottomSheetDialog
import io.trtc.tuikit.atomicx.R

class SmartCellularRecommendationDialog(context: Context?) :
    BottomSheetDialog(context!!, R.style.dialogStyleFromBottom) {

    var onEnableSmartCellular: (() -> Unit)? = null
    var onKeepWiFi: (() -> Unit)? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.dialog_smart_cellular_recommendation)

        initViews()
        setupClickListeners()
    }

    private fun initViews() {
        findViewById<ImageView>(R.id.iv_wifi_icon)?.setImageDrawable(createWiFiPoorIcon())
        findViewById<ImageView>(R.id.iv_cellular_icon)?.setImageDrawable(createCellularGoodIcon())
        findViewById<ImageView>(R.id.iv_arrow)?.setImageDrawable(createArrowIcon())
    }

    private fun setupClickListeners() {
        findViewById<Button>(R.id.btn_improve)?.setOnClickListener {
            onEnableSmartCellular?.invoke()
            dismiss()
        }

        findViewById<Button>(R.id.btn_keep_wifi)?.setOnClickListener {
            onKeepWiFi?.invoke()
            dismiss()
        }
    }

    private fun createWiFiPoorIcon(): Drawable {
        val size = 150
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        val centerX = size / 2f
        val centerY = size / 2f + 12f

        paint.style = Paint.Style.STROKE
        paint.strokeWidth = 10f
        paint.strokeCap = Paint.Cap.ROUND

        paint.color = Color.parseColor("#FFB3BA")
        canvas.drawArc(
            centerX - 50f,
            centerY - 50f,
            centerX + 50f,
            centerY + 50f,
            135f,
            270f,
            false,
            paint
        )
        canvas.drawArc(
            centerX - 32f,
            centerY - 32f,
            centerX + 32f,
            centerY + 32f,
            135f,
            270f,
            false,
            paint
        )

        paint.color = Color.parseColor("#FF4D4F")
        canvas.drawArc(
            centerX - 15f,
            centerY - 15f,
            centerX + 15f,
            centerY + 15f,
            135f,
            270f,
            false,
            paint
        )

        paint.style = Paint.Style.FILL
        canvas.drawCircle(centerX, centerY + 20f, 10f, paint)

        val warningSize = 40f
        val warningX = size - warningSize - 5f
        val warningY = 5f

        canvas.drawCircle(
            warningX + warningSize / 2,
            warningY + warningSize / 2,
            warningSize / 2,
            paint
        )

        paint.color = Color.WHITE
        canvas.drawRect(
            warningX + warningSize / 2 - 2f,
            warningY + 7f,
            warningX + warningSize / 2 + 2f,
            warningY + 21f,
            paint
        )
        canvas.drawCircle(warningX + warningSize / 2, warningY + 27f, 2f, paint)

        return BitmapDrawable(context.resources, bitmap)
    }

    private fun createCellularGoodIcon(): Drawable {
        val size = 150
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        val barWidth = 15f
        val barSpacing = 10f
        val maxHeight = 100f
        val startX = (size - (barWidth * 5 + barSpacing * 4)) / 2
        val startY = (size + maxHeight) / 2

        paint.style = Paint.Style.FILL
        paint.color = Color.parseColor("#52C41A")

        for (i in 0 until 5) {
            val barHeight = maxHeight * (i + 1) / 5
            val x = startX + i * (barWidth + barSpacing)
            val y = startY - barHeight

            val rect = RectF(x, y, x + barWidth, startY)
            canvas.drawRoundRect(rect, 5f, 5f, paint)
        }

        return BitmapDrawable(context.resources, bitmap)
    }

    private fun createArrowIcon(): Drawable {
        val width = 100
        val height = 75
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        paint.style = Paint.Style.STROKE
        paint.strokeWidth = 7f
        paint.strokeCap = Paint.Cap.ROUND
        paint.strokeJoin = Paint.Join.ROUND
        paint.color = Color.parseColor("#999999")

        val path = Path()
        path.moveTo(12f, height / 2f)
        path.lineTo(width - 30f, height / 2f)

        path.moveTo(width - 30f, height / 2f - 15f)
        path.lineTo(width - 12f, height / 2f)
        path.lineTo(width - 30f, height / 2f + 15f)

        canvas.drawPath(path, paint)

        return BitmapDrawable(context.resources, bitmap)
    }
}