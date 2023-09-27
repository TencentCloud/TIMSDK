package com.tencent.qcloud.tuikit.tuicallkit.view.common.gridimage

import android.os.Handler
import android.os.Looper
import java.util.concurrent.ExecutorService
import java.util.concurrent.SynchronousQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

object ThreadUtils {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var executors: ExecutorService? = null

    @JvmStatic
    fun execute(runnable: Runnable) {
        if (executors == null) {
            executors = ThreadPoolExecutor(
                0, Int.MAX_VALUE, 60L, TimeUnit.SECONDS,
                SynchronousQueue()
            )
        }
        executors?.execute(runnable)
    }

    @JvmStatic
    fun runOnUIThread(runnable: Runnable) {
        mainHandler.post(runnable)
    }
}