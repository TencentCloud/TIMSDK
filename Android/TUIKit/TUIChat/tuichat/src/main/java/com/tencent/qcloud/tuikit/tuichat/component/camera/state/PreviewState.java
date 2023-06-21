package com.tencent.qcloud.tuikit.tuichat.component.camera.state;

import android.graphics.Bitmap;
import android.view.Surface;
import android.view.SurfaceHolder;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.component.camera.view.CameraInterface;
import com.tencent.qcloud.tuikit.tuichat.component.camera.view.CameraView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

class PreviewState implements State {
    public static final String TAG = "PreviewState";

    private CameraMachine machine;

    PreviewState(CameraMachine machine) {
        this.machine = machine;
    }

    @Override
    public void startPreview(SurfaceHolder holder, float screenProp) {
        TUIChatLog.i(TAG, "startPreview");
        CameraInterface.getInstance().doStartPreview(holder, screenProp);
    }

    @Override
    public void stop() {
        TUIChatLog.i(TAG, "stop");
        CameraInterface.getInstance().doStopPreview();
    }

    @Override
    public void focus(float x, float y, CameraInterface.FocusCallback callback) {
        TUIChatLog.i(TAG, "preview state focus");
        if (machine.getCameraView().handlerFocus(x, y)) {
            CameraInterface.getInstance().handleFocus(machine.getContext(), x, y, callback);
        }
    }

    @Override
    public void switchCamera(SurfaceHolder holder, float screenProp) {
        TUIChatLog.i(TAG, "switchCamera");
        CameraInterface.getInstance().switchCamera(holder, screenProp);
    }

    @Override
    public void capture() {
        TUIChatLog.i(TAG, "capture");
        CameraInterface.getInstance().takePicture(new CameraInterface.TakePictureCallback() {
            @Override
            public void captureResult(Bitmap bitmap, boolean isVertical) {
                String path = FileUtil.generateImageFilePath();
                boolean result = FileUtil.saveBitmap(path, bitmap);
                if (!result) {
                    TUIChatLog.e(TAG, "take picture save bitmap failed");
                }
                machine.getCameraView().showPicture(bitmap, isVertical);
                machine.getBrowserPictureState().setDataPath(path);
                machine.setState(machine.getBrowserPictureState());
            }
        });
    }

    @Override
    public void startRecord(Surface surface, float screenProp) {
        TUIChatLog.i(TAG, "startRecord");
        CameraInterface.getInstance().startRecord(surface, screenProp);
    }

    @Override
    public void stopRecord(final boolean isShort, long time) {
        TUIChatLog.i(TAG, "stopRecord");
        CameraInterface.getInstance().stopRecord(isShort, new CameraInterface.StopRecordCallback() {
            @Override
            public void recordResult(String path) {
                if (isShort) {
                    FileUtil.deleteFile(path);
                    machine.getCameraView().resetState(CameraView.TYPE_SHORT);
                } else {
                    machine.getBrowserVideoState().setDataPath(path);
                    machine.getCameraView().playVideo(path);
                    machine.setState(machine.getBrowserVideoState());
                }
            }

            @Override
            public void recordFailed(String path) {
                FileUtil.deleteFile(path);
                machine.getCameraView().resetState(CameraView.TYPE_VIDEO);
            }
        });
    }

    @Override
    public void zoom(float zoom, int type) {
        TUIChatLog.i(TAG, "zoom");
        CameraInterface.getInstance().setZoom(zoom, type);
    }

    @Override
    public void setFlashMode(String mode) {
        TUIChatLog.i(TAG, "setFlashMode");
        CameraInterface.getInstance().setFlashMode(mode);
    }
}
