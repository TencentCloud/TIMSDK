package com.tencent.qcloud.tuicore.util;

import android.app.Application;
import android.os.Build;
import android.text.TextUtils;

import java.lang.reflect.Method;

public class TUIUtil {
    private static String currentProcessName = "";

    public static String getProcessName() {
        if (!TextUtils.isEmpty(currentProcessName)) {
            return currentProcessName;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            currentProcessName = Application.getProcessName();
            return currentProcessName;
        }

        try {
            final Method declaredMethod = Class.forName("android.app.ActivityThread", false, Application.class.getClassLoader())
                    .getDeclaredMethod("currentProcessName", (Class<?>[]) new Class[0]);
            declaredMethod.setAccessible(true);
            final Object invoke = declaredMethod.invoke(null, new Object[0]);
            if (invoke instanceof String) {
                currentProcessName = (String) invoke;
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }

        return currentProcessName;
    }
}
