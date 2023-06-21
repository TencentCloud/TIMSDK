package com.tencent.qcloud.tuikit.tuicallkit.utils

import android.content.Context
import android.content.res.Resources
import android.graphics.*
import android.graphics.drawable.Drawable
import android.text.TextUtils
import android.widget.ImageView
import androidx.annotation.DrawableRes
import androidx.annotation.RawRes
import com.bumptech.glide.Glide
import com.bumptech.glide.RequestBuilder
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation
import com.bumptech.glide.request.RequestOptions
import java.security.MessageDigest

object ImageLoader {
    private val radius: Int = 1

    @JvmStatic
    fun loadImage(context: Context?, imageView: ImageView?, url: String?, @DrawableRes errorResId: Int) {
        loadImage(context, imageView, url, errorResId, radius)
    }

    @JvmName("loadImage1")
    @JvmOverloads
    fun loadImage(
        context: Context?, imageView: ImageView?, url: String?, @DrawableRes errorResId: Int = 0,
        radius: Int = this.radius
    ) {
        if (TextUtils.isEmpty(url)) {
            if (imageView != null && errorResId != 0) {
                imageView.setImageResource(errorResId)
            }
            return
        }
        Glide.with(context!!).load(url).error(loadTransform(context, errorResId, radius)).into(
            imageView!!
        )
    }

    fun loadGifImage(context: Context?, imageView: ImageView?, @RawRes @DrawableRes resourceId: Int) {
        Glide.with(context!!).asGif().load(resourceId).into(imageView!!)
    }

    fun clear(context: Context?, imageView: ImageView?) {
        Glide.with(context!!).clear(imageView!!)
    }


    private fun loadTransform(
        context: Context?,
        @DrawableRes placeholderId: Int,
        radius: Int
    ): RequestBuilder<Drawable> {
        return Glide.with(context!!).load(placeholderId)
            .apply(RequestOptions().centerCrop().transform(GlideRoundTransform(context, radius)))
    }

    class GlideRoundTransform(context: Context?, dp: Int) : BitmapTransformation() {
        override fun transform(pool: BitmapPool, toTransform: Bitmap, outWidth: Int, outHeight: Int): Bitmap {
            return roundCrop(pool, toTransform)!!
        }

        override fun updateDiskCacheKey(messageDigest: MessageDigest) {}

        companion object {
            private var radius = 0f
            private fun roundCrop(pool: BitmapPool, source: Bitmap?): Bitmap? {
                if (source == null) {
                    return null
                }
                var result: Bitmap? = pool[source.width, source.height, Bitmap.Config.ARGB_8888]
                if (result == null) {
                    result = Bitmap.createBitmap(source.width, source.height, Bitmap.Config.ARGB_8888)
                }
                val canvas = Canvas(result)
                val paint = Paint()
                paint.shader = BitmapShader(source, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
                paint.isAntiAlias = true
                val rectF = RectF(
                    0f, 0f, source.width.toFloat(), source.height
                        .toFloat()
                )
                canvas.drawRoundRect(rectF, radius, radius, paint)
                return result
            }
        }

        init {
            radius = Resources.getSystem().displayMetrics.density * dp
        }
    }

}