package com.tencent.qcloud.tuikit.timcommon.component.gatherimage;

import android.graphics.Bitmap;
import android.graphics.Color;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Multiple image data
 */

public class MultiImageData implements Cloneable {
    static final int maxSize = 9;
    List<Object> imageUrls;
    int defaultImageResId;
    Map<Integer, Bitmap> bitmapMap;
    int bgColor = Color.parseColor("#cfd3d8");

    int targetImageSize;
    int maxWidth;
    int maxHeight;
    int rowCount;
    int columnCount;
    int gap = 6;

    public MultiImageData() {}

    public MultiImageData(int defaultImageResId) {
        this.defaultImageResId = defaultImageResId;
    }

    public MultiImageData(List<Object> imageUrls, int defaultImageResId) {
        this.imageUrls = imageUrls;
        this.defaultImageResId = defaultImageResId;
    }

    public int getDefaultImageResId() {
        return defaultImageResId;
    }

    public void setDefaultImageResId(int defaultImageResId) {
        this.defaultImageResId = defaultImageResId;
    }

    public List<Object> getImageUrls() {
        return imageUrls;
    }

    public void setImageUrls(List<Object> imageUrls) {
        this.imageUrls = imageUrls;
    }

    public void putBitmap(Bitmap bitmap, int position) {
        if (null != bitmapMap) {
            synchronized (bitmapMap) {
                bitmapMap.put(position, bitmap);
            }
        } else {
            bitmapMap = new HashMap<>();
            synchronized (bitmapMap) {
                bitmapMap.put(position, bitmap);
            }
        }
    }

    public Bitmap getBitmap(int position) {
        if (null != bitmapMap) {
            synchronized (bitmapMap) {
                return bitmapMap.get(position);
            }
        }
        return null;
    }

    public int size() {
        if (null != imageUrls) {
            return imageUrls.size() > maxSize ? maxSize : imageUrls.size();
        } else {
            return 0;
        }
    }

    @Override
    protected MultiImageData clone() throws CloneNotSupportedException {
        MultiImageData multiImageData = (MultiImageData) super.clone();
        if (imageUrls != null) {
            multiImageData.imageUrls = new ArrayList<>(imageUrls.size());
            multiImageData.imageUrls.addAll(imageUrls);
        }
        if (bitmapMap != null) {
            multiImageData.bitmapMap = new HashMap<>();
            multiImageData.bitmapMap.putAll(bitmapMap);
        }
        return multiImageData;
    }
}
