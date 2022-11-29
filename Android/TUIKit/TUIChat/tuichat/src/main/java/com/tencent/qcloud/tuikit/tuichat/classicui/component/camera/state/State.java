package com.tencent.qcloud.tuikit.tuichat.classicui.component.camera.state;

import android.view.Surface;
import android.view.SurfaceHolder;

import com.tencent.qcloud.tuikit.tuichat.classicui.component.camera.view.CameraInterface;

public interface State {

    void start(SurfaceHolder holder, float screenProp);

    void stop();

    void foucs(float x, float y, CameraInterface.FocusCallback callback);

    void swtich(SurfaceHolder holder, float screenProp);

    void restart();

    void capture();

    void record(Surface surface, float screenProp);

    void stopRecord(boolean isShort, long time);

    void cancle(SurfaceHolder holder, float screenProp);

    void confirm();

    void zoom(float zoom, int type);

    void flash(String mode);
}
