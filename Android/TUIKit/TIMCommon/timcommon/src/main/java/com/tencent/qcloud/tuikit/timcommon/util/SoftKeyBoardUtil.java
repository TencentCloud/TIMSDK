package com.tencent.qcloud.tuikit.timcommon.util;

import android.content.Context;
import android.graphics.Rect;
import android.os.IBinder;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import com.tencent.qcloud.tuicore.TUIConfig;

public class SoftKeyBoardUtil {
    public static void hideKeyBoard(IBinder token) {
        InputMethodManager imm = (InputMethodManager) TUIConfig.getAppContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null) {
            imm.hideSoftInputFromWindow(token, 0);
        }
    }

    public static void hideKeyBoard(Window window) {
        InputMethodManager imm = (InputMethodManager) TUIConfig.getAppContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null) {
            if (isSoftInputShown(window)) {
                imm.toggleSoftInput(0, 0);
            }
        }
    }

    public static void showKeyBoard(Window window) {
        InputMethodManager imm = (InputMethodManager) TUIConfig.getAppContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null) {
            if (!isSoftInputShown(window)) {
                imm.toggleSoftInput(0, 0);
            }
        }
    }

    private static boolean isSoftInputShown(Window window) {
        View decorView = window.getDecorView();
        int screenHeight = decorView.getHeight();
        Rect rect = new Rect();
        decorView.getWindowVisibleDisplayFrame(rect);
        return screenHeight - rect.bottom - getNavigateBarHeight(window.getWindowManager()) >= 0;
    }

    private static int getNavigateBarHeight(WindowManager windowManager) {
        DisplayMetrics metrics = new DisplayMetrics();
        windowManager.getDefaultDisplay().getMetrics(metrics);
        int usableHeight = metrics.heightPixels;
        windowManager.getDefaultDisplay().getRealMetrics(metrics);
        int realHeight = metrics.heightPixels;
        if (realHeight > usableHeight) {
            return realHeight - usableHeight;
        } else {
            return 0;
        }
    }
}
