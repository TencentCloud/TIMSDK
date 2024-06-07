package com.tencent.qcloud.tuikit.timcommon.util;

import android.app.Activity;
import android.app.AlertDialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import com.tencent.qcloud.tuikit.timcommon.R;

public class PopWindowUtil {

    public static PopupWindow popupWindow(View windowView, View parent, int x, int y) {
        PopupWindow popup = new PopupWindow(windowView, WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT);
        //        int[] position = calculatePopWindowPos(windowView, parent, x, y);
        popup.setOutsideTouchable(true);
        popup.setFocusable(true);
        popup.setBackgroundDrawable(new ColorDrawable(0xAEEEEE00));
        popup.showAtLocation(windowView, Gravity.CENTER | Gravity.TOP, x, y);
        return popup;
    }
}
