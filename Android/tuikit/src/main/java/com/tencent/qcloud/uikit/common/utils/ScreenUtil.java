package com.tencent.qcloud.uikit.common.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Point;
import android.graphics.Rect;
import android.support.annotation.NonNull;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.common.UIKitConstants;

/**
 * Created by valxehuang on 2018/7/26.
 */

public class ScreenUtil {
    private static int navigationBarHeight = 0;
    private static SharedPreferences preferences = TUIKit.getAppContext().getSharedPreferences(UIKitConstants.UI_PARAMS, Context.MODE_PRIVATE);

    public static boolean checkNavigationBarShow(@NonNull Context context, @NonNull Window window) {
        boolean show;
        Display display = window.getWindowManager().getDefaultDisplay();
        Point point = new Point();
        display.getRealSize(point);

        View decorView = window.getDecorView();
        Configuration conf = context.getResources().getConfiguration();
        if (Configuration.ORIENTATION_LANDSCAPE == conf.orientation) {
            View contentView = decorView.findViewById(android.R.id.content);
            show = (point.x != contentView.getWidth());
        } else {
            Rect rect = new Rect();
            decorView.getWindowVisibleDisplayFrame(rect);
            show = (rect.bottom != point.y);
        }
        return show;
    }


    public static int getNavigationBarHeight() {
        if (navigationBarHeight != 0)
            return navigationBarHeight;
        Resources resources = TUIKit.getAppContext().getResources();
        int resourceId = resources.getIdentifier("navigation_bar_height", "dimen", "android");
        int height = resources.getDimensionPixelSize(resourceId);
        navigationBarHeight = height;
        return height;
    }


    public static int[] getScreenSize() {
        int size[] = new int[2];
        DisplayMetrics dm = TUIKit.getAppContext().getResources().getDisplayMetrics();
        size[0] = dm.widthPixels;
        size[1] = dm.heightPixels;
        return size;
    }

    public static int getStatusBarHeight() {
        int result = 0;
        int resourceId = TUIKit.getAppContext().getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            result = TUIKit.getAppContext().getResources().getDimensionPixelSize(resourceId);
        }
        return result;
    }

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
}
