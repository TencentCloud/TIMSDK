package com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.photoview.listener;

public interface OnGestureListener {
    void onDrag(float dx, float dy);

    void onFling(float startX, float startY, float velocityX, float velocityY);

    void onScale(float scaleFactor, float focusX, float focusY);
}