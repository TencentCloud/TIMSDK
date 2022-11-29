package com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.listener;


public interface CaptureListener {
    void takePictures();

    void recordShort(long time);

    void recordStart();

    void recordEnd(long time);

    void recordZoom(float zoom);

    void recordError();
}
