// Copyright (c) 2024 Tencent. All rights reserved.

package com.tencent.qcloud.tuikit.tuimultimediaplugin.common;

import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * 通用线程池，核心线程个数为1，最大线程个数为3，非核心线程空闲时间为100ms
 */
public class TUIMultimediaCommonThreadPool extends ThreadPoolExecutor {

    public static final int MAX_POOL_SIZE = 3;
    public static ThreadPoolExecutor sCommonThreadPool;

    private TUIMultimediaCommonThreadPool(int poolSize) {
        super(1, poolSize, 100L, TimeUnit.MILLISECONDS,
                new LinkedBlockingDeque<Runnable>(),
                Executors.defaultThreadFactory(), new AbortPolicy());
    }

    public static synchronized ThreadPoolExecutor getThreadExecutor() {
        if (sCommonThreadPool == null || sCommonThreadPool.isShutdown()) {
            sCommonThreadPool = new TUIMultimediaCommonThreadPool(MAX_POOL_SIZE);
        }
        return sCommonThreadPool;
    }

}
