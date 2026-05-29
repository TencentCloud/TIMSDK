package io.trtc.tuikit.atomicx.common.foregroundservice.base

/**
 *后台服务状态说明：
 *  IDLE：空闲状态，默认初始状态
 *  STARTING: 调用start之后一直到服务没有真正启动之前的状态
 *  RUNNING：系统启动后台服务启动完成
 *  STOPPING：调用stop之后到服务被系统真正停止之前的状态
 */
enum class ServiceState {
    IDLE,
    STARTING,
    RUNNING,
    STOPPING
}
