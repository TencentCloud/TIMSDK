package com.huawei.android.hms.agent.common;

import android.os.Handler;
import android.os.Looper;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * 线程工具，用于执行线程等
 */
public final class ThreadUtil {
    public static final ThreadUtil INST = new ThreadUtil();

    private ExecutorService executors;

    private ThreadUtil(){
    }

    /**
     * 在线程中执行
     * @param runnable 要执行的runnable
     */
    public void excute(Runnable runnable) {
        ExecutorService executorService = getExecutorService();
        if (executorService != null) {
            // 优先使用线程池，提高效率
            executorService.execute(runnable);
        } else {
            // 线程池获取失败，则直接使用线程
            new Thread(runnable).start();
        }
    }

    /**
     * 在主线程中执行
     * @param runnable 要执行的runnable
     */
    public void excuteInMainThread(Runnable runnable){
        new Handler(Looper.getMainLooper()).post(runnable);
    }

    /**
     * 获取缓存线程池
     * @return 缓存线程池服务
     */
    private ExecutorService getExecutorService(){
        if (executors == null) {
            try {
                executors = Executors.newCachedThreadPool();
            } catch (Exception e) {
                HMSAgentLog.e("create thread service error:" + e.getMessage());
            }
        }

        return executors;
    }
}
