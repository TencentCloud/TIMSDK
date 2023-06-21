package com.tencent.qcloud.tuikit.timcommon.component.gatherimage;

import android.graphics.Bitmap;
import android.graphics.Canvas;

public interface Synthesizer {
    Bitmap synthesizeImageList(MultiImageData imageData);

    boolean asyncLoadImageList(MultiImageData imageData);

    void drawDrawable(Canvas canvas, MultiImageData imageData);
}
