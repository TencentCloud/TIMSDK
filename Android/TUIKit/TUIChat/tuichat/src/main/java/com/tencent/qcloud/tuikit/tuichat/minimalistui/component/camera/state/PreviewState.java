package com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.state;

import android.graphics.Bitmap;
import android.view.Surface;
import android.view.SurfaceHolder;

import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.CameraManager;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.CameraView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.ICameraView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

class PreviewState extends State {
    public static final String TAG = "PreviewState";

    PreviewState(ICameraView cameraView) {
        super(cameraView);
    }

    @Override
    public void start(SurfaceHolder holder, float screenProp) {
        TUIChatLog.i(TAG, "start");
        CameraManager.getInstance().doStartPreview(holder, screenProp);
    }

    @Override
    public void stop() {
        TUIChatLog.i(TAG, "stop");
        CameraManager.getInstance().doStopPreview();
    }

    @Override
    public void focus(float x, float y, CameraManager.FocusCallback callback) {
        TUIChatLog.i(TAG, "focus");
        if (cameraView.handlerFoucs(x, y)) {
            CameraManager.getInstance().handleFocus(cameraView.getContext(), x, y, callback);
        }
    }

    @Override
    public void switchCamera(SurfaceHolder holder, float screenProp) {
        TUIChatLog.i(TAG, "switch ");
        CameraManager.getInstance().switchCamera(holder, screenProp);
    }

    @Override
    public void restart() {
        TUIChatLog.i(TAG, "restart ");
        CameraManager.getInstance().doDestroyCamera();
    }

    @Override
    public void capture() {
        TUIChatLog.i(TAG, "capture ");
        CameraManager.getInstance().takePicture(new CameraManager.TakePictureCallback() {
            @Override
            public void captureResult(Bitmap bitmap, boolean isVertical) {
                cameraView.showPicture(bitmap, isVertical);
                TUIChatLog.i(TAG, "capture");
            }
        });
    }

    @Override
    public void record(Surface surface, float screenProp) {
        TUIChatLog.i(TAG, "record");
        CameraManager.getInstance().startRecord(surface, screenProp, null);
    }

    @Override
    public void stopRecord(final boolean isShort, long time) {
        TUIChatLog.i(TAG, "stopRecord " + isShort + " " + time);
        CameraManager.getInstance().stopRecord(isShort, new CameraManager.StopRecordCallback() {
            @Override
            public void recordResult(String url, Bitmap firstFrame) {
                if (isShort) {
                    cameraView.resetState(CameraView.TYPE_SHORT);
                } else {
                    cameraView.playVideo(firstFrame, url);
                }
            }
        });
    }

    @Override
    public void zoom(float zoom, int type) {
        TUIChatLog.i(TAG, "zoom");
        CameraManager.getInstance().setZoom(zoom, type);
    }

    @Override
    public void flash(String mode) {
        TUIChatLog.i(TAG, "flash " + mode);
        CameraManager.getInstance().setFlashMode(mode);
    }
}
