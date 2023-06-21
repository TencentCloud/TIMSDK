package com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.photoview.view;

import android.widget.ImageView;

public class PhotoViewUtil {
    public static void checkZoomLevels(float minZoom, float midZoom, float maxZoom) {
        if (minZoom >= midZoom) {
            throw new IllegalArgumentException("Minimum zoom has to be less than Medium zoom. Call setMinimumZoom() with a more appropriate value");
        } else if (midZoom >= maxZoom) {
            throw new IllegalArgumentException("Medium zoom has to be less than Maximum zoom. Call setMaximumZoom() with a more appropriate value");
        }
    }

    public static boolean hasDrawable(ImageView imageView) {
        return imageView.getDrawable() != null;
    }

    public static boolean isSupportedScaleType(final ImageView.ScaleType scaleType) {
        if (scaleType == null) {
            return false;
        }
        if (scaleType == ImageView.ScaleType.MATRIX) {
            throw new IllegalStateException("Matrix scale type is not supported");
        }
        return true;
    }
}
