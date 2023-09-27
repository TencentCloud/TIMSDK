package com.tencent.qcloud.tuikit.tuicallkit.view.common.gridimage

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Rect
import android.text.TextUtils
import android.widget.ImageView
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader.clear
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader.loadBitmap
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader.loadImage
import com.tencent.qcloud.tuikit.tuicallkit.view.common.gridimage.ThreadUtils.execute
import com.tencent.qcloud.tuikit.tuicallkit.view.common.gridimage.ThreadUtils.runOnUIThread
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.concurrent.ExecutionException

class GridImageSynthesizer(private val mContext: Context, private val mImageView: ImageView) {
    public var imageId = ""
    private var gridImageData: GridImageData? = null

    init {
        init()
    }

    private fun init() {
        gridImageData = GridImageData()
    }

    fun setImageUrls(list: List<Any?>?) {
        gridImageData?.imageUrlList = list
    }

    fun setMaxSize(maxWidth: Int, maxHeight: Int) {
        gridImageData?.maxWidth = maxWidth
        gridImageData?.maxHeight = maxHeight
    }

    var defaultImage: Int
        get() {
            return gridImageData?.defaultImageResId ?: 0
        }
        set(defaultImageResId) {
            gridImageData?.defaultImageResId = defaultImageResId
        }

    fun setBgColor(bgColor: Int) {
        gridImageData?.bgColor = bgColor
    }

    fun setGap(gap: Int) {
        gridImageData?.gap = gap
    }

    private fun calculateGridParam(imagesSize: Int): IntArray {
        val gridParam = IntArray(2)
        if (imagesSize < 3) {
            gridParam[0] = 1
            gridParam[1] = imagesSize
        } else if (imagesSize <= 4) {
            gridParam[0] = 2
            gridParam[1] = 2
        } else {
            gridParam[0] = imagesSize / 3 + if (imagesSize % 3 == 0) 0 else 1
            gridParam[1] = 3
        }
        return gridParam
    }

    private fun asyncLoadImageList(imageData: GridImageData): Boolean {
        val loadSuccess = true
        val imageUrlList = imageData.imageUrlList
        imageUrlList?.let {
            for (i in it.indices) {
                val defaultIcon = BitmapFactory.decodeResource(mContext.resources, R.drawable.tuicallkit_ic_avatar)
                try {
                    val bitmap = asyncLoadImage(it[i] ?: "", imageData.targetImageSize)
                    if (bitmap != null) {
                        imageData.putBitmap(bitmap, i)
                    }
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                    imageData.putBitmap(defaultIcon, i)
                } catch (e: ExecutionException) {
                    e.printStackTrace()
                    imageData.putBitmap(defaultIcon, i)
                }
            }
        }
        return loadSuccess
    }

