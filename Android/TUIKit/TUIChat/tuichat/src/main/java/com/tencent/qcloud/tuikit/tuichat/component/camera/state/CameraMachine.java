package com.tencent.qcloud.tuikit.tuichat.component.camera.state;

import android.content.Context;
import android.view.Surface;
import android.view.SurfaceHolder;

import com.tencent.qcloud.tuikit.tuichat.component.camera.view.CameraInterface;
import com.tencent.qcloud.tuikit.tuichat.component.camera.view.ICameraView;

public class CameraMachine implements State {
    private Context context;
    private State state;
    private final ICameraView cameraView;

    private final State previewState;
    private final State borrowPictureState;
    private final State borrowVideoState;

    public CameraMachine(Context context, ICameraView cameraView) {
        this.context = context;
        previewState = new PreviewState(this);
        borrowPictureState = new BrowserPictureState(this);
        borrowVideoState = new BrowserVideoState(this);
        this.state = previewState;
        this.cameraView = cameraView;
    }

    public ICameraView getCameraView() {
        return cameraView;
    }

    public Context getContext() {
        return context;
    }

    State getBrowserPictureState() {
        return borrowPictureState;
    }

    State getBrowserVideoState() {
        return borrowVideoState;
    }

    State getPreviewState() {
        return previewState;
    }

    @Override
    public void startPreview(SurfaceHolder holder, float screenProp) {
        state.startPreview(holder, screenProp);
    }

    @Override
    public void stop() {
        state.stop();
    }

    @Override
    public void focus(float x, float y, CameraInterface.FocusCallback callback) {
        state.focus(x, y, callback);
    }

    @Override
    public void switchCamera(SurfaceHolder holder, float screenProp) {
        state.switchCamera(holder, screenProp);
    }

    @Override
    public void restart() {
        state.restart();
    }

    @Override
    public void capture() {
        state.capture();
    }

    @Override
    public void startRecord(Surface surface, float screenProp) {
        state.startRecord(surface, screenProp);
    }

    @Override
    public void stopRecord(boolean isShort, long time) {
        state.stopRecord(isShort, time);
    }

    @Override
    public void cancel(SurfaceHolder holder, float screenProp) {
        state.cancel(holder, screenProp);
    }

    @Override
    public void confirm() {
        state.confirm();
    }

    @Override
    public void zoom(float zoom, int type) {
        state.zoom(zoom, type);
    }

    @Override
    public void setFlashMode(String mode) {
        state.setFlashMode(mode);
    }

    public State getState() {
        return this.state;
    }

    public void setState(State state) {
        this.state = state;
    }
}
