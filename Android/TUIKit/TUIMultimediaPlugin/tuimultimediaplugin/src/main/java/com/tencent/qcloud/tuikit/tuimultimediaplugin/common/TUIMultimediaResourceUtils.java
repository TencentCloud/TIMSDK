package com.tencent.qcloud.tuikit.tuimultimediaplugin.common;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Point;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.util.TypedValue;
import android.view.WindowManager;
import android.widget.ImageView;
import androidx.annotation.ColorInt;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.drawable.DrawableCompat;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaPlugin;
import java.util.Locale;

public class TUIMultimediaResourceUtils {
    public static final String DRAWABLE_RESOURCE_PREFIX = "@drawable/";
    public static final String STRING_RESOURCE_PREFIX = "@string/";

    public static final String TYPE_STRING = "string";
    public static final String TYPE_DRAWABLE = "drawable";

    public static int getDrawableId(String resName) {
        if (resName != null && resName.startsWith(DRAWABLE_RESOURCE_PREFIX)) {
            return getResources().getIdentifier(resName, TYPE_DRAWABLE, TUIMultimediaResourceUtils.getPackageName());
        }
        throw new IllegalArgumentException("\"" + resName + "\" is illegal, must start with \"@\".");
    }

    public static int getStringId(String resName) {
        return getResources().getIdentifier(resName, TYPE_STRING, TUIMultimediaResourceUtils.getPackageName());
    }

    public static String getString(String resName) {
        if (resName != null && resName.startsWith(STRING_RESOURCE_PREFIX)) {
            return getResources().getString(getStringId(resName.substring(STRING_RESOURCE_PREFIX.length())));
        }
        return resName;
    }

    public static String getString(@StringRes int resId) {
        return getResources().getString(resId);
    }

    public static int getColor(int colorId) {
        return getResources().getColor(colorId);
    }


    public static Resources getResources() {
        return TUIMultimediaPlugin.getAppContext().getResources();
    }

    public static Drawable getColorDrawable(int colorId) {
        int color = ContextCompat.getColor(TUIMultimediaPlugin.getAppContext(), colorId); // 获取颜色
        return new ColorDrawable(color);
    }

    @SuppressLint("UseCompatLoadingForDrawables")
    public static Drawable getDrawable(int drawableId) {
        Resources res = getResources();
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            return res.getDrawable(drawableId, null);
        } else {
            return res.getDrawable(drawableId);
        }
    }

    public static Drawable getDrawable(@NonNull Context context, int drawableId, @ColorInt int tint) {
        Drawable drawable = ContextCompat.getDrawable(context, drawableId);
        if (drawable == null) {
            return null;
        }
        Drawable drawableUp = DrawableCompat.wrap(drawable);
        DrawableCompat.setTint(drawableUp, tint);
        return drawableUp;
    }


    public static float spToPx(Context context, float sp) {
        return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, sp, context.getResources().getDisplayMetrics());
    }

    public static Point getScreenSize(Context context) {
        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Point point = new Point();
        windowManager.getDefaultDisplay().getRealSize(point);
        return point;
    }

    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    public static void setImageResource(ImageView imageView, String res) {
        imageView.setImageResource(TUIMultimediaResourceUtils.getDrawableId(res));
    }

    public static String getPackageName() {
        return TUIMultimediaPlugin.getAppContext().getPackageName();
    }

    public static String secondsToTimeString(long timeMs) {
        long seconds = timeMs / 1000;
        int minutes = (int) (seconds / 60);
        seconds = (int) (seconds % 60);
        return String.format(Locale.ENGLISH, "%02d:%02d", minutes, seconds);
    }
}
