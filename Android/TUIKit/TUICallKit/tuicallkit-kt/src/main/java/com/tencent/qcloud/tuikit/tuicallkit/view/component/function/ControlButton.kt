package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.LinearLayout
import android.widget.TextView
import androidx.constraintlayout.utils.widget.ImageFilterView
import com.tencent.qcloud.tuikit.tuicallkit.R

class ControlButton @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {
    val imageView: ImageFilterView
    val textView: TextView

    init {
        LayoutInflater.from(context).inflate(R.layout.tuicallkit_function_view_video_item, this, true)
        imageView = findViewById(R.id.iv_function)
        textView = findViewById(R.id.tv_function)

        attrs?.let {
            val typedArray = context.obtainStyledAttributes(it, R.styleable.ControlButton, 0, 0)
            val iconRes = typedArray.getResourceId(R.styleable.ControlButton_cbIcon, 0)
            val text = typedArray.getString(R.styleable.ControlButton_cbText)
            if (iconRes != 0) {
                imageView.setImageResource(iconRes)
            }
            textView.text = text ?: ""
            typedArray.recycle()
        }
    }
}