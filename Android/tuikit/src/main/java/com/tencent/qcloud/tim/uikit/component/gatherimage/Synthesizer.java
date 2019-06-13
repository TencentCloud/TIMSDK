package com.tencent.qcloud.tim.uikit.component.gatherimage;

import android.graphics.Bitmap;
import android.graphics.Canvas;


public interface Synthesizer {

    /**
     * 图片合成
     */
    Bitmap synthesizeImageList();

    /**
     * 异步下载图片列表
     */
    boolean asyncLoadImageList();

    /**
     * 画合成的图片
     *
     * @param canvas
     */
    void drawDrawable(Canvas canvas);

}
