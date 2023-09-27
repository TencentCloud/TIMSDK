package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.view.common.RoundCornerImageView
import com.tencent.qcloud.tuikit.tuicallkit.view.common.gridimage.GridImageSynthesizer

class RecordsIconView : RoundCornerImageView {
    private var imageSize = 100
    private var background = Color.parseColor("#cfd3d8")
    private var defaultImageResId = 0
    private var imageGap = 6
    private lateinit var gridImageSynthesizer: GridImageSynthesizer

    constructor(context: Context) : super(context) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        initAttrs(attrs)
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(context, attrs, defStyleAttr) {
        initAttrs(attrs)
        init(context)
    }

    private fun initAttrs(attributeSet: AttributeSet?) {
        val ta = context.obtainStyledAttributes(attributeSet, R.styleable.SynthesizedImageView)
        if (null != ta) {
            background = ta.getColor(R.styleable.SynthesizedImageView_image_background, background)
            defaultImageResId = ta.getResourceId(R.styleable.SynthesizedImageView_default_image, defaultImageResId)
            imageSize = ta.getDimensionPixelSize(R.styleable.SynthesizedImageView_image_size, imageSize)
            imageGap = ta.getDimensionPixelSize(R.styleable.SynthesizedImageView_image_gap, imageGap)
            ta.recycle()
        }
    }

    private fun init(context: Context) {
        gridImageSynthesizer = GridImageSynthesizer(context, this)
        gridImageSynthesizer.setMaxSize(imageSize, imageSize)
        gridImageSynthesizer.defaultImage = defaultImageResId
        gridImageSynthesizer.setBgColor(background)
        gridImageSynthesizer.setGap(imageGap)
    }

    fun displayImage(imageUrls: List<Any?>?): RecordsIconView {
        gridImageSynthesizer.setImageUrls(imageUrls)
        return this
    }

    fun setImageId(id: String?) {
        if (id == null) {
            gridImageSynthesizer.imageId = ""
        } else {
            gridImageSynthesizer.imageId = id
        }
    }

    fun load(imageId: String?) {
        gridImageSynthesizer.load(imageId)
    }

    fun clear() {
        gridImageSynthesizer.clearImage()
    }
}