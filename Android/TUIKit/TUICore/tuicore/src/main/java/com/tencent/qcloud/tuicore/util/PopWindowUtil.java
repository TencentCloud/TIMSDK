package com.tencent.qcloud.tuicore.util;

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

import com.tencent.qcloud.tuicore.R;

public class PopWindowUtil {

    public static AlertDialog buildFullScreenDialog(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            if (activity.isDestroyed())
                return null;
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(activity, R.style.TUIKit_AlertDialogStyle);
        builder.setTitle("");
        builder.setCancelable(true);
        AlertDialog dialog = builder.create();
        dialog.getWindow().setDimAmount(0);
        dialog.setCanceledOnTouchOutside(true);
        dialog.show();
        dialog.getWindow().setLayout(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);
        dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        return dialog;
    }

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
