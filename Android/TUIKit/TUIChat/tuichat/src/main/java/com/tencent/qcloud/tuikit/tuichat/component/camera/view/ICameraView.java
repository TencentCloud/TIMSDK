package com.tencent.qcloud.tuikit.tuichat.component.camera.view;

import android.graphics.Bitmap;

public interface ICameraView {
    void resetState(int type);

    void confirmState(int type);

    void showPicture(Bitmap bitmap, boolean isVertical);

    void playVideo(String url);

    void stopPlayVideo();

    void setTip(String tip);

    void startPreviewCallback();

    boolean handlerFocus(float x, float y);
}
