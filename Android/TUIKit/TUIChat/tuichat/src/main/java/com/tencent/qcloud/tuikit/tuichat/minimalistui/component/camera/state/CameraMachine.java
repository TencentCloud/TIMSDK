package com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.state;

import android.content.Context;
import android.view.Surface;
import android.view.SurfaceHolder;

import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.CameraManager;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.ICameraView;

public class CameraMachine extends State {
    private final Context context;
    private State state;

    private final State previewState;
    private final State browsePictureState;
    private final State browseVideoState;

    public CameraMachine(Context context, ICameraView cameraView) {
        super(cameraView);
        this.context = context;
        previewState = new PreviewState(cameraView);
        browsePictureState = new BrowsePictureState(cameraView);
        browseVideoState = new BrowseVideoState(cameraView);
        this.state = previewState;
    }

    public Context getContext() {
        return context;
    }

    @Override
    public void start(SurfaceHolder holder, float screenProp) {
        state.start(holder, screenProp);
        if (state == browsePictureState || state == browseVideoState) {
            state = previewState;
        }
    }

    @Override
    public void stop() {
        state.stop();
    }

    @Override
    public void focus(float x, float y, CameraManager.FocusCallback callback) {
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
        if (state == previewState) {
            state = browsePictureState;
        }
    }

    @Override
    public void record(Surface surface, float screenProp) {
        state.record(surface, screenProp);
    }

    @Override
    public void stopRecord(boolean isShort, long time) {
        state.stopRecord(isShort, time);
        if (!isShort && state == previewState) {
            state = browseVideoState;
        }
    }

    @Override
    public void cancel(SurfaceHolder holder, float screenProp) {
        state.cancel(holder, screenProp);
        if (state == browsePictureState || state == browseVideoState) {
            state = previewState;
        }
    }

    @Override
    public void confirm() {
        state.confirm();
        if (state == browsePictureState || state == browseVideoState) {
            state = previewState;
        }
    }

    @Override
    public void zoom(float zoom, int type) {
        state.zoom(zoom, type);
    }

    @Override
    public void flash(String mode) {
        state.flash(mode);
    }

}
