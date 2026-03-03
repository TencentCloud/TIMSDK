package io.trtc.tuikit.atomicx.widget.utils

import androidx.annotation.DrawableRes

data class ImageOptions(
    @DrawableRes val placeImage: Int = 0,
    @DrawableRes val errorImage: Int = 0,
    val roundRadius: Int = 0,
    val isGif: Boolean = false,
    val skipMemoryCache: Boolean = false,
    val skipDiskCache: Boolean = false,
    val blurEffect: Float = 0f
) {
    class Builder {
        private var placeImage: Int = 0
        private var errorImage: Int = 0
        private var roundRadius: Int = 0
        private var isGif: Boolean = false
        private var skipMemoryCache: Boolean = false
        private var skipDiskCache: Boolean = false
        private var blurEffect: Float = 0f

        fun setPlaceImage(@DrawableRes placeImage: Int) = apply {
            this.placeImage = placeImage
        }

        fun setErrorImage(@DrawableRes errorImage: Int) = apply {
            this.errorImage = errorImage
        }

        fun setRoundRadius(roundRadius: Int) = apply {
            this.roundRadius = roundRadius
        }

        fun asGif(isGif: Boolean) = apply {
            this.isGif = isGif
        }

        fun setSkipMemoryCache(skip: Boolean) = apply {
            this.skipMemoryCache = skip
        }

        fun setSkipDiskCache(skip: Boolean) = apply {
            this.skipDiskCache = skip
        }

        fun setBlurEffect(level: Float) = apply {
            this.blurEffect = level
        }

        fun build() = ImageOptions(
            placeImage = placeImage,
            errorImage = errorImage,
            roundRadius = roundRadius,
            isGif = isGif,
            skipMemoryCache = skipMemoryCache,
            skipDiskCache = skipDiskCache,
            blurEffect = blurEffect
        )
    }

    companion object {
        @JvmStatic
        fun default() = ImageOptions()

        @JvmStatic
        fun withPlaceholder(@DrawableRes placeImage: Int) = ImageOptions(placeImage = placeImage)
    }
}
