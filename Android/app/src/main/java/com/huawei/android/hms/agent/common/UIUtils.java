package com.huawei.android.hms.agent.common;

import android.app.Activity;
import android.view.WindowManager;

/**
 * 工具类
 */
public final class UIUtils {
    /**
     * 判断当前activity是否为全屏
     * @param activity 当前activity
     * @return 是否全屏
     */
    public static boolean isActivityFullscreen(Activity activity)
    {
        WindowManager.LayoutParams attrs = activity.getWindow().getAttributes();
        if ((attrs.flags & WindowManager.LayoutParams.FLAG_FULLSCREEN) == WindowManager.LayoutParams.FLAG_FULLSCREEN)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}
