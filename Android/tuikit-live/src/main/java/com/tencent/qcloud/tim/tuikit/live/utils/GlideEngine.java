package com.tencent.qcloud.tim.tuikit.live.utils;

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
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RawRes;

import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestBuilder;
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.qcloud.tim.tuikit.live.TUIKitLive;

import java.security.MessageDigest;


public class GlideEngine {

    public static void clear(ImageView imageView) {
        Glide.with(TUIKitLive.getAppContext()).clear(imageView);
    }

    public static void loadImage(ImageView imageView, @Nullable String url) {
        Glide.with(TUIKitLive.getAppContext())
                .load(url)
                .into(imageView);
    }

    public static void loadImage(ImageView imageView, @RawRes @DrawableRes @Nullable Integer resourceId) {
        Glide.with(TUIKitLive.getAppContext())
                .load(resourceId)
                .into(imageView);
    }

    public static void loadImage(ImageView imageView, String url, @DrawableRes int resourceId) {
        Glide.with(TUIKitLive.getAppContext())
                .load(url)
                .error(resourceId)
                .into(imageView);
    }

    public static void loadImage(ImageView imageView, String url, @DrawableRes int resourceId, int radius) {
        Glide.with(TUIKitLive.getAppContext())
                .load(url)
                .apply(new RequestOptions().placeholder(resourceId).error(resourceId).centerCrop()
                        .transform(new GlideRoundTransform(imageView.getContext(), radius)))
                .thumbnail(loadTransform(imageView.getContext(), resourceId, radius))
                .thumbnail(loadTransform(imageView.getContext(), resourceId, radius))
                .into(imageView);
    }

    private static RequestBuilder<Drawable> loadTransform(Context context, @DrawableRes int placeholderId, int radius) {
        return Glide.with(context)
                .load(placeholderId)
                .apply(new RequestOptions().centerCrop()
                        .transform(new GlideRoundTransform(context, radius)));
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
            if (source == null) return null;

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
        public void updateDiskCacheKey(@NonNull MessageDigest messageDigest) {

        }
    }
}
