package com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.state;

import android.view.SurfaceHolder;

import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.CameraManager;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.CameraView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view.ICameraView;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class BrowseVideoState extends State {

    private static final String TAG = BrowseVideoState.class.getSimpleName();

    BrowseVideoState(ICameraView cameraView) {
        super(cameraView);
    }

    @Override
    public void start(SurfaceHolder holder, float screenProp) {
        TUIChatLog.i(TAG, "start");
        CameraManager.getInstance().doStartPreview(holder, screenProp);
    }

    @Override
    public void cancel(SurfaceHolder holder, float screenProp) {
        TUIChatLog.i(TAG, "cancel");
        cameraView.resetState(CameraView.TYPE_VIDEO);
    }

    @Override
    public void confirm() {
        TUIChatLog.i(TAG, "confirm");
        cameraView.confirmState(CameraView.TYPE_VIDEO);
    }

}
