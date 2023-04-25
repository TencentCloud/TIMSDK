package com.tencent.qcloud.tuikit.tuicallkit.view.common.gridimage;

import android.os.Handler;
import android.os.Looper;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.SynchronousQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class ThreadUtils {
    private static Handler         mMainHandler = new Handler(Looper.getMainLooper());
    private static ExecutorService mExecutors;

    public static void execute(Runnable runnable) {
        if (mExecutors == null) {
            mExecutors = new ThreadPoolExecutor(0, Integer.MAX_VALUE, 60L, TimeUnit.SECONDS,
                    new SynchronousQueue<>());
        }
        mExecutors.execute(runnable);
    }

    public static void runOnUIThread(Runnable runnable) {
        mMainHandler.post(runnable);
    }
}
