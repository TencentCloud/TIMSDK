package com.tencent.qcloud.tuikit.timcommon.component.impl;

import android.content.Context;
import android.graphics.Bitmap;
import android.net.Uri;
import android.widget.ImageView;
import com.bumptech.glide.Glide;
import com.bumptech.glide.Priority;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.R;
import java.io.File;
import java.util.concurrent.ExecutionException;

public class GlideEngine {
    public static void loadCornerImageWithoutPlaceHolder(ImageView imageView, Object uri, RequestListener listener, float radius) {
        RoundedCorners transform = null;
        if ((int) radius > 0) {
            transform = new RoundedCorners((int) radius);
        }

        RequestOptions options = new RequestOptions().centerCrop();
        if (transform != null) {
            options = options.transform(transform);
        }
        Glide.with(TUILogin.getAppContext()).load(uri).apply(options).listener(listener).into(imageView);
    }

    public static void clear(ImageView imageView) {
        Glide.with(TUILogin.getAppContext()).clear(imageView);
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

    public void loadImage(Context context, int resizeX, int resizeY, ImageView imageView, Uri uri) {
        Glide.with(context).load(uri).apply(new RequestOptions().override(resizeX, resizeY).priority(Priority.HIGH).fitCenter()).into(imageView);
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
            .diskCacheStrategy(DiskCacheStrategy.ALL)
            .placeholder(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon))
            .apply(new RequestOptions().centerCrop().error(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon)))
            .into(imageView);
    }

    public static void loadUserIcon(ImageView imageView, Object uri, int defaultResId, int radius) {
        Glide.with(TUILogin.getAppContext()).load(uri).placeholder(defaultResId).apply(new RequestOptions().centerCrop().error(defaultResId)).into(imageView);
    }

    public static Bitmap loadBitmap(Object imageUrl, int targetImageSize) throws InterruptedException, ExecutionException {
        if (imageUrl == null) {
            return null;
        }
        return Glide.with(TUILogin.getAppContext())
            .asBitmap()
            .load(imageUrl)
            .apply(new RequestOptions().error(TUIThemeManager.getAttrResId(TUILogin.getAppContext(), R.attr.core_default_user_icon)))
            .into(targetImageSize, targetImageSize)
            .get();
    }

    public static void loadImageSetDefault(ImageView imageView, Object uri, int defaultResId) {
        Glide.with(TUILogin.getAppContext()).load(uri).placeholder(defaultResId).apply(new RequestOptions().centerCrop().error(defaultResId)).into(imageView);
    }
}
