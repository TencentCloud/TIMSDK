package io.trtc.tuikit.atomicx.common.permission

abstract class PermissionCallback {
    abstract fun onGranted()

    open fun onRequesting() {}

    open fun onDenied() {}
}
