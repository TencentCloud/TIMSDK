package com.tencent.qcloud.tuikit.timcommon.util;

import android.content.Context;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.WindowManager;
import com.tencent.qcloud.tuicore.TUIConfig;

public class ScreenUtil {
    private static final String TAG = ScreenUtil.class.getSimpleName();

    public static int getScreenHeight(Context context) {
        DisplayMetrics metric = new DisplayMetrics();
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        wm.getDefaultDisplay().getMetrics(metric);
        return metric.heightPixels;
    }

    public static int getScreenWidth(Context context) {
        DisplayMetrics metric = new DisplayMetrics();
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        wm.getDefaultDisplay().getMetrics(metric);
        return metric.widthPixels;
    }

    public static int getPxByDp(float dp) {
        float scale = TUIConfig.getAppContext().getResources().getDisplayMetrics().density;
        return (int) (dp * scale + 0.5f);
    }

    public static int dip2px(float dpValue) {
        final float scale = TUIConfig.getAppContext().getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    public static float dp2px(float dpValue, DisplayMetrics displayMetrics) {
        return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dpValue, displayMetrics);
    }
}
