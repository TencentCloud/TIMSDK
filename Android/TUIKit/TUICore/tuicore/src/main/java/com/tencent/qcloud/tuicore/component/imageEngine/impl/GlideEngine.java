package com.tencent.qcloud.tuicore.component.imageEngine.impl;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.widget.ImageView;

import androidx.annotation.DrawableRes;

import com.bumptech.glide.Glide;
import com.bumptech.glide.Priority;
import com.bumptech.glide.RequestBuilder;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.imageEngine.ImageEngine;

import java.io.File;
import java.util.concurrent.ExecutionException;

public class GlideEngine implements ImageEngine {


    public static void loadCornerImage(ImageView imageView, String filePath, RequestListener listener, float radius) {
        CornerTransform transform = new CornerTransform(TUILogin.getAppContext(), radius);
        RequestOptions options = new RequestOptions()
                .centerCrop()
                .placeholder(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon))
                .transform(transform);
        Glide.with(TUILogin.getAppContext())
                .load(filePath)
                .apply(options)
                .listener(listener)
                .into(imageView);
    }

    public static void loadCornerImageWithoutPlaceHolder(ImageView imageView, String filePath, RequestListener listener, float radius) {
        CornerTransform transform = new CornerTransform(TUILogin.getAppContext(), radius);
        RequestOptions options = new RequestOptions()
                .centerCrop()
                .transform(transform);
        Glide.with(TUILogin.getAppContext())
                .load(filePath)
                .apply(options)
                .listener(listener)
                .into(imageView);
    }

    public static void loadImage(ImageView imageView, String userAvatar, int resId, float radius) {
        loadCornerImage(imageView, userAvatar, null, radius);
    }

    public static void loadImage(ImageView imageView, String filePath, RequestListener listener) {
        Glide.with(TUILogin.getAppContext())
                .load(filePath)
                .listener(listener)
                .apply(new RequestOptions().error(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon)))
                .into(imageView);
    }

    public static void loadImage(ImageView imageView, String filePath) {
        Glide.with(TUILogin.getAppContext())
                .load(filePath)
                .apply(new RequestOptions().error(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon)))
                .into(imageView);
    }

    public static void loadProfileImage(ImageView imageView, String filePath, RequestListener listener) {
        Glide.with(TUILogin.getAppContext())
                .load(filePath)
                .listener(listener)
                .apply(new RequestOptions().error(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon)))
                .into(imageView);
    }

    public static void clear(ImageView imageView) {
        Glide.with(TUILogin.getAppContext()).clear(imageView);
    }

    public static void loadImage(ImageView imageView, Uri uri) {
        if (uri == null) {
            return;
        }
        Glide.with(TUILogin.getAppContext())
                .load(uri)
                .apply(new RequestOptions().error(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon)))
                .into(imageView);
    }

    public static void loadImage(String filePath, String url) {
        try {
            File file = Glide.with(TUILogin.getAppContext()).asFile().load(url).submit().get();
            File destFile = new File(filePath);
            file.renameTo(destFile);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
    }

    public static void loadImage(ImageView imageView, Object uri) {
        if (uri == null) {
            return;
        }
        Glide.with(TUILogin.getAppContext())
                .load(uri)
                .apply(new RequestOptions().error(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon)))
                .into(imageView);
    }

    public static void loadUserIcon(ImageView imageView, Object uri) {
        loadUserIcon(imageView, uri, 0);
    }

    public static void loadUserIcon(ImageView imageView, Object uri, int radius) {
        Glide.with(TUILogin.getAppContext())
                .load(uri)
                .placeholder(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon))
                .apply(new RequestOptions().centerCrop().error(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon)))
                .into(imageView);
    }

    public static void loadUserIcon(ImageView imageView, Object uri, int defaultResId, int radius) {
        Glide.with(TUILogin.getAppContext())
                .load(uri)
                .placeholder(defaultResId)
                .apply(new RequestOptions().centerCrop().error(defaultResId))
                .into(imageView);
    }

    private static RequestBuilder<Drawable> loadTransform(Context context, @DrawableRes int placeholderId, float radius) {
        return Glide.with(context)
                .load(placeholderId)
                .apply(new RequestOptions().centerCrop()
                        .transform(new CornerTransform(context, radius)));
    }

    public static Bitmap loadBitmap(Object imageUrl, int targetImageSize) throws InterruptedException, ExecutionException {
        if (imageUrl == null) {
            return null;
        }
        return Glide.with(TUILogin.getAppContext()).asBitmap()
                .load(imageUrl)
                .apply(new RequestOptions().error(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon)))
                .into(targetImageSize, targetImageSize)
                .get();
    }

    @Override
    public void loadThumbnail(Context context, int resize, Drawable placeholder, ImageView imageView, Uri uri) {
        Glide.with(context)
                .asBitmap() // some .jpeg files are actually gif
                .load(uri)
                .apply(new RequestOptions()
                        .override(resize, resize)
                        .placeholder(placeholder)
                        .centerCrop())
                .into(imageView);
    }

    @Override
    public void loadGifThumbnail(Context context, int resize, Drawable placeholder, ImageView imageView,
                                 Uri uri) {
        Glide.with(context)
                .asBitmap() // some .jpeg files are actually gif
                .load(uri)
                .apply(new RequestOptions()
                        .override(resize, resize)
                        .placeholder(placeholder)
                        .centerCrop())
                .into(imageView);
    }

    @Override
    public void loadImage(Context context, int resizeX, int resizeY, ImageView imageView, Uri uri) {
        Glide.with(context)
                .load(uri)
                .apply(new RequestOptions()
                        .override(resizeX, resizeY)
                        .priority(Priority.HIGH)
                        .fitCenter())
                .into(imageView);
    }

    @Override
    public void loadGifImage(Context context, int resizeX, int resizeY, ImageView imageView, Uri uri) {
        Glide.with(context)
                .asGif()
                .load(uri)
                .apply(new RequestOptions()
                        .override(resizeX, resizeY)
                        .priority(Priority.HIGH)
                        .fitCenter())
                .into(imageView);
    }

    @Override
    public boolean supportAnimatedGif() {
        return true;
    }

}
