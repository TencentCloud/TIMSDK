package com.tencent.qcloud.tuicore.util;

import android.widget.Toast;

import com.tencent.qcloud.tuicore.TUIConfig;

/**
 * UI通用方法类
 */
public class ToastUtil {

    private static Toast toast;

    public static void toastLongMessage(final String message) {
        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (toast != null) {
                    toast.cancel();
                    toast = null;
                }
                toast = Toast.makeText(TUIConfig.getAppContext(), message,
                        Toast.LENGTH_LONG);
                toast.show();
            }
        });
    }


    public static void toastShortMessage(final String message) {
        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (toast != null) {
                    toast.cancel();
                    toast = null;
                }
                toast = Toast.makeText(TUIConfig.getAppContext(), message,
                        Toast.LENGTH_SHORT);
                toast.show();
            }
        });
    }


}
