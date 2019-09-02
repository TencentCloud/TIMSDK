package com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.text.TextUtils;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.Priority;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.ImageEngine;

import java.io.File;
import java.util.concurrent.ExecutionException;


public class GlideEngine implements ImageEngine {


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

    public static void loadCornerImage(ImageView imageView, String filePath, RequestListener listener, float radius) {
        CornerTransform transform = new CornerTransform(TUIKit.getAppContext(), radius);
        ColorDrawable drawable = new ColorDrawable(Color.GRAY);
        RequestOptions options = new RequestOptions()
                .centerCrop()
                .placeholder(drawable)
                .transform(transform);
        Glide.with(TUIKit.getAppContext())
                .load(filePath)
                .apply(options)
                .listener(listener)
                .into(imageView);
    }

    public static void loadImage(ImageView imageView, String filePath, RequestListener listener) {
        Glide.with(TUIKit.getAppContext())
                .load(filePath)
                .listener(listener)
                .into(imageView);
    }

    public static void loadProfileImage(ImageView imageView, String filePath, RequestListener listener) {
        Glide.with(TUIKit.getAppContext())
                .load(filePath)
                .listener(listener)
                .apply(new RequestOptions().error(R.drawable.default_user_icon))
                .into(imageView);
    }

    public static void loadImage(ImageView imageView, Uri uri) {
        if (uri == null) {
            return;
        }
        Glide.with(TUIKit.getAppContext())
                .load(uri)
                .apply(new RequestOptions().error(R.drawable.default_user_icon))
                .into(imageView);
    }


    public static void loadImage(String filePath, String url) {
        try {
            File file = Glide.with(TUIKit.getAppContext()).asFile().load(url).submit().get();
            File destFile = new File(filePath);
            file.renameTo(destFile);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
    }

    public static Bitmap loadBitmap(String imageUrl, int targetImageSize) throws InterruptedException, ExecutionException {
        if (TextUtils.isEmpty(imageUrl)) {
            return null;
        }
        return Glide.with(TUIKit.getAppContext()).asBitmap()
                .load(imageUrl)
                .apply(new RequestOptions().error(R.drawable.default_user_icon))
                .into(targetImageSize, targetImageSize)
                .get();
    }

}
