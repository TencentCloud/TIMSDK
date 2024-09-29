package com.tencent.cloud.tuikit.roomkit.common.utils;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapShader;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.widget.ImageView;

import androidx.annotation.DrawableRes;
import androidx.annotation.RawRes;

import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestBuilder;
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation;
import com.bumptech.glide.request.RequestOptions;

import java.security.MessageDigest;
import java.util.concurrent.ExecutionException;

public class ImageLoader {
    private static int radius = 15;

    public static void clear(Context context, ImageView imageView) {
        Glide.with(context).clear(imageView);
    }

    public static void clear(Context context) {
        Glide.with(context).pauseRequests();
    }

    public static void loadImage(Context context, ImageView imageView, String url) {
        loadImage(context, imageView, url, 0, radius);
    }

    public static void loadImage(Context context, ImageView imageView, String url, @DrawableRes int errorResId) {
        loadImage(context, imageView, url, errorResId, radius);
    }

    public static void loadImage(Context context, ImageView imageView, String url,
                                 @DrawableRes int errorResId, int radius) {
        if (TextUtils.isEmpty(url)) {
            if (imageView != null && errorResId != 0) {
                imageView.setImageResource(errorResId);
            }
            return;
        }
        if (context instanceof Activity && ((Activity)context).isDestroyed()) {
            return;
        }
        Glide.with(context).load(url).error(loadTransform(context, errorResId, radius)).into(imageView);
    }

    public static void loadImage(Context context, ImageView imageView, @RawRes @DrawableRes Integer resourceId) {
        Glide.with(context).load(resourceId).into(imageView);
    }

    public static Bitmap getImage(Context context, String url, int width, int height) {
        if (TextUtils.isEmpty(url)) {
            return null;
        }
        try {
            Bitmap bitmap = Glide.with(context)
                    .asBitmap()
                    .load(url)
                    .into(width, height)
                    .get();
            return bitmap;
        } catch (ExecutionException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void loadImageThumbnail(Context context, ImageView imageView,
                                          String url, @DrawableRes int resourceId, int radius) {
        Glide.with(context).load(url)
                .apply(new RequestOptions().placeholder(resourceId).error(resourceId).centerCrop()
                        .transform(new GlideRoundTransform(imageView.getContext(), radius)))
                .thumbnail(loadTransform(imageView.getContext(), resourceId, radius))
                .into(imageView);
    }

    public static void loadGifImage(Context context, ImageView imageView, String url) {
        loadGifImage(context, imageView, url, 0);
    }

    public static void loadGifImage(Context context, ImageView imageView, String url, @DrawableRes int errorResId) {
        if (TextUtils.isEmpty(url)) {
            if (imageView != null && errorResId != 0) {
                imageView.setImageResource(errorResId);
            }
            return;
        }
        Glide.with(context).asGif().load(url).into(imageView);
    }

    public static void loadGifImage(Context context, ImageView imageView, @RawRes @DrawableRes int resourceId) {
        Glide.with(context).asGif().load(resourceId).into(imageView);
    }

    private static RequestBuilder<Drawable> loadTransform(Context context, @DrawableRes int placeholderId, int radius) {
        return Glide.with(context).load(placeholderId)
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
