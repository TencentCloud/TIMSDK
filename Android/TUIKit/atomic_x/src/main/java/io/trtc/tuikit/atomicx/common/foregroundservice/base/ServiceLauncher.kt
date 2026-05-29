package io.trtc.tuikit.atomicx.common.foregroundservice.base

import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 *
 * api 状态说明：
 * 1、start API说明：{@link AudioForegroundService#start(Context, String, String, int)}
 *  a、如果服务已经被调用start(STARTING) 或者 调用 start 之后服务已经被启动(RUNNING)，此时代表重复 start 可以直接返回
 *  b、如果服务状态为 STOPPING 状态，代表之前 start 之后，在服务没有完全启动时，调用了 stop API,此时由于 start 被后调用，所以变更状态为start
 * 2、stop API说明：{@link AudioForegroundService#stop(Context)}
 *  a、如果服务为 IDLE 状态，调用 stop 为无效操作，可以忽略
 *  b、如果服务为 STARTING 状态，代表服务还没有真正启动，所以需要标记 为 STOPPING。待真正启动之后，再结束自己避免 调用startForegroundService 之后，5秒没有调用
 *  startForeground的异常。
 *  c、如果服务为 RUNNING 状态，代表服务已经启动，直接正常停止即可。
 *  d、如果服务为 STOPPING 状态，代表之前已经调用 stop 且没有完全停止，所以和之前还是一样状态，无需处理。
 */
class ServiceLauncher<T : BaseForegroundService>(
    private val serviceClass: Class<T>,
    private val tag: String
) {
    @Volatile
    var state = ServiceState.IDLE
        private set

    fun start(
        context: Context,
        title: String?,
        description: String?,
        icon: Int,
        permissionChecker: () -> Boolean = { true }
    ) {
        val appContext = context.applicationContext

        if (state == ServiceState.STARTING || state == ServiceState.RUNNING) {
            Log.i(tag, "start foreground service, service is already active")
            return
        }
        if (state == ServiceState.STOPPING) {
            state = ServiceState.STARTING
            Log.i(tag, "start foreground service, changing STOPPING to STARTING")
            return
        }

        state = ServiceState.STARTING
        if (!permissionChecker()) {
            state = ServiceState.IDLE
            Log.e(tag, "start failed: permission denied")
            return
        }

        val intent = Intent(appContext, serviceClass).apply {
            putExtra(BaseForegroundService.TITLE, title)
            putExtra(BaseForegroundService.ICON, icon)
            putExtra(BaseForegroundService.DESCRIPTION, description)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            appContext.startForegroundService(intent)
        } else {
            appContext.startService(intent)
        }
    }

    fun stop(context: Context) {
        val appContext = context.applicationContext
        when (state) {
            ServiceState.RUNNING -> {
                appContext.stopService(Intent(appContext, serviceClass))
                state = ServiceState.IDLE
            }
            ServiceState.STARTING -> state = ServiceState.STOPPING
            else -> {}
        }
    }

    fun updateState(newState: ServiceState) {
        state = newState
    }
}