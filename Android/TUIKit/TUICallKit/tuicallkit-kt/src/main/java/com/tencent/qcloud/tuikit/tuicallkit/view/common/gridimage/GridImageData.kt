package com.tencent.qcloud.tuikit.tuicallkit.view.common.gridimage

import android.graphics.Bitmap
import android.graphics.Color
import java.lang.Integer.min

class GridImageData : Cloneable {

    var imageUrlList: List<Any?>? = null
    var bitmapMap: MutableMap<Int, Bitmap?>? = null
    var defaultImageResId: Int = 0
    var bgColor: Int = Color.parseColor("#cfd3d8")
    var targetImageSize: Int = 0
    var maxWidth: Int = 0
    var maxHeight: Int = 0
    var rowCount: Int = 0
    var columnCount: Int = 0
    var gap: Int = 6

    constructor()

    constructor(imageUrlList: List<Any?>?, defaultImageResId: Int) {
        this.imageUrlList = imageUrlList
        this.defaultImageResId = defaultImageResId
    }

    fun putBitmap(bitmap: Bitmap, position: Int) {
        if (bitmapMap == null) {
            bitmapMap = HashMap()
        }
        bitmapMap?.let {
            synchronized(it) { it.put(position, bitmap) }
        }
    }

    fun getBitmap(position: Int): Bitmap? {
        bitmapMap?.let {
            synchronized(it) { return it[position] }
        }
        return null
    }

    fun size(): Int {
        imageUrlList?.let {
           return min(it.size, MAX_SIZE)
        }
        return 0
    }

    @Throws(CloneNotSupportedException::class)
    public override fun clone(): GridImageData {
        val gridImageData = super.clone() as GridImageData
        imageUrlList?.let {
            gridImageData.imageUrlList = ArrayList(it.size)
            (gridImageData.imageUrlList as ArrayList).addAll(it)
        }
        bitmapMap?.let {
            gridImageData.bitmapMap = HashMap()
            gridImageData.bitmapMap?.putAll(it)
        }
        return gridImageData
    }

    companion object {
        private const val MAX_SIZE = 9
    }
}