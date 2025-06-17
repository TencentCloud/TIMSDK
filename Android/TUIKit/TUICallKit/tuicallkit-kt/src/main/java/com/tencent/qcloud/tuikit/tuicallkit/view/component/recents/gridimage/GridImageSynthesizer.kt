package com.tencent.qcloud.tuikit.tuicallkit.view.component.recents.gridimage

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Rect
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.widget.ImageView
import com.tencent.qcloud.tuicore.TUIConfig
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.imageloader.ImageOptions
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.concurrent.ExecutionException
import java.util.concurrent.ExecutorService
import java.util.concurrent.SynchronousQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

class GridImageSynthesizer(context: Context, view: ImageView) {
    private val context: Context = context.applicationContext
    private val mainHandler = Handler(Looper.getMainLooper())
    private var executors: ExecutorService? = null

    private val imageView: ImageView = view
    private var gridImageData: GridImageData = GridImageData()
    private var imageId = ""

    fun setImageId(id: String?) {
        imageId = id ?: ""
    }

    fun setImageUrls(list: List<Any?>?) {
        gridImageData.imageUrlList = list
    }

    fun setMaxSize(maxWidth: Int, maxHeight: Int) {
        gridImageData.maxWidth = maxWidth
        gridImageData.maxHeight = maxHeight
    }

    fun setBackgroundColor(bgColor: Int) {
        gridImageData.bgColor = bgColor
    }

    fun setGap(gap: Int) {
        gridImageData.gap = gap
    }

    fun setDefaultImage(resId: Int) {
        gridImageData.defaultImageResId = resId
    }

