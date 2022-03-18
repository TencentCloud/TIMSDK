package com.tencent.liteav.trtccalling.ui.common;

import android.content.Context;
import android.os.PowerManager;
import android.util.TypedValue;
import android.view.Window;
import android.view.WindowManager;

public class Utils {

    public static int dp2px(Context context, float dpVal) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                dpVal, context.getResources().getDisplayMetrics());
    }

    //锁屏下可直接拉起界面,且通话界面不黑屏
    public static void setScreenLockParams(Window window) {
        if (null == window) {
            return;
        }
        PowerManager powerManager = (PowerManager) window.getContext().getSystemService(Context.POWER_SERVICE);
        boolean isScreenOn = powerManager.isScreenOn();
        if (isScreenOn) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                    | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                    | WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                    | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                    | WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                    | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
        }
    }
}
