package com.tencent.qcloud.tim.uikit.component.video.state;

import android.view.Surface;
import android.view.SurfaceHolder;

import com.tencent.qcloud.tim.uikit.component.video.CameraInterface;
import com.tencent.qcloud.tim.uikit.component.video.JCameraView;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

public class BorrowVideoState implements State {

    private static final String TAG = BorrowVideoState.class.getSimpleName();
    private CameraMachine machine;

    public BorrowVideoState(CameraMachine machine) {
        this.machine = machine;
    }

    @Override
    public void start(SurfaceHolder holder, float screenProp) {
        CameraInterface.getInstance().doStartPreview(holder, screenProp);
        machine.setState(machine.getPreviewState());
    }

    @Override
    public void stop() {

    }

    @Override
    public void foucs(float x, float y, CameraInterface.FocusCallback callback) {

    }


    @Override
    public void swtich(SurfaceHolder holder, float screenProp) {

    }

    @Override
    public void restart() {

    }

    @Override
    public void capture() {

    }

    @Override
    public void record(Surface surface, float screenProp) {

    }

    @Override
    public void stopRecord(boolean isShort, long time) {

    }

    @Override
    public void cancle(SurfaceHolder holder, float screenProp) {
        machine.getView().resetState(JCameraView.TYPE_VIDEO);
        machine.setState(machine.getPreviewState());
    }

    @Override
    public void confirm() {
        machine.getView().confirmState(JCameraView.TYPE_VIDEO);
        machine.setState(machine.getPreviewState());
    }

    @Override
    public void zoom(float zoom, int type) {
        TUIKitLog.i(TAG, "zoom");
    }

    @Override
    public void flash(String mode) {

    }
}
