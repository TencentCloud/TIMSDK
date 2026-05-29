package io.trtc.tuikit.atomicx.common.event

fun interface INotification {
    fun onNotifyEvent(key: String, subKey: String, param: Map<String, Any?>?)
}
