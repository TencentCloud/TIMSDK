package com.tencent.qcloud.tuicore.component.gatherimage;

import android.graphics.Bitmap;
import android.graphics.Canvas;


public interface Synthesizer {

    /**
     * 图片合成
     */
    Bitmap synthesizeImageList(MultiImageData imageData);

    /**
     * 异步下载图片列表
     */
    boolean asyncLoadImageList(MultiImageData imageData);

    /**
     * 画合成的图片
     *
     * @param canvas
     */
    void drawDrawable(Canvas canvas, MultiImageData imageData);

}
