package com.tencent.qcloud.tuicore.util;

import android.view.Gravity;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.qcloud.tuicore.TUIConfig;

/**
 * UI通用方法类
 */
public class ToastUtil {

    private static Toast toast;

    public static void toastLongMessage(final String message) {
        toastMessage(message, true);
    }

    public static void toastShortMessage(final String message) {
        toastMessage(message, false);
    }

    private static void toastMessage(final String message, boolean isLong) {
        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (toast != null) {
                    toast.cancel();
                    toast = null;
                }
                toast = Toast.makeText(TUIConfig.getAppContext(), message,
                        isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT);
                // 解决各个手机系统 toast 文字对齐方式不一致的问题
                View view = toast.getView();
                TextView textView = view.findViewById(android.R.id.message);
                if (textView != null) {
                    textView.setGravity(Gravity.CENTER);
                }
                toast.show();
            }
        });
    }

}
