package com.tencent.qcloud.tuikit.timcommon.util;

import android.os.Handler;
import android.os.Looper;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ThreadUtils {
    private static final Handler handler = new Handler(Looper.getMainLooper());
    private static final ExecutorService executors = Executors.newCachedThreadPool();
    
    private ThreadUtils() {}

    public static void execute(Runnable runnable) {
        executors.execute(runnable);
    }

    public static boolean isOnMainThread() {
        return Thread.currentThread() == Looper.getMainLooper().getThread();
    }

    public static void runOnUiThread(Runnable runnable) {
        if (isOnMainThread()) {
            runnable.run();
        } else {
            postOnUiThread(runnable);
        }
    }

    public static boolean postOnUiThread(Runnable runnable) {
        return handler.post(runnable);
    }

    public static boolean postOnUiThreadDelayed(Runnable runnable, long delayMillis) {
        return handler.postDelayed(runnable, delayMillis);
    }
}
