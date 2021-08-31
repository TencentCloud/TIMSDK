package com.tencent.qcloud.tim.uikit.utils;

import android.widget.Toast;

import com.tencent.qcloud.tim.uikit.TUIKit;

/**
 * UI通用方法类
 */
public class ToastUtil {

    private static Toast mToast;

    public static final void toastLongMessage(final String message) {
        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mToast != null) {
                    mToast.cancel();
                    mToast = null;
                }
                mToast = Toast.makeText(TUIKit.getAppContext(), message,
                        Toast.LENGTH_LONG);
                mToast.show();
            }
        });
    }


    public static final void toastShortMessage(final String message) {
        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mToast != null) {
                    mToast.cancel();
                    mToast = null;
                }
                mToast = Toast.makeText(TUIKit.getAppContext(), message,
                        Toast.LENGTH_SHORT);
                mToast.show();
            }
        });
    }


}
