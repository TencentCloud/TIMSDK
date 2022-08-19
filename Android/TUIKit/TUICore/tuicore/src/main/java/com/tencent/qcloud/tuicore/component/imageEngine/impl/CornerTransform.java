package com.tencent.qcloud.tuicore.component.imageEngine.impl;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapShader;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Shader;

import androidx.annotation.NonNull;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.Transformation;
import com.bumptech.glide.load.engine.Resource;
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.BitmapResource;

import java.security.MessageDigest;

public class CornerTransform implements Transformation<Bitmap> {

    private BitmapPool mBitmapPool;
    private float radius;
    private boolean exceptLeftTop, exceptRightTop, exceptLeftBottom, exceptRightBottom;

    public CornerTransform(Context context, float radius) {
        this.mBitmapPool = Glide.get(context).getBitmapPool();
        this.radius = radius;
    }

    public void setExceptCorner(boolean leftTop, boolean rightTop, boolean leftBottom, boolean rightBottom) {
        this.exceptLeftTop = leftTop;
        this.exceptRightTop = rightTop;
        this.exceptLeftBottom = leftBottom;
        this.exceptRightBottom = rightBottom;
    }

    @NonNull
    @Override
    public Resource<Bitmap> transform(@NonNull Context context, @NonNull Resource<Bitmap> resource, int outWidth, int outHeight) {
        Bitmap source = resource.get();
        int finalWidth, finalHeight;
        // 输出目标的宽高或高宽比例
        // The width-height or height-width ratio of the output target
        float ratio;
        if (outWidth > outHeight) {
            // 输出宽度>输出高度,求高宽比
            // output width > output height, find the aspect ratio
            ratio = (float) outHeight / (float) outWidth;
            finalWidth = source.getWidth();
            // 固定原图宽度,求最终高度
            // Fix the width of the original image and find the final height
            finalHeight = (int) ((float) source.getWidth() * ratio); 
            if (finalHeight > source.getHeight()) {
                // 求出的最终高度>原图高度,求宽高比
                // Find the final height > the original image height, find the aspect ratio
                ratio = (float) outWidth / (float) outHeight;
                finalHeight = source.getHeight();
                // 固定原图高度,求最终宽度
                // Fix the width of the original image and find the final width
                finalWidth = (int) ((float) source.getHeight() * ratio);
            }
        } else if (outWidth < outHeight) { 
            // 输出宽度 < 输出高度,求宽高比
            // output width < output height, find the aspect ratio
            ratio = (float) outWidth / (float) outHeight;
            finalHeight = source.getHeight();
            // 固定原图高度,求最终宽度
            // Fix the width of the original image and find the final width
            finalWidth = (int) ((float) source.getHeight() * ratio);
            if (finalWidth > source.getWidth()) { 
                // 求出的最终宽度 > 原图宽度,求高宽比
                // Find the final width > the original image width, find the aspect ratio
                ratio = (float) outHeight / (float) outWidth;
                finalWidth = source.getWidth();
                finalHeight = (int) ((float) source.getWidth() * ratio);
            }
        } else { 
            // 输出宽度=输出高度
            // output width = output height
            finalHeight = source.getHeight();
            finalWidth = finalHeight;
        }

        // 修正圆角
        // Correct rounded corners
        this.radius *= (float) finalHeight / (float) outHeight;
        Bitmap outBitmap = this.mBitmapPool.get(finalWidth, finalHeight, Bitmap.Config.ARGB_8888);
        if (outBitmap == null) {
            outBitmap = Bitmap.createBitmap(finalWidth, finalHeight, Bitmap.Config.ARGB_8888);
        }

        Canvas canvas = new Canvas(outBitmap);
        Paint paint = new Paint();
        BitmapShader shader = new BitmapShader(source, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP);
        // 计算中心位置,进行偏移
        // Calculate the center position and offset it
        int width = (source.getWidth() - finalWidth) / 2;
        int height = (source.getHeight() - finalHeight) / 2;
        if (width != 0 || height != 0) {
            Matrix matrix = new Matrix();
            matrix.setTranslate((float) (-width), (float) (-height));
            shader.setLocalMatrix(matrix);
        }

        paint.setShader(shader);
        paint.setAntiAlias(true);
        RectF rectF = new RectF(0.0F, 0.0F, (float) canvas.getWidth(), (float) canvas.getHeight());
        canvas.drawRoundRect(rectF, this.radius, this.radius, paint);

        if (exceptLeftTop) {
            canvas.drawRect(0, 0, radius, radius, paint);
        }
        if (exceptRightTop) {
            canvas.drawRect(canvas.getWidth() - radius, 0, radius, radius, paint);
        }

        if (exceptLeftBottom) {
            canvas.drawRect(0, canvas.getHeight() - radius, radius, canvas.getHeight(), paint);
        }

        if (exceptRightBottom) {
            canvas.drawRect(canvas.getWidth() - radius, canvas.getHeight() - radius, canvas.getWidth(), canvas.getHeight(), paint);
        }

        return BitmapResource.obtain(outBitmap, this.mBitmapPool);
    }

    @Override
    public void updateDiskCacheKey(@NonNull MessageDigest messageDigest) {

    }
}