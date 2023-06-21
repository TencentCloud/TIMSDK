package com.tencent.qcloud.tuikit.tuicallkit.utils;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapShader;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.widget.ImageView;

import androidx.annotation.DrawableRes;
import androidx.annotation.RawRes;

import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestBuilder;
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.qcloud.tuikit.tuicallkit.R;

import java.security.MessageDigest;
import java.util.concurrent.ExecutionException;

public class ImageLoader {
    private static int radius = 0;

    public static void clear(Context context, ImageView imageView) {
        Glide.with(context).clear(imageView);
    }

    public static void loadImage(Context context, ImageView imageView, Object url) {
        loadImage(context, imageView, url, R.drawable.tuicalling_ic_avatar);
    }

    public static void loadImage(Context context, ImageView imageView, Object url, @DrawableRes int resId) {
        if (url == null || url == "") {
            if (imageView != null && resId != 0) {
                imageView.setImageResource(resId);
            }
            return;
        }
        Glide.with(context).load(url).placeholder(resId).error(loadTransform(context, resId, radius)).into(imageView);
    }

    public static void loadImage(Context context, ImageView imageView, @RawRes @DrawableRes Integer resourceId) {
        Glide.with(context).load(resourceId).into(imageView);
    }

    public static Bitmap loadBitmap(Context context, Object imageUrl, int targetImageSize) throws InterruptedException,
            ExecutionException {
        if (imageUrl == null) {
            return null;
        }
        return Glide.with(context).asBitmap().load(imageUrl)
                .apply(loadTransform(context, R.drawable.tuicalling_ic_avatar, radius))
                .into(targetImageSize, targetImageSize)
                .get();
    }

    public static void loadGifImage(Context context, ImageView imageView, @RawRes @DrawableRes int resourceId) {
        Glide.with(context).asGif().load(resourceId).into(imageView);
    }

    private static RequestBuilder<Drawable> loadTransform(Context context, @DrawableRes int resId, int radius) {
        return Glide.with(context).load(resId).placeholder(resId)
                .apply(new RequestOptions().centerCrop().transform(new GlideRoundTransform(context, radius)));
    }

    public static class GlideRoundTransform extends BitmapTransformation {
        private static float radius = 0f;

        public GlideRoundTransform(Context context, int dp) {
            radius = Resources.getSystem().getDisplayMetrics().density * dp;
        }

        @Override
        protected Bitmap transform(BitmapPool pool, Bitmap toTransform, int outWidth, int outHeight) {
            return roundCrop(pool, toTransform);
        }

        private static Bitmap roundCrop(BitmapPool pool, Bitmap source) {
            if (source == null) {
                return null;
            }

            Bitmap result = pool.get(source.getWidth(), source.getHeight(), Bitmap.Config.ARGB_8888);
            if (result == null) {
                result = Bitmap.createBitmap(source.getWidth(), source.getHeight(), Bitmap.Config.ARGB_8888);
            }

            Canvas canvas = new Canvas(result);
            Paint paint = new Paint();
            paint.setShader(new BitmapShader(source, BitmapShader.TileMode.CLAMP, BitmapShader.TileMode.CLAMP));
            paint.setAntiAlias(true);
            RectF rectF = new RectF(0f, 0f, source.getWidth(), source.getHeight());
            canvas.drawRoundRect(rectF, radius, radius, paint);
            return result;
        }

        @Override
        public void updateDiskCacheKey(MessageDigest messageDigest) {

        }
    }
}
