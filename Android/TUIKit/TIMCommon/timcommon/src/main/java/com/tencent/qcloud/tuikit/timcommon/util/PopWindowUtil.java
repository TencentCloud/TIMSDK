package com.tencent.qcloud.tuikit.timcommon.util;

import android.graphics.drawable.ColorDrawable;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.PopupWindow;

public class PopWindowUtil {

    public static PopupWindow popupWindow(View windowView, View parent, int x, int y) {
        PopupWindow popup = new PopupWindow(windowView, WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT);
        popup.setOutsideTouchable(true);
        popup.setFocusable(true);
        popup.setBackgroundDrawable(new ColorDrawable(0xAEEEEE00));
        popup.showAtLocation(windowView, Gravity.CENTER | Gravity.TOP, x, y);
        return popup;
    }
}
