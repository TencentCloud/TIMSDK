package com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.state;

import android.view.Surface;
import android.view.SurfaceHolder;

import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.CameraManager;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.ICameraView;

public abstract class State {
    protected ICameraView cameraView;
    public State(ICameraView cameraView) {
        this.cameraView = cameraView;
    }

    public void start(SurfaceHolder holder, float screenProp) {}

    public void stop() {}

    public void focus(float x, float y, CameraManager.FocusCallback callback) {}

    public void switchCamera(SurfaceHolder holder, float screenProp) {}

    public void restart() {}

    public void capture() {}

    public void record(Surface surface, float screenProp) {}

    public void stopRecord(boolean isShort, long time) {}

    public void cancel(SurfaceHolder holder, float screenProp) {}

    public void confirm() {}

    public void zoom(float zoom, int type) {}

    public void flash(String mode) {}
}