    private fun getDefaultImage(): Int {
        return gridImageData.defaultImageResId
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
                val defaultIcon = BitmapFactory.decodeResource(context.resources, R.drawable.tuicallkit_ic_avatar)
                try {
                    val bitmap = asyncLoadImage(it[i] ?: "", imageData.targetImageSize)
                    if (bitmap != null) {
                        imageData.putBitmap(bitmap, i)
                    } else {
                        imageData.putBitmap(defaultIcon, i)
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
            val top = (imageData.targetImageSize * (if (imageData.columnCount == 1) rowNum + 0.5 else rowNum).toFloat()
                    + imageData.gap * (rowNum + 1)).toInt()
            val right = left + imageData.targetImageSize
            val bottom = top + imageData.targetImageSize
            val bitmap = imageData.getBitmap(i)

            if (size == 1 || size == 4 || size == 9) {
                drawBitmapAtPosition(canvas, left, top, right, bottom, bitmap)
                continue
            }
            if (size == 2) {
                drawBitmapAtPosition(canvas, left, center, right, center + imageData.targetImageSize, bitmap)
                continue
            }
            if (size == 3) {
                when (i) {
                    0 -> drawBitmapAtPosition(canvas, center, top, center + imageData.targetImageSize, bottom, bitmap)
                    else -> drawBitmapAtPosition(
                        canvas, imageData.gap * i + imageData.targetImageSize * (i - 1), tCenter,
                        imageData.gap * i + imageData.targetImageSize * i, tCenter + imageData.targetImageSize,
                        bitmap
                    )
                }
                continue
            }

            if (size == 5) {
                when (i) {
                    0 -> drawBitmapAtPosition(
                        canvas, rCenter - imageData.targetImageSize,
                        rCenter - imageData.targetImageSize, rCenter, rCenter, bitmap
                    )
                    1 -> drawBitmapAtPosition(
                        canvas, lCenter, rCenter - imageData.targetImageSize,
                        lCenter + imageData.targetImageSize, rCenter, bitmap
                    )
                    else -> drawBitmapAtPosition(
                        canvas, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 2),
                        tCenter, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 1),
                        tCenter + imageData.targetImageSize, bitmap
                    )
                }
                continue
            }
            if (size == 6) {
                when {
                    i < 3 -> drawBitmapAtPosition(
                        canvas, imageData.gap * (i + 1) + imageData.targetImageSize * i,
                        bCenter - imageData.targetImageSize,
                        imageData.gap * (i + 1) + imageData.targetImageSize * (i + 1), bCenter, bitmap
                    )
                    else -> drawBitmapAtPosition(
                        canvas, imageData.gap * (i - 2) + imageData.targetImageSize * (i - 3),
                        tCenter, imageData.gap * (i - 2) + imageData.targetImageSize * (i - 2),
                        tCenter + imageData.targetImageSize, bitmap
                    )
                }
                continue
            }

            if (size == 7) {
                when (i) {
                    0 -> drawBitmapAtPosition(
                        canvas, center, imageData.gap, center + imageData.targetImageSize,
                        imageData.gap + imageData.targetImageSize, bitmap
                    )
                    in 1..3 -> drawBitmapAtPosition(
                        canvas, imageData.gap * i + imageData.targetImageSize * (i - 1), center,
                        imageData.gap * i + imageData.targetImageSize * i, center + imageData.targetImageSize,
                        bitmap
                    )
                    else -> drawBitmapAtPosition(
                        canvas, imageData.gap * (i - 3) + imageData.targetImageSize * (i - 4),
                        tCenter + imageData.targetImageSize / 2,
                        imageData.gap * (i - 3) + imageData.targetImageSize * (i - 3),
                        tCenter + imageData.targetImageSize / 2 + imageData.targetImageSize, bitmap
                    )
                }
                continue
            }

            if (size == 8) {
                when (i) {
                    0 -> drawBitmapAtPosition(
                        canvas, rCenter - imageData.targetImageSize, imageData.gap, rCenter,
                        imageData.gap + imageData.targetImageSize, bitmap
                    )
                    1 -> drawBitmapAtPosition(
                        canvas, lCenter, imageData.gap, lCenter + imageData.targetImageSize,
                        imageData.gap + imageData.targetImageSize, bitmap
                    )
                    in 2..4 -> drawBitmapAtPosition(
                        canvas, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 2),
                        center, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 1),
                        center + imageData.targetImageSize, bitmap
                    )
                    else -> drawBitmapAtPosition(
                        canvas, imageData.gap * (i - 4) + imageData.targetImageSize * (i - 5),
                        tCenter + imageData.targetImageSize / 2,
                        imageData.gap * (i - 4) + imageData.targetImageSize * (i - 4),
                        tCenter + imageData.targetImageSize / 2 + imageData.targetImageSize, bitmap
                    )
                }
                continue
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
        val option = ImageOptions.Builder().setPlaceImage(R.drawable.tuicallkit_ic_avatar).build()
        return ImageLoader.transformBitmap(context, imgUrl, targetImageSize, targetImageSize, option)
    }

    fun load(imageId: String?) {
        if (gridImageData.size() == 0) {
            if (imageId != null && !TextUtils.equals(imageId, this.imageId)) {
                return
            }
            ImageLoader.load(context, imageView, getDefaultImage(), R.drawable.tuicallkit_ic_avatar)
            return
        }
        if (gridImageData.size() == 1) {
            if (imageId != null && !TextUtils.equals(imageId, this.imageId)) {
                return
            }
            if (gridImageData.imageUrlList != null) {
                ImageLoader.load(context, imageView, gridImageData.imageUrlList!![0], R.drawable.tuicallkit_ic_avatar)
            }
            return
        }
        clearImage()
        val copyGridImageData = try {
            gridImageData.clone()
        } catch (e: CloneNotSupportedException) {
            e.printStackTrace()
            val urlList: ArrayList<Any?> = ArrayList()
            if (gridImageData.imageUrlList != null) {
                urlList.addAll(gridImageData.imageUrlList!!)
            }
            GridImageData(urlList, gridImageData.defaultImageResId)
        }
        val gridParam = calculateGridParam(gridImageData.size())
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

    private fun loadImage(bitmap: Bitmap?, targetId: String?) {
        mainHandler.post {
            if (TextUtils.equals(imageId, targetId)) {
                ImageLoader.load(context, imageView, bitmap, R.drawable.tuicallkit_ic_avatar)
            }
        }
    }

    fun clearImage() {
        ImageLoader.clear(context, imageView)
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

    private fun execute(runnable: Runnable) {
        if (executors == null) {
            executors = ThreadPoolExecutor(
                0, Int.MAX_VALUE, 60L, TimeUnit.SECONDS,
                SynchronousQueue()
            )
        }
        executors?.execute(runnable)
    }

    internal class GridImageData : Cloneable {
        var imageUrlList: List<Any?>? = ArrayList()
        var defaultImageResId: Int = 0
        var bgColor: Int = Color.parseColor("#cfd3d8")
        var targetImageSize: Int = 0
        var maxWidth: Int = 100
        var maxHeight: Int = 100
        var rowCount: Int = 0
        var columnCount: Int = 0
        var gap: Int = 6

        private var bitmapMap: MutableMap<Int, Bitmap?> = HashMap()

        constructor()

        constructor(imageUrlList: List<Any?>?, defaultImageResId: Int) {
            this.imageUrlList = imageUrlList
            this.defaultImageResId = defaultImageResId
        }

        fun putBitmap(bitmap: Bitmap, position: Int) {
            synchronized(bitmapMap) { bitmapMap.put(position, bitmap) }
        }

        fun getBitmap(position: Int): Bitmap? {
            synchronized(bitmapMap) { return bitmapMap[position] }
            return null
        }

        fun size(): Int {
            imageUrlList?.let {
                return Integer.min(it.size, MAX_SIZE)
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
            gridImageData.bitmapMap.putAll(bitmapMap)
            return gridImageData
        }

        companion object {
            private const val MAX_SIZE = 9
        }
    }
}