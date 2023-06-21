package com.tencent.qcloud.tuikit.tuichat.component.camera.state;

import android.text.TextUtils;
import android.view.SurfaceHolder;

import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.component.camera.view.CameraView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class BrowserVideoState implements State {
    private static final String TAG = BrowserVideoState.class.getSimpleName();
    private CameraMachine machine;
    private String dataPath;

    public BrowserVideoState(CameraMachine machine) {
        this.machine = machine;
    }

    @Override
    public void cancel(SurfaceHolder holder, float screenProp) {
        TUIChatLog.i(TAG, "cancel");
        if (!TextUtils.isEmpty(dataPath)) {
            FileUtil.deleteFile(dataPath);
        }
        dataPath = null;
        machine.getCameraView().stopPlayVideo();
        machine.getCameraView().resetState(CameraView.TYPE_VIDEO);
        machine.setState(machine.getPreviewState());
        machine.startPreview(holder, screenProp);
    }

    @Override
    public void confirm() {
        TUIChatLog.i(TAG, "confirm");
        machine.getCameraView().confirmState(CameraView.TYPE_VIDEO);
        machine.setState(machine.getPreviewState());
    }

    @Override
    public void setDataPath(String dataPath) {
        this.dataPath = dataPath;
    }

    @Override
    public String getDataPath() {
        return dataPath;
    }
}
