package com.tencent.qcloud.tuikit.tuichat.minimalistui.component.camera.view;

import android.content.Context;
import android.graphics.Bitmap;

public interface ICameraView {

    Context getContext();

    void resetState(int type);

    void confirmState(int type);

    void showPicture(Bitmap bitmap, boolean isVertical);

    void playVideo(Bitmap firstFrame, String url);

    void stopVideo();

    void setTip(String tip);

    void startPreviewCallback();

    boolean handlerFoucs(float x, float y);
}
