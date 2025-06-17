package com.tencent.qcloud.tuikit.tuicallkit.view.component.recents

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import androidx.constraintlayout.utils.widget.ImageFilterView
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.view.component.recents.gridimage.GridImageSynthesizer

class RecordsIconView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null, defStyle: Int = 0) :
    ImageFilterView(context, attrs, defStyle) {
    private var imageSize = 100
    private var imageGap = 6
    private val gridImageSynthesizer: GridImageSynthesizer = GridImageSynthesizer(context, this)

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        initView()
    }

    private fun initView() {
        gridImageSynthesizer.setMaxSize(imageSize, imageSize)
        gridImageSynthesizer.setDefaultImage(R.drawable.tuicallkit_ic_avatar)
        gridImageSynthesizer.setBackgroundColor(Color.parseColor("#cfd3d8"))
        gridImageSynthesizer.setGap(imageGap)
    }

    fun displayImage(imageUrls: List<Any?>?): RecordsIconView {
        gridImageSynthesizer.setImageUrls(imageUrls)
        return this
    }

    fun setImageId(id: String?) {
        gridImageSynthesizer.setImageId(id)
    }

    fun load(imageId: String?) {
        gridImageSynthesizer.load(imageId)
    }

    fun clear() {
        gridImageSynthesizer.clearImage()
    }
}