    private fun synthesizeImageList(imageData: GridImageData): Bitmap {
        val mergeBitmap = Bitmap.createBitmap(imageData.maxWidth, imageData.maxHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(mergeBitmap)
        drawDrawable(canvas, imageData)
        canvas.save()
        canvas.restore()
        return mergeBitmap
    }

    private fun drawDrawable(canvas: Canvas, imageData: GridImageData) {
        canvas.drawColor(imageData.bgColor)
        val size = imageData.size()
        val tCenter = (imageData.maxHeight + imageData.gap) / 2
        val bCenter = (imageData.maxHeight - imageData.gap) / 2
        val lCenter = (imageData.maxWidth + imageData.gap) / 2
        val rCenter = (imageData.maxWidth - imageData.gap) / 2
        val center = (imageData.maxHeight - imageData.targetImageSize) / 2
        for (i in 0 until size) {
            val rowNum = i / imageData.columnCount
            val columnNum = i % imageData.columnCount
            val left: Int =
                (imageData.targetImageSize * (if (imageData.columnCount == 1) columnNum + 0.5 else columnNum).toFloat()
                        + imageData.gap * (columnNum + 1)).toInt()
            val top: Int = (imageData.targetImageSize * (if (imageData.columnCount == 1) rowNum + 0.5 else rowNum).toFloat()
                    + imageData.gap * (rowNum + 1)).toInt()
            val right = left + imageData.targetImageSize
            val bottom = top + imageData.targetImageSize
            val bitmap = imageData.getBitmap(i)
            if (size == 1) {
                drawBitmapAtPosition(canvas, left, top, right, bottom, bitmap)
            } else if (size == 2) {
                drawBitmapAtPosition(canvas, left, center, right, center + imageData.targetImageSize, bitmap)
            } else if (size == 3) {
                if (i == 0) {
                    drawBitmapAtPosition(canvas, center, top, center + imageData.targetImageSize, bottom, bitmap)
                } else {
                    drawBitmapAtPosition(
                        canvas, imageData.gap * i + imageData.targetImageSize * (i - 1), tCenter,
                        imageData.gap * i + imageData.targetImageSize * i, tCenter + imageData.targetImageSize,
                        bitmap
                    )
                }
            } else if (size == 4) {
                drawBitmapAtPosition(canvas, left, top, right, bottom, bitmap)
            } else if (size == 5) {
                if (i == 0) {
                    drawBitmapAtPosition(
                        canvas, rCenter - imageData.targetImageSize,
                        rCenter - imageData.targetImageSize, rCenter, rCenter, bitmap
                    )
                } else if (i == 1) {
                    drawBitmapAtPosition(
                        canvas, lCenter, rCenter - imageData.targetImageSize,
                        lCenter + imageData.targetImageSize, rCenter, bitmap
                    )
                } else {
                    drawBitmapAtPosition(
                        canvas, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 2),
                        tCenter, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 1), tCenter
                                + imageData.targetImageSize, bitmap
                    )
                }
            } else if (size == 6) {
                if (i < 3) {
                    drawBitmapAtPosition(
                        canvas, imageData.gap * (i + 1) + imageData.targetImageSize * i,
                        bCenter - imageData.targetImageSize,
                        imageData.gap * (i + 1) + imageData.targetImageSize * (i + 1), bCenter, bitmap
                    )
                } else {
                    drawBitmapAtPosition(
                        canvas, imageData.gap * (i - 2) + imageData.targetImageSize * (i - 3),
                        tCenter, imageData.gap * (i - 2) + imageData.targetImageSize * (i - 2), tCenter
                                + imageData.targetImageSize, bitmap
                    )
                }
            } else if (size == 7) {
                if (i == 0) {
                    drawBitmapAtPosition(
                        canvas, center, imageData.gap, center + imageData.targetImageSize,
                        imageData.gap + imageData.targetImageSize, bitmap
                    )
                } else if (i > 0 && i < 4) {
                    drawBitmapAtPosition(
                        canvas, imageData.gap * i + imageData.targetImageSize * (i - 1), center,
                        imageData.gap * i + imageData.targetImageSize * i, center + imageData.targetImageSize,
                        bitmap
                    )
                } else {
                    drawBitmapAtPosition(
                        canvas, imageData.gap * (i - 3) + imageData.targetImageSize * (i - 4),
                        tCenter + imageData.targetImageSize / 2,
                        imageData.gap * (i - 3) + imageData.targetImageSize * (i - 3),
                        tCenter + imageData.targetImageSize / 2 + imageData.targetImageSize, bitmap
                    )
                }
            } else if (size == 8) {
                if (i == 0) {
                    drawBitmapAtPosition(
                        canvas, rCenter - imageData.targetImageSize, imageData.gap, rCenter,
                        imageData.gap + imageData.targetImageSize, bitmap
                    )
                } else if (i == 1) {
                    drawBitmapAtPosition(
                        canvas, lCenter, imageData.gap, lCenter + imageData.targetImageSize,
                        imageData.gap + imageData.targetImageSize, bitmap
                    )
                } else if (i > 1 && i < 5) {
                    drawBitmapAtPosition(
                        canvas, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 2),
                        center, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 1),
                        center + imageData.targetImageSize, bitmap
                    )
                } else {
                    drawBitmapAtPosition(
                        canvas, imageData.gap * (i - 4) + imageData.targetImageSize * (i - 5),
                        tCenter + imageData.targetImageSize / 2,
                        imageData.gap * (i - 4) + imageData.targetImageSize * (i - 4),
                        tCenter + imageData.targetImageSize / 2 + imageData.targetImageSize, bitmap
                    )
                }
            } else if (size == 9) {
                drawBitmapAtPosition(canvas, left, top, right, bottom, bitmap)
            }
        }
    }

    private fun drawBitmapAtPosition(canvas: Canvas, left: Int, top: Int, right: Int, bottom: Int, bitmap: Bitmap?) {
        if (null != bitmap) {
            val rect = Rect(left, top, right, bottom)
            canvas.drawBitmap(bitmap, null, rect, null)
        }
    }

    @Throws(ExecutionException::class, InterruptedException::class)
    private fun asyncLoadImage(imgUrl: Any, targetImageSize: Int): Bitmap? {
        return loadBitmap(mContext, imgUrl, targetImageSize)
    }

    fun load(imageId: String?) {
        gridImageData?.let {
            if (it.size() == 0) {
                if (imageId != null && !TextUtils.equals(imageId, this.imageId)) {
                    return
                }
                loadImage(mContext, mImageView, defaultImage)
                return
            }
            if (it.size() == 1) {
                if (imageId != null && !TextUtils.equals(imageId, this.imageId)) {
                    return
                }
                if (it.imageUrlList!= null) {
                    loadImage(mContext, mImageView, it.imageUrlList!![0])
                }
                return
            }
            clearImage()
            val copyGridImageData = try {
                it.clone()
            } catch (e: CloneNotSupportedException) {
                e.printStackTrace()
                val urlList: ArrayList<Any?> = ArrayList()
                if (it.imageUrlList != null) {
                    urlList.addAll(it.imageUrlList!!)
                }
                GridImageData(urlList, it.defaultImageResId)
            }
            val gridParam = calculateGridParam(it.size())
            copyGridImageData.rowCount = gridParam[0]
            copyGridImageData.columnCount = gridParam[1]
            copyGridImageData.targetImageSize = (copyGridImageData.maxWidth - (copyGridImageData.columnCount + 1)
                    * copyGridImageData.gap) / if (copyGridImageData.columnCount == 1) 2 else copyGridImageData.columnCount
            val finalImageId = imageId
            execute {
                val file = File(TUIConfig.getImageBaseDir() + finalImageId)
                var cacheBitmapExists = false
                var existsBitmap: Bitmap? = null
                if (file.exists() && file.isFile) {
                    val options = BitmapFactory.Options()
                    existsBitmap = BitmapFactory.decodeFile(file.path, options)
                    if (options.outWidth > 0 && options.outHeight > 0) {
                        cacheBitmapExists = true
                    }
                }
                if (!cacheBitmapExists) {
                    asyncLoadImageList(copyGridImageData)
                    existsBitmap = synthesizeImageList(copyGridImageData)
                    storeBitmap(file, existsBitmap)
                }
                loadImage(existsBitmap, finalImageId)
            }
        }
    }

    private fun loadImage(bitmap: Bitmap?, targetId: String?) {
        runOnUIThread {
            if (TextUtils.equals(imageId, targetId)) {
                loadImage(mContext, mImageView, bitmap)
            }
        }
    }

    fun clearImage() {
        clear(mContext, mImageView)
    }

    private fun storeBitmap(outFile: File, bitmap: Bitmap) {
        if (!outFile.exists() || outFile.isDirectory) {
            outFile.parentFile.mkdirs()
        }
        var fOut: FileOutputStream? = null
        try {
            outFile.deleteOnExit()
            outFile.createNewFile()
            fOut = FileOutputStream(outFile)
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fOut)
            fOut.flush()
        } catch (e: IOException) {
            outFile.deleteOnExit()
        } finally {
            if (null != fOut) {
                try {
                    fOut.close()
                } catch (e: IOException) {
                    e.printStackTrace()
                    outFile.deleteOnExit()
                }
            }
        }
    }
}