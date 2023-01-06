package com.tencent.qcloud.tuicore.permission;

public abstract class PermissionCallback {
    public abstract void onGranted();
    public void onDenied() {}
}
