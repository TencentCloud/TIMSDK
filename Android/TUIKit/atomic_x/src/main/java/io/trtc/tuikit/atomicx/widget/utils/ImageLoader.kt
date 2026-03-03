package io.trtc.tuikit.atomicx.widget.utils

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.RenderEffect
import android.graphics.Shader
import android.os.Build
import android.util.TypedValue
import android.widget.ImageView
import androidx.annotation.DrawableRes
import androidx.annotation.RawRes
import com.bumptech.glide.Glide
import com.bumptech.glide.RequestBuilder
import com.bumptech.glide.load.MultiTransformation
import com.bumptech.glide.load.Transformation
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation
import com.bumptech.glide.load.resource.bitmap.CenterCrop
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.bumptech.glide.request.RequestOptions
import java.security.MessageDigest

object ImageLoader {

    @JvmStatic
    fun load(context: Context, target: ImageView?, source: Any?, @DrawableRes placeImage: Int) {
        val imageOptions = ImageOptions.Builder()
            .setPlaceImage(placeImage)
            .build()
        load(context, target, source, imageOptions)
    }

    @JvmStatic
    fun load(context: Context, target: ImageView?, source: Any?, config: ImageOptions) {
        if (target == null) {
            return
        }

        if (source == null) {
            val image = if (config.placeImage != 0) config.placeImage else config.errorImage
            target.setImageResource(image)
            return
        }

        loadImageView(context, target, source, config)
    }

    @JvmStatic
    fun loadGif(context: Context, target: ImageView?, @RawRes @DrawableRes resourceId: Int) {
        if (target == null) {
            return
        }
        Glide.with(context.applicationContext)
            .asGif()
            .load(resourceId)
            .into(target)
    }

    @JvmStatic
    fun transformBitmap(
        context: Context,
        source: Any?,
        width: Int,
        height: Int,
        options: ImageOptions
    ): Bitmap? {
        if (source == null) {
            return null
        }

        val builder = Glide.with(context.applicationContext)
            .asBitmap()
            .load(source)

        setBuilderOptions(context.applicationContext, builder, options)

        return try {
            builder.submit(width, height).get()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    @JvmStatic
    fun clear(context: Context, target: ImageView?) {
        if (target != null) {
            Glide.with(context.applicationContext).clear(target)
        }
    }

    private fun loadImageView(context: Context, target: ImageView, source: Any, config: ImageOptions) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            if (context is Activity) {
                if (context.isFinishing || context.isDestroyed) {
                    return
                }
            }
        }

        val builder = if (config.isGif) {
            Glide.with(context.applicationContext).asGif().load(source)
        } else {
            Glide.with(context.applicationContext).load(source)
        }

        setBuilderOptions(context.applicationContext, builder, config)
        builder.into(target)
        setRenderEffect(target, config)
    }

    private fun setRenderEffect(target: ImageView, config: ImageOptions) {
        val level = config.blurEffect
        if (level > 0 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            target.setRenderEffect(
                RenderEffect.createBlurEffect(level, level, Shader.TileMode.MIRROR)
            )
        }
    }

    private fun setBuilderOptions(context: Context, builder: RequestBuilder<*>, config: ImageOptions) {
        val options = RequestOptions()

        val transformations = mutableListOf<Transformation<Bitmap>>()
        transformations.add(CenterCrop())

        if (config.roundRadius > 0) {
            transformations.add(RoundedCorners(dpToPx(context, config.roundRadius)))
        }

        if (config.blurEffect > 0 && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            transformations.add(BlurTransformation(context, config.blurEffect))
        }

        options.transform(MultiTransformation(transformations))

        if (config.placeImage != 0) {
            options.placeholder(config.placeImage)
        }

        if (config.errorImage != 0) {
            options.error(config.errorImage)
        }

        options.diskCacheStrategy(
            if (config.skipDiskCache) DiskCacheStrategy.NONE else DiskCacheStrategy.ALL
        )
        options.skipMemoryCache(config.skipMemoryCache)

        builder.apply(options)
    }

    private fun dpToPx(context: Context, dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp.toFloat(),
            context.resources.displayMetrics
        ).toInt()
    }

    class BlurTransformation(
        context: Context,
        level: Float
    ) : BitmapTransformation() {

        private val radius: Float = level * 0.25f
        private val contextRef = java.lang.ref.WeakReference(context)

        override fun updateDiskCacheKey(messageDigest: MessageDigest) {
            messageDigest.update("blur:$radius".toByteArray())
        }

        override fun transform(
            pool: BitmapPool,
            toTransform: Bitmap,
            outWidth: Int,
            outHeight: Int
        ): Bitmap {
            val context = contextRef.get() ?: return toTransform
            return BlurUtils.blur(context, pool, toTransform, radius.toInt())
        }
    }
}
