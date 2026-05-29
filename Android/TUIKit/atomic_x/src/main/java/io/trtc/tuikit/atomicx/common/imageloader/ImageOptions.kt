package io.trtc.tuikit.atomicx.common.imageloader

class ImageOptions private constructor(
    val placeImage: Int,
    val errorImage: Int,
    val roundRadius: Int,
    val isGif: Boolean,
    val skipMemoryCache: Boolean,
    val skipDiskCache: Boolean,
    val blurEffect: Float
) {

    class Builder {
        var placeImage: Int = 0
            private set
        var errorImage: Int = 0
            private set
        var roundRadius: Int = 0
            private set
        var isGif: Boolean = false
            private set
        val skipMemoryCache: Boolean = false
        val skipDiskCache: Boolean = false
        var blurEffect: Float = 0f // range: 0~100
            private set

        fun setPlaceImage(placeImage: Int): Builder {
            this.placeImage = placeImage
            return this
        }

        fun setErrorImage(errorImage: Int): Builder {
            this.errorImage = errorImage
            return this
        }

        fun setRoundRadius(roundRadius: Int): Builder {
            this.roundRadius = roundRadius
            return this
        }

        fun asGif(isGif: Boolean): Builder {
            this.isGif = isGif
            return this
        }

        fun setBlurEffect(level: Float): Builder {
            this.blurEffect = level
            return this
        }

        fun build(): ImageOptions {
            return ImageOptions(
                placeImage = placeImage,
                errorImage = errorImage,
                roundRadius = roundRadius,
                isGif = isGif,
                skipMemoryCache = skipMemoryCache,
                skipDiskCache = skipDiskCache,
                blurEffect = blurEffect
            )
        }
    }
}